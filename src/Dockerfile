FROM python:3.13

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /code

# Copy project files from api directory
COPY api/pyproject.toml api/uv.lock ./

# Install dependencies from lock file
RUN uv sync --frozen --no-dev

# Copy the rest of the application
COPY . .

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]