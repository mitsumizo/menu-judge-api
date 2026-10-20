.PHONY: install test lint run

install:
	uv sync

# exit code 5 = "no tests collected", which is fine on day 0
test:
	uv run pytest -q || [ $$? -eq 5 ]

lint:
	uv run ruff check .
	uv run mypy

run:
	uv run uvicorn app.main:app --reload
