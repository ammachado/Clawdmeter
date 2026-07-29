from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def test_pyproject_declares_uv_managed_daemon_dependencies():
    content = (ROOT / "pyproject.toml").read_text()

    assert 'requires-python = ">=3.10"' in content
    assert '"bleak>=0.22"' in content
    assert '"httpx>=0.27"' in content
    assert "[dependency-groups]" in content
    assert 'windows = ["pystray", "pillow"]' in content


def test_legacy_windows_requirements_file_is_removed():
    assert not (ROOT / "daemon" / "requirements-windows.txt").exists()
