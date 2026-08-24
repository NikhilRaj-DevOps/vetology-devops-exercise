FROM python:3.12-slim

WORKDIR /app
COPY app.py .

RUN useradd --uid 10001 --create-home --shell /usr/sbin/nologin appuser
USER 10001

EXPOSE 8080
CMD ["python", "app.py"]