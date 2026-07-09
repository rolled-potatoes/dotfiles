---
name: notion-auto-delegate
description: Use when the user provides a Notion URL (notion.so, notion.site) or asks for 노션 링크 read/write. Delegate Notion I/O to the notion-mcp subagent.
---

# Notion Auto Delegate

Use ONLY when the user message includes a Notion URL or explicitly asks for Notion read/write work.

Trigger cues:
- `https://*.notion.so/...`
- `https://*.notion.site/...`
- `노션 링크`, `Notion URL`, `노션 페이지`, `노션 DB`

Execution policy:
- Delegate Notion I/O (fetch, query, create, update, comments, views) to the `notion-mcp` subagent first.
- For pure Notion tasks, delegate the full task to `notion-mcp`.
- For coding tasks sourced from Notion, delegate only Notion read/write steps to `notion-mcp`; keep code edits in the primary coding agent.
- Preserve existing user-authored Notion content unless the user explicitly requests replacement.

Ambiguous input handling:
- If the user only drops a Notion link with no instruction, first fetch via `notion-mcp`, then return:
  1) concise summary,
  2) key metadata,
  3) suggested next actions.

Fallback policy:
- If subagent delegation is temporarily unavailable, proceed with direct Notion MCP tools and note the fallback in the response.
