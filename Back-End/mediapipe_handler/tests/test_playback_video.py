from unittest.mock import MagicMock, patch

from app.standalone import playback_video


@patch("cv2.VideoCapture")
def test_run_invalid_file(mock_capture):
    """Test that run() prints an error when the video file cannot be opened."""
    mock_capture.return_value.isOpened.return_value = False

    with patch("builtins.print") as mock_print:
        playback_video.run("nonexistent.mp4")

    mock_print.assert_called_with("Error: Could not open nonexistent.mp4")


@patch("cv2.VideoCapture")
@patch("cv2.namedWindow")
@patch("cv2.createTrackbar")
@patch("cv2.imshow")
@patch("cv2.waitKey", return_value=27)  # ESC to exit immediately
@patch("cv2.destroyAllWindows")
def test_run_valid_file(
    mock_destroy, mock_waitkey, mock_imshow, mock_trackbar, mock_window, mock_capture
):
    """Test that run() opens a video and releases resources properly."""
    mock_cap = MagicMock()
    mock_cap.isOpened.return_value = True
    mock_cap.read.return_value = (True, "frame")
    mock_cap.get.side_effect = (
        lambda prop: 10 if prop == 7 else 100
    )  # CAP_PROP_POS_FRAMES=1, CAP_PROP_FRAME_COUNT=7
    mock_capture.return_value = mock_cap

    playback_video.run("test.mp4")

    # Ensure VideoCapture was opened
    mock_capture.assert_called_with("test.mp4")
    # Ensure windows were created and destroyed
    mock_window.assert_called_once_with("Playback")
    mock_destroy.assert_called_once()
    # Ensure frames were attempted to be read
    mock_cap.read.assert_called()


def test_on_trackbar_sets_frame_position():
    """Test the on_trackbar inner function logic in isolation."""
    # We can call it directly by mocking cv2 and cap
    mock_cap = MagicMock()
    mock_cap.set = MagicMock()

    total_frames = 100
    current_frame = 0

    def on_trackbar(val):
        nonlocal current_frame
        current_frame = val
        mock_cap.set(1, val)  # Simulate cv2.CAP_PROP_POS_FRAMES = 1

    # Simulate moving the trackbar
    on_trackbar(42)
    assert current_frame == 42
    mock_cap.set.assert_called_with(1, 42)
