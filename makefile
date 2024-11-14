# Makefile

# Variables
IMAGE_NAME := my-nginx-image
CONTAINER_NAME := my-nginx-container
PORT := 8080

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) test/

# Run the Docker container
run:
	docker run nginx

# Stop and remove the Docker container
stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)