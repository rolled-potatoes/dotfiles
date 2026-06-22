# Explore delegation

When you need to inspect the codebase, find files, search patterns, or map the structure:

- Prefer the `explore` subagent first.
- Use `task` to delegate search work to `explore`.
- Do not do broad repository search directly in the primary agent unless `explore` was insufficient.
- Only fall back to direct `read`, `glob`, or `grep` when you already know the exact file or need a small follow-up check.

Keep exploration cheap and narrow. Use the lowest-cost path that answers the question.
