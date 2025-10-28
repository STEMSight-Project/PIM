def test_ai_modules_importable(repo_root, fake_core_modules):
    from services.tests.conftest import load_service_module

    # ai package files: check they import without executing heavy external deps
    ai_files = [
        "ai_detection_service.py",
        "pim_classifier_service.py",
        "stream_processor.py",
    ]
    for f in ai_files:
        mod = load_service_module(repo_root, f"ai/{f}", f"ai_{f}")
        assert mod is not None
