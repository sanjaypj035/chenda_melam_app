# Stage 1: Build the Flutter web application
FROM cirrusci/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Copy all your project files into the container
COPY . .

# Run Flutter commands to get dependencies and build the web app
RUN flutter pub get
RUN flutter build web --release --base-href /

# Stage 2: Create a lightweight container to serve the static files
FROM nginx:alpine

# Copy the built files from the previous stage into the nginx web root
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 to allow Vercel to serve the application
EXPOSE 80

# Command to start the web server
CMD ["nginx", "-g", "daemon off;"]