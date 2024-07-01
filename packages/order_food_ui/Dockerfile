# Dockerfile for Flutter web app

# Use the Debian base image
FROM debian:bullseye-slim

# Set the working directory
WORKDIR /app

# Install necessary dependencies including ca-certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Increase Git buffer size
RUN git config --global http.postBuffer 524288000

# Install Flutter SDK from the stable branch directly
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git /usr/local/flutter

# Set Flutter environment variables
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable Flutter web
RUN flutter config --enable-web

# Create a non-root user and set permissions
RUN useradd -ms /bin/bash flutteruser && chown -R flutteruser:flutteruser /usr/local/flutter /app

# Switch to the non-root user
USER flutteruser

# Copy the Flutter project files into the container
COPY --chown=flutteruser:flutteruser . /app/

# Ensure Flutter dependencies are up-to-date
RUN flutter pub get

# Build the Flutter web app
RUN flutter build web

# Use an nginx image to serve the Flutter web build
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 to the outside world
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
