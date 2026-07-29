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


def test_installers_and_screenshot_use_uv():
    linux = (ROOT / "install.sh").read_text()
    macos = (ROOT / "install-mac.sh").read_text()
    windows = (ROOT / "install-windows.ps1").read_text()
    screenshot = (ROOT / "screenshot.sh").read_text()

    assert "command -v uv" in linux
    assert "command -v uv" in macos
    assert 'uv sync --project "$SCRIPT_DIR"' in macos
    assert "Get-Command uv" in windows
    assert "uv sync --project $RepoRoot --group windows --python 3.11" in windows
    assert "uv run --with pyserial python -" in screenshot
    assert "pip install" not in macos
    assert "-m venv" not in windows


def test_documentation_describes_uv_workflow_without_pip_or_manual_venvs():
    files = [ROOT / "README.md", ROOT / "CLAUDE.md", ROOT / "daemon" / "README-windows.md"]
    content = "\n".join(path.read_text() for path in files)

    assert "uv" in content
    assert "pip install" not in content
    assert "python -m venv" not in content
    assert "falls back to pio's bundled Python" not in content
