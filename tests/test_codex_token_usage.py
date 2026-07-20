import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
COMMAND = REPO_ROOT / "codex" / ".local" / "bin" / "codex-token-usage"


def usage(total: int) -> dict[str, int]:
    return {
        "input_tokens": total - 10,
        "cached_input_tokens": total // 2,
        "output_tokens": 10,
        "reasoning_output_tokens": 2,
        "total_tokens": total,
    }


class CodexTokenUsageTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.codex_home = Path(self.tempdir.name)
        self.sessions = self.codex_home / "sessions" / "2026" / "07" / "20"
        self.archive = self.codex_home / "archived_sessions"
        self.sessions.mkdir(parents=True)
        self.archive.mkdir()

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def write_rollout(self, path: Path, rows: list[dict], malformed: bool = False) -> None:
        with path.open("w") as stream:
            for row in rows:
                stream.write(json.dumps(row) + "\n")
            if malformed:
                stream.write('{"type":"event_msg"')

    def run_command(self, *args: str) -> subprocess.CompletedProcess[str]:
        environment = os.environ.copy()
        environment["CODEX_HOME"] = str(self.codex_home)
        return subprocess.run(
            [str(COMMAND), *args],
            env=environment,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_agent_tree_model_split_archive_and_malformed_json(self) -> None:
        root_id = "root-session-000001"
        child_id = "child-session-0001"
        root_path = self.sessions / "rollout-root.jsonl"
        self.write_rollout(
            root_path,
            [
                {
                    "type": "session_meta",
                    "payload": {
                        "id": root_id,
                        "timestamp": "2026-07-20T12:00:00Z",
                        "cwd": "/tmp/example",
                        "source": "vscode",
                    },
                },
                {"type": "turn_context", "payload": {"model": "model-alpha"}},
                {
                    "type": "event_msg",
                    "payload": {
                        "type": "token_count",
                        "info": {
                            "total_token_usage": usage(100),
                            "last_token_usage": usage(100),
                        },
                    },
                },
                {"type": "turn_context", "payload": {"model": "model-beta"}},
                {
                    "type": "event_msg",
                    "payload": {
                        "type": "token_count",
                        "info": {
                            "total_token_usage": usage(250),
                            "last_token_usage": usage(150),
                        },
                    },
                },
            ],
            malformed=True,
        )
        shutil.copyfile(root_path, self.archive / "rollout-root-copy.jsonl")

        self.write_rollout(
            self.archive / "rollout-child.jsonl",
            [
                {
                    "type": "session_meta",
                    "payload": {
                        "id": child_id,
                        "timestamp": "2026-07-20T12:01:00Z",
                        "cwd": "/tmp/example",
                        "parent_thread_id": root_id,
                        "agent_role": "explorer",
                        "agent_nickname": "Ada",
                        "source": {
                            "subagent": {
                                "thread_spawn": {
                                    "parent_thread_id": root_id,
                                    "agent_role": "explorer",
                                    "agent_nickname": "Ada",
                                }
                            }
                        },
                    },
                },
                {"type": "turn_context", "payload": {"model": "model-child"}},
                {
                    "type": "event_msg",
                    "payload": {
                        "type": "token_count",
                        "info": {
                            "total_token_usage": usage(50),
                            "last_token_usage": usage(50),
                        },
                    },
                },
            ],
        )
        (self.codex_home / "session_index.jsonl").write_text(
            json.dumps({"id": root_id, "thread_name": "Fixture session"}) + "\n"
        )

        result = self.run_command("--all")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count("Fixture session ["), 1)
        self.assertIn("explorer/Ada", result.stdout)
        self.assertIn("model-alpha: total 100", result.stdout)
        self.assertIn("model-beta: total 150", result.stdout)
        self.assertIn("model-child", result.stdout)
        self.assertIn("tree total: total 300", result.stdout)

    def test_unknown_session_returns_nonzero(self) -> None:
        result = self.run_command("--session", "missing")

        self.assertEqual(result.returncode, 1)
        self.assertIn("No session ID", result.stderr)


if __name__ == "__main__":
    unittest.main()
