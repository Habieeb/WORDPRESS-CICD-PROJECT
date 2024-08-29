# Use the official WordPress image as a base
FROM wordpress:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    nginx

# Copy the custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the port Nginx is listening on
EXPOSE 80

# Start WordPress and Nginx
CMD ["sh", "-c", "service nginx start && docker-entrypoint.sh apache2-foreground"]
]
