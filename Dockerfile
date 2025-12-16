# Dockerfile - minimal Python HTTP server
FROM python:3.11-slim

WORKDIR /app
COPY src/app/requirements.txt .
RUN if [ -s requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

COPY src/app/ .

EXPOSE 8080
CMD ["python", "main.py"]
