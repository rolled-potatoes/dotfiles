import subprocess
import sys
import tempfile
import tomllib
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/configure-codex-agents.py"


class ConfigureCodexAgentsTest(unittest.TestCase):
    def test_preserves_settings_and_updates_idempotently(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            roles = root / 'roles "quoted"'
            roles.mkdir()
            (roles / "reviewer.toml").write_text('model = "example"\n')
            config = root / "config.toml"
            config.write_text('model = "local"\n[agents.personal]\ndescription = "keep"\n')

            def run(dry="0"):
                return subprocess.run([sys.executable, str(SCRIPT), str(config), str(roles), dry], capture_output=True, text=True)

            self.assertEqual(run("1").returncode, 0)
            self.assertNotIn("reviewer", config.read_text())
            self.assertEqual(run().returncode, 0)
            first = config.read_text()
            data = tomllib.loads(first)
            self.assertEqual(data["model"], "local")
            self.assertEqual(data["agents"]["personal"]["description"], "keep")
            self.assertEqual(data["agents"]["reviewer"]["config_file"], str(roles / "reviewer.toml"))
            self.assertEqual(run().returncode, 0)
            self.assertEqual(config.read_text(), first)
            self.assertEqual(len(list(root.glob("config.toml.dotfiles-backup-*"))), 1)
            (roles / "personal.toml").touch()
            self.assertNotEqual(run().returncode, 0)
            self.assertEqual(config.read_text(), first)


if __name__ == "__main__":
    unittest.main()
