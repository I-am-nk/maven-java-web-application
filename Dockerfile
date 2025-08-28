# ------------ STAGE 1: BUILD THE WAR WITH MAVEN ------------
# Use a Maven image that already has Java 17 (LTS) preinstalled.
FROM maven:3.9-eclipse-temurin-17 AS build

# Set working directory inside the image
WORKDIR /app/

# Copy only pom.xml first to leverage Docker layer caching for dependencies
COPY pom.xml .

# Download all dependencies. This is a separate step to cache dependencies.
RUN mvn dependency:go-offline

# Now copy the rest of the application code
COPY src ./src
# Build the application and package it as a WAR file
RUN mvn package

# After this, your WAR will be at /app/target/*.war

# ------------ STAGE 2: RUNTIME WITH TOMCAT ------------
FROM tomcat:11.0-jdk17-temurin

# Optional: clean default webapps (docs/examples) to reduce attack surface & size
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the WAR file from the build stage to the Tomcat webapps directory to deploy it as the root application.
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war


# Expose port 8080 to the outside world
EXPOSE 8080
