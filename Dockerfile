# Use a lightweight Python image
FROM python:3.9-slim

# Maintainer label
LABEL maintainer="local.com"

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PATH="/py/bin:$PATH"

# Install system dependencies & create a non-root user
RUN apt-get update && apt-get install -y \
    default-mysql-client gcc libmariadb-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && python -m venv /py \
    && /py/bin/pip install --upgrade pip \
    && groupadd --system appuser && useradd --system --gid appuser --no-create-home appuser

# Copy project files
WORKDIR /app
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Install Python dependencies
ARG DEV=false
RUN /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi && \
    rm -rf /tmp

# Set permissions & switch user
RUN chown -R appuser:appuser /app
USER appuser

# Expose the application port
EXPOSE 8000

# Default command to run the server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
