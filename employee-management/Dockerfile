# --- Builder Stage ---
# Use a full JDK image with Maven to build the application
FROM openjdk:21-jdk-slim as builder

WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Build the application and create the layered JAR
# Use the Maven wrapper to ensure consistent builds
RUN ./mvnw package -DskipTests

# Extract the layers from the JAR for optimized Docker caching
RUN java -Djarmode=layertools -jar target/*.jar extract


# --- Final Stage ---
# Use a slim JRE for a smaller and more secure final image
FROM eclipse-temurin:21-jre

# Set the working directory in the container
WORKDIR /app

# Create a non-root user to run the application for better security
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Copy the extracted layers from the builder stage
COPY --from=builder /workspace/app/dependencies/ ./
COPY --from=builder /workspace/app/spring-boot-loader/ ./
COPY --from=builder /workspace/app/snapshot-dependencies/ ./
COPY --from=builder /workspace/app/application/ ./

# Change ownership to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# The entrypoint is now the Spring Boot loader, not "java -jar"
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]