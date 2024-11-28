# Use an official Python image
FROM python:3.10

# Set the working directory
WORKDIR /app

# Copy the application and dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# Expose the FastAPI port
EXPOSE 8000

# Start the FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
