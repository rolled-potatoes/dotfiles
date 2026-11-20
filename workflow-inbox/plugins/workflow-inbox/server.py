import json
from pathlib import Path
import sys
import re
import subprocess

ROOT = Path.home() / 'codex-workflow-inbox/result'
URI = 'ui://workflow/inbox-v8.html'
MIME = 'text/html;profile=mcp-app'
META = {'ui': {'resourceUri': URI}, 'openai/ui': {'entrypoints': [{'type': 'thread'}]}, 'openai/outputTemplate': URI}
TOOL = {'name': 'show_inbox', 'title': '작업함', 'description': '실험 작업의 현재 상태와 질문을 대화 패널에 표시합니다.', 'inputSchema': {'type': 'object', 'properties': {}, 'additionalProperties': False}, 'annotations': {'readOnlyHint': True}, '_meta': META}

ARCHIVE_TOOL = {
    'name': 'set_archive', 'description': '선택한 작업을 보관하거나 이전 상태로 복원합니다.',
    'inputSchema': {'type':'object','properties':{
        'id':{'type':'string'}, 'version':{'type':'integer'}, 'archived':{'type':'boolean'}},
        'required':['id','version','archived'],'additionalProperties':False},
    '_meta': {'ui': {'visibility':['app','model']}, 'openai/widgetAccessible':True}
}

LIST_TOOL = {
    'name': 'list_inbox', 'description': '작업함의 최신 목록을 읽습니다.',
    'inputSchema': TOOL['inputSchema'], 'annotations': {'readOnlyHint': True},
    '_meta': {'ui': {'visibility':['app']}, 'openai/widgetAccessible':True}
}

def change_archive(args):
    task = args.get('id')
    if not isinstance(task,str) or not re.fullmatch(r'[A-Za-z0-9-]+',task) or type(args.get('version')) is not int or type(args.get('archived')) is not bool or not (ROOT/task/'status.json').is_file():
        return {'isError':True,'content':[{'type':'text','text':'작업 또는 버전을 확인해 주세요.'}]}
    state = '아카이브' if args['archived'] else '복원'
    proc = subprocess.run([sys.executable,str(Path(__file__).resolve().parents[2]/'bin/workflow'),task,str(args['version']),state,'작업함에서 '+state+' 요청'],capture_output=True)
    rows = tasks()
    return {'isError':bool(proc.returncode),'structuredContent':{'tasks':rows},'content':[{'type':'text','text':'작업 상태가 바뀌었습니다. 다시 확인해 주세요.' if proc.returncode else state+' 완료'}]}

def tasks():
    rows = []
    for status in sorted(ROOT.glob('*/status.json')):
        data = json.loads(status.read_text())
        folder = status.parent
        question = folder/'decision.md'
        pending = data['state']=='계획수정' and not (folder/'answer.txt').exists()
        sessions = json.loads((folder/'sessions.json').read_text()) if (folder/'sessions.json').exists() else {}
        owner = folder/'owner.json'
        answer = folder/'answer.txt'
        project_file = folder/'project.json'
        project = json.loads(project_file.read_text()) if project_file.exists() else None
        rows.append(dict(project=project,version=data['version'],previousState=data.get('previousState'),id=folder.name, owner=json.loads(owner.read_text())['threadId'] if owner.exists() else None,
                         result=next((line.partition(' · ')[2] for line in reversed(data['history']) if ' · 작업함에서 ' not in line),''),
                         next=('제품 결정 필요' if pending else '남은 작업 없음' if data['state']=='개발완료' else '현재 단계 진행'),
                         decision=repr(answer.read_text()) if answer.exists() else None,
                         planning=sessions.get('planning'), development=sessions.get('development'), title=(folder/'title.txt').read_text().strip() if (folder/'title.txt').is_file() else folder.name, state=data['state'], question=question.read_text() if pending and question.exists() else ''))
    return rows

def page():
    template = Path(__file__).with_name('panel.html').read_text()
    rows = json.dumps(tasks(), ensure_ascii=True).replace('<', r'\u003c')
    return template.replace('INITIAL_ROWS', rows)

def handle(method, params):
    if method=='initialize':
        return {'protocolVersion':params.get('protocolVersion','2025-06-18'),'capabilities':{'tools':{},'resources':{}},'serverInfo':{'name':'workflow-inbox','version':'0.4.6'}}
    if method=='tools/list': return {'tools':[TOOL,ARCHIVE_TOOL,LIST_TOOL]}
    if method=='resources/list': return {'resources':[{'name':'작업함','uri':URI,'mimeType':MIME}]}
    if method=='resources/templates/list': return {'resourceTemplates':[]}
    if method=='resources/read' and params.get('uri') in (URI, 'ui://workflow/inbox-v7.html', 'ui://workflow/inbox-v6.html', 'ui://workflow/inbox-v5.html', 'ui://workflow/inbox-v4.html', 'ui://workflow/inbox-v3.html', 'ui://workflow/inbox.html', 'ui://workflow/inbox-v2.html'): return {'contents':[{'uri':params['uri'],'mimeType':MIME,'text':page()}]}
    if method=='tools/call' and params.get('name')=='set_archive': return change_archive(params.get('arguments',{}))
    if method=='tools/call' and params.get('name') in ('show_inbox','list_inbox'):
        rows=tasks()
        thread = params.get('_meta', {}).get('threadId')
        project = None
        if isinstance(thread, str) and re.fullmatch(r'[0-9a-fA-F-]{36}', thread):
            mapping = ROOT.parent/'session-projects'/(thread+'.json')
            if mapping.is_file():
                project = json.loads(mapping.read_text())
        registry = ROOT.parent/'projects.json'
        options = json.loads(registry.read_text()) if registry.exists() else []
        context = {'tasks':rows,'currentProject':project['id'] if project else None,
                   'projects':[{'id':p['id'],'label':p['label']} for p in options]}
        return {'content':[{'type':'text','text':json.dumps(rows,ensure_ascii=False)}],'structuredContent':context,'_meta':META if params['name']=='show_inbox' else {}}
    if method=='ping': return {}
    raise KeyError(method)

for line in sys.stdin:
    req=json.loads(line)
    if 'id' not in req: continue
    response={'jsonrpc':'2.0','id':req['id']}
    try: response['result']=handle(req['method'],req.get('params',{}))
    except KeyError: response['error']={'code':-32601,'message':'Unknown request'}
    except (OSError, ValueError): response['error']={'code':-32603,'message':'Task storage unavailable'}
    print(json.dumps(response,ensure_ascii=False),flush=True)
