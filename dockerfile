
FROM python:3.11-slim

WORKDIR /app


RUN apt-get update && apt-get install -y git openssh-client && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts

COPY pyproject.toml .

COPY . .

RUN --mount=type=ssh pip install .

EXPOSE 8080

CMD ["python", "src/app.py"]

