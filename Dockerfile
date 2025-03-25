# Use a specific Python Alpine image
FROM python:3.12-alpine3.19

# Set the working directory inside the container
WORKDIR /app

# Copy only the requirements file first to leverage Docker cache
COPY requirements.txt . 

# Update package index and install build dependencies, including Git
RUN apk update && \
    apk add --no-cache gcc musl-dev linux-headers postgresql-dev git

# Install uv separately (for better caching and time monitoring)
RUN pip install uv

# Use uv to install dependencies (system-wide for Alpine)
RUN uv pip install --system --no-cache -r requirements.txt

# Install Gunicorn separately for process management
RUN uv pip install gunicorn --system --no-cache

# Remove build dependencies to reduce image size
RUN apk del gcc musl-dev linux-headers

# Copy the rest of the application code
COPY . .

# Set a default PORT to avoid errors
ENV PORT=8080

# Remove Python cache files to reduce image size further
RUN find /app -name "*.pyc" -delete && \
    find /app -name "__pycache__" -delete

# Expose the application port
EXPOSE $PORT

# Automatically determine Gunicorn workers based on CPU count
CMD gunicorn --workers $(nproc) --bind 0.0.0.0:$PORT run:app
