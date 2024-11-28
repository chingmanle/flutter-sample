# Stage 1: Build the Flutter app
FROM debian:bullseye-slim AS build

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter && \
    chmod -R 777 /flutter && \
    git config --global --add safe.directory /flutter && \
    /flutter/bin/flutter doctor -v

# Add Flutter to PATH
ENV PATH="/flutter/bin:$PATH"

# Disable Flutter analytics
RUN flutter config --no-analytics

# Create a non-root user
RUN useradd -ms /bin/bash flutter && \
    chown -R flutter:flutter /flutter

# Switch to the non-root user
USER flutter

# Set the working directory for the Flutter app
WORKDIR /app

# Copy only pubspec files to leverage Docker caching
COPY --chown=flutter:flutter pubspec.yaml pubspec.lock ./


# Ensure the project root is correctly initialized
RUN mkdir -p /app && flutter create .

# Copy the rest of the project files
COPY --chown=flutter:flutter . .

# Install dependencies
RUN flutter pub get

# Build the Flutter web app
RUN flutter build web

# Stage 2: Serve the web app with Nginx
FROM nginx:stable-alpine AS production

# Copy the built Flutter web app from the previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose the web server port
EXPOSE 80
