FROM maven:latest AS builder

#Install docker for running docker in docker
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy curl && \
    curl -sSL https://get.docker.com/ | sh && \
    sed -i '62 s/H//' /etc/init.d/docker
COPY pom.xml /tmp/

# Copy the pom.xml and all microservice directories into the container
COPY api-gateway /tmp/api-gateway
COPY discovery-server /tmp/discovery-server
COPY inventory-service /tmp/inventory-service
COPY notification-service /tmp/notification-service
COPY order-service /tmp/order-service
COPY product-service /tmp/product-service
COPY realms /tmp/realms
WORKDIR /tmp/
RUN mvn clean verify -DskipTests -Djib.skip

# Stage 2: Create the runtime environment
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR files from the builder stage (copy all services as needed)
COPY --from=builder /tmp/product-service/target/product-service-1.0-SNAPSHOT.jar ./product-service.jar

# Expose the port the application will run on
EXPOSE 8080

# Define the command to run the application
CMD ["java", "-jar", "product-service.jar"]