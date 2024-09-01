# Use the official Node.js image as the base image
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy the source code into the container
COPY src/ ./

# Install dependencies (if applicable)
RUN npm install

# Run the build script
RUN npm run build

# Default command to run (if needed)
CMD ["npm", "run", "build"]
