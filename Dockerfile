FROM python:3.11-slim

WORKDIR /app

COPY src/app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/app/ .

ENV PORT=8080

EXPOSE 8080

CMD ["python", "main.py"]
