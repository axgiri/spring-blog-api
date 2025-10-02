## Build stage
FROM eclipse-temurin:24-jdk AS builder
WORKDIR /workspace

# Copy only necessary files first to leverage Docker layer caching
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle ./
COPY src src

# Build the application (skip tests for faster container build)
RUN chmod +x gradlew \
	&& ./gradlew --no-daemon clean bootJar -x test

## Runtime stage
FROM eclipse-temurin:24-jre
WORKDIR /
VOLUME /tmp

# Copy the fat jar from the builder stage
COPY --from=builder /workspace/build/libs/*.jar /app.jar

EXPOSE 8082
ENTRYPOINT ["java","-jar","/app.jar"]