import os
from unittest.mock import MagicMock, patch

from app.standalone import record_video


@patch("cv2.VideoCapture")
@patch("cv2.VideoWriter")
@patch("cv2.VideoWriter_fourcc", return_value=1234)
@patch("cv2.cvtColor", return_value="rgb_image")
@patch("cv2.imshow")
@patch("cv2.waitKey", return_value=27)  # ESC to exit immediately
@patch("cv2.destroyAllWindows")
def test_run_recording_saves_video(
    mock_destroy,
    mock_waitkey,
    mock_imshow,
    mock_cvtcolor,
    mock_fourcc,
    mock_writer,
    mock_capture,
):
    """Test that record_video.run creates a video and calls expected OpenCV functions."""
    mock_cap = MagicMock()
    mock_cap.isOpened.return_value = True
    mock_cap.read.return_value = (True, "frame")
    mock_cap.get.side_effect = lambda prop: {
        3: 640,  # CAP_PROP_FRAME_WIDTH
        4: 480,  # CAP_PROP_FRAME_HEIGHT
        5: 30,  # CAP_PROP_FPS
    }.get(prop, 0)
    mock_capture.return_value = mock_cap

    mock_out = MagicMock()
    mock_writer.return_value = mock_out

    mock_hands = MagicMock()
    mock_hands.__enter__.return_value = mock_hands
    mock_hands.__exit__.return_value = None
    mock_hands.process.return_value = MagicMock(multi_hand_landmarks=None)

    with (
        patch("mediapipe.solutions.hands.Hands", return_value=mock_hands),
        patch("mediapipe.solutions.drawing_utils.draw_landmarks") as mock_draw,
        patch("builtins.print") as mock_print,
    ):
        record_video.run(output_dir="videos")

    # Verify OpenCV objects were created correctly
    mock_capture.assert_called_with(0)
    mock_writer.assert_called()
    mock_destroy.assert_called_once()
    mock_out.write.assert_called()  # At least one frame was written
    mock_print.assert_any_call("Recording... press ESC to stop.")
    assert any(
        "Saved recording to videos" in str(c[0][0]) for c in mock_print.call_args_list
    )


@patch("cv2.VideoCapture")
def test_run_graceful_failure_on_read(mock_capture):
    """Test that the loop exits cleanly if cap.read() fails."""
    mock_cap = MagicMock()
    mock_cap.isOpened.return_value = True
    mock_cap.read.return_value = (False, None)
    mock_capture.return_value = mock_cap

    with (
        patch("mediapipe.solutions.hands.Hands") as mock_hands,
        patch("cv2.VideoWriter") as mock_writer,
        patch("cv2.destroyAllWindows"),
        patch("builtins.print") as mock_print,
    ):
        record_video.run(output_dir="videos")

    mock_print.assert_any_call("Recording... press ESC to stop.")
    # No crash, and "Saved recording to" should still appear
    assert any("Saved recording to" in str(c[0][0]) for c in mock_print.call_args_list)


def test_output_filepath_format(tmp_path):
    """Ensure output filename includes timestamp and .avi extension."""
    out_dir = tmp_path / "videos"
    out_dir.mkdir()

    with (
        patch("cv2.VideoCapture"),
        patch("cv2.VideoWriter"),
        patch("mediapipe.solutions.hands.Hands") as mock_hands,
        patch("cv2.waitKey", return_value=27),
        patch("cv2.destroyAllWindows"),
        patch("builtins.print"),
    ):
        record_video.run(output_dir=str(out_dir))

    files = os.listdir(out_dir)
    assert len(files) == 1
    filename = files[0]
    assert filename.startswith("output_")
    assert filename.endswith(".avi")
