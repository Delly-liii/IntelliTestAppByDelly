# Multi-stage Dockerfile to build Flutter web and serve with nginx
# Build stage
FROM cirrusci/flutter:stable AS builder

WORKDIR /app

# Copy only pubspec first for caching
COPY flutter_app/pubspec.* ./
RUN flutter pub get --offline || flutter pub get

# Copy the rest
COPY flutter_app/ .

# Build web
RUN flutter build web --release

# Production stage
FROM nginx:stable-alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built web app
COPY --from=builder /app/build/web /usr/share/nginx/html

# Add custom nginx config to fallback to index.html for SPA and proxy /api to django
COPY flutter_app/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
