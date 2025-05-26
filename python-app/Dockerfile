# Use official Python slim image
FROM python:3.12-slim

# Set working directory inside container
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source code
COPY . .

# Expose port 5000
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
