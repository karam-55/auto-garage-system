# Build stage
FROM cirrusci/flutter:stable AS build

WORKDIR /app

# Copy pubspec files and download dependencies
COPY pubspec.yaml ./
RUN flutter pub get

# Copy the rest of the Flutter web files
COPY . .

# Build Flutter web
RUN flutter build web --release

# Runtime stage - use lightweight image
FROM nginx:alpine

# Copy built files from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
