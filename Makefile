# Define variables
FLUTTER_PROJECT_NAME ?= my_flutter_app
WEB_PORT ?= 80
BACKEND_PORT ?= 8000

# Default target
all: create

# Create a new Flutter project
create:
	@echo "Creating a new Flutter project: $(FLUTTER_PROJECT_NAME)"
	flutter create $(FLUTTER_PROJECT_NAME)
	@echo "Project created successfully! Navigate to $(FLUTTER_PROJECT_NAME) to start working."

# Build the app for web
build-web:
	@echo "Building the Flutter app for web..."
	cd $(FLUTTER_PROJECT_NAME) && flutter build web
	@echo "Web build complete! Find the output in $(FLUTTER_PROJECT_NAME)/build/web."

# Build the app for Android
build-android:
	@echo "Building the Flutter app for Android..."
	cd $(FLUTTER_PROJECT_NAME) && flutter build apk
	@echo "Android APK build complete! Find the APK in $(FLUTTER_PROJECT_NAME)/build/app/outputs/flutter-apk."

# Serve the web build locally
serve-web:
	@echo "Starting a local web server for testing..."
	cd $(FLUTTER_PROJECT_NAME)/build/web && python3 -m http.server $(WEB_PORT)

# Clean build directories
clean:
	@echo "Cleaning build directories..."
	cd $(FLUTTER_PROJECT_NAME) && flutter clean
	@echo "Clean complete."

# Build and start Docker Compose
docker-compose-up:
	@echo "Building and starting Docker Compose services..."
	docker-compose up --build -d
	@echo "Docker Compose services are up. Backend is running on port $(BACKEND_PORT)."

# Stop Docker Compose
docker-compose-down:
	@echo "Stopping Docker Compose services..."
	docker-compose down
	@echo "Docker Compose services stopped."

# Restart Docker Compose
docker-compose-restart:
	@echo "Restarting Docker Compose services..."
	docker-compose down
	docker-compose up --build -d
	@echo "Docker Compose services restarted."

# Run backend in standalone mode
run-backend:
	@echo "Starting the backend in standalone mode..."
	cd backend/app && uvicorn main:app --host 0.0.0.0 --port $(BACKEND_PORT) --reload

# Display help
help:
	@echo "Usage:"
	@echo "  make create              Create a new Flutter project (default: my_flutter_app)."
	@echo "  make build-web           Build the Flutter app for web."
	@echo "  make build-android       Build the Flutter app for Android."
	@echo "  make serve-web           Serve the web build locally on port $(WEB_PORT)."
	@echo "  make clean               Clean the build directories."
	@echo "  make docker-compose-up   Build and start Docker Compose services."
	@echo "  make docker-compose-down Stop Docker Compose services."
	@echo "  make docker-compose-restart Restart Docker Compose services."
	@echo "  make run-backend         Run the backend locally without Docker."
	@echo "  make help                Show this help message."
