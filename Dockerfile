# Use a specific Python Alpine image
FROM python:3.12-alpine3.19

# Set the working directory inside the container
WORKDIR /app

# Copy only the requirements file first to leverage Docker cache
COPY requirements.txt .

# Update package index and install build dependencies, including Git
RUN apk update && \
    apk add --no-cache gcc musl-dev linux-headers postgresql-dev git

# Install uv (as a separate step to monitor time)
RUN pip install uv

# Use uv to install dependencies (as a separate step to monitor time)
RUN uv pip install --system --no-cache -r requirements.txt

RUN uv pip install gunicorn --system --no-cache

# Remove build dependencies to reduce image size
RUN apk del gcc musl-dev linux-headers

# Copy the rest of the application code
COPY . .

EXPOSE 8080

# Print environment variables and list files for debugging
CMD gunicorn --bind 0.0.0.0:$PORT main:app
