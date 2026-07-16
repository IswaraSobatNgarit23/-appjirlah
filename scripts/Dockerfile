FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY magma_scraper.py .

CMD ["python", "-u", "magma_scraper.py"]
