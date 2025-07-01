FROM ghcr.io/astral-sh/uv:python3.13-bookworm

WORKDIR /backend

COPY .env uv.lock pyproject.toml .

RUN uv sync

ENV PATH="/app/.venv/bin:$PATH"

COPY src .

EXPOSE 8000

CMD ["uv","run","uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
