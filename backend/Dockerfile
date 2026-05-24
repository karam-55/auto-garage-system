# Use latest stable Dart SDK
FROM dart:stable AS build

# Cache busting - change this value to force rebuild
ARG CACHEBUST=2026-05-14-002

# Force rebuild by changing this value
ENV REBUILD_ID=2026-05-14-002

# Set working directory
WORKDIR /app

# Copy pubspec files and install dependencies
COPY pubspec.* ./
RUN dart pub get

# Copy source code
COPY . .

# Exclude migration and seed scripts from production build
RUN rm -f bin/migrate_database.dart bin/seed_data.dart || true

# Force cache invalidation by creating a dummy file with timestamp
RUN echo "Build timestamp: $(date)" > /tmp/build_timestamp.txt

# Compile the server
RUN dart compile exe bin/server.dart -o /app/server

# Runtime stage - use lightweight image
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy compiled binary from build stage
COPY --from=build /app/server /app/server

# Expose port
EXPOSE 8080

# Set environment variable
ENV PORT=8080

# Run the server
CMD ["/app/server"]
