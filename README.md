# AWS Microservices DevOps Project

## Project Overview
This project demonstrates Docker-based microservices deployment
and CI/CD automation using AWS DevOps tools.

## Services
- User Service - Port 3001
- Product Service - Port 3002
- Order Service - Port 3003

## Technologies
- Ubuntu
- Git and GitHub
- Docker
- Docker Compose
- Nginx
- Jenkins
- AWS ECR
- AWS EC2
- Terraform
- Prometheus
- Grafana

## Current Implementation
- Created three sample Node.js microservices.
- Created Dockerfiles for all services.
- Built Docker images.
- Configured Docker Compose.
- Configured Nginx reverse proxy.
- Added service health checks.

## Local Access
- User: http://localhost:8081/users/health
- Product: http://localhost:8081/products/health
- Order: http://localhost:8081/orders/health
