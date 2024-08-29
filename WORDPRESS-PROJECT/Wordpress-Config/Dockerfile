# Use the official WordPress image as the base
FROM wordpress:latest

# Copy custom configuration files if needed
COPY nginx.conf /etc/nginx/nginx.conf

# Add custom scripts or configurations
COPY backup.sh /usr/local/bin/backup.sh

# Set up environment variables, configurations, etc.

# Expose ports if needed
EXPOSE 80
