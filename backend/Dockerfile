
FROM openjdk:17-jdk-slim

LABEL maintainer="your-email@example.com"
LABEL description="Task Management System Backend"

WORKDIR /app

COPY target/task-management-system-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]