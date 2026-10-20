# menu-judge-api

FastAPI backend for [Menu Judge](https://github.com/mitsumizo/menu-judge).
The original app was built with AI. This one is rewritten by hand, to make sure I understand every part.

## Rules

- No AI for writing code. Official docs and Google are fine.
- If stuck for 15 minutes, take one hint, then keep going.
- When a test fails, the first move is `print(r.status_code, r.json())`.

## Commands

```bash
make install  # create .venv and install dependencies
make test     # run pytest
make lint     # ruff + mypy (strict)
make run      # start the dev server on http://127.0.0.1:8000
```

## Plan

Day-by-day milestones: [docs/MILESTONES.md](docs/MILESTONES.md)

| Week | Goal |
|---|---|
| 1 | Upload a menu image, get / list / delete / patch menus. Pydantic models. A fake analyzer. Tests |
| 2 | `MenuAnalyzer` protocol with Claude and fake implementations. `Depends`, lifespan, repository protocol, `dependency_overrides` |
| 3 | Async analysis: `POST` returns 202 and `pending`, a worker on `asyncio.Queue` does the work, `GET` shows `done`. Retry, semaphore |
| 4 | SQLite. Call this API from `menu-judge-next` |
