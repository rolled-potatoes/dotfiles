import json
import sys
from pathlib import Path
from tempfile import NamedTemporaryFile
from uuid import UUID

def register(root, event):
    registry = root / 'projects.json'
    if not registry.is_file() or not event.get('cwd'):
        return
    try:
        thread = str(UUID(event['session_id']))
    except (KeyError, ValueError):
        return
    cwd = Path(event['cwd']).resolve()
    matches = [(Path(p['path']).resolve(), p) for p in json.loads(registry.read_text()) if p.get('path')]
    candidates = [(path, p) for path, p in matches if cwd.is_relative_to(path)]
    project = max(candidates, key=lambda pair: len(pair[0].parts))[1] if candidates else None
    directory = root / 'session-projects'
    directory.mkdir(exist_ok=True)
    with NamedTemporaryFile('w', dir=directory, delete=False) as tmp:
        json.dump(project, tmp)
    Path(tmp.name).replace(directory / (thread + '.json'))

if __name__ == '__main__':
    register(Path.home() / 'codex-workflow-inbox', json.load(sys.stdin))
