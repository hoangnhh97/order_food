# Dockerfile for Django application

# Use an official Python 3.10 runtime as a parent image
FROM python:3.11-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt /app/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Apply patch to rest_framework_simplejwt
RUN sed -i 's/from django.utils.timezone import is_naive, make_aware, utc/from django.utils.timezone import is_naive, make_aware\nfrom datetime import timezone as datetime_timezone\nutc = datetime_timezone.utc/' $(pip show djangorestframework-simplejwt | grep Location | cut -d" " -f2)/rest_framework_simplejwt/utils.py

# Copy the rest of the application code into the container
COPY . /app/

# Make port 8989 available to the world outside this container
EXPOSE 8989

# Run the Django server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8989"]
