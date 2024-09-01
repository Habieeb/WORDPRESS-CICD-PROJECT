COMPREHENSIVE GUIDE TO DEPLOYING DOCKER AND WORDPRESS ON EC2
Table of Contents
1.	Introduction
2.	Prerequisites
3.	Setup EC2 Instance
4.	Install Docker
5.	Install Docker Compose
6.	Creating Dockerfile and Docker Compose file on ec2 instance
7.	Local Development Environment
8.	Local Development Environment SETUP
9.	Setup Docker and Docker Compose for WordPress and MySQL on Local Host
10.	Configure and Deploy with GitHub Actions
11.	Verify Deployment
12.	Troubleshooting
13.	Additional Notes
14.	Directory Structure for Pipeline
15.	Conclusion
________________________________________













INTRODUCTION
This guide outlines the steps to deploy a Dockerized WordPress site on an EC2 instance, using Docker Compose for container orchestration. It covers setting up Docker and Docker Compose, configuring GitHub Actions for CI/CD, and troubleshooting common issues.
Prerequisites
•	AWS Account: An AWS account with permissions to create and manage EC2 instances.
•	EC2 Instance: A running EC2 instance (Ubuntu) with SSH access.
•	GitHub Repository: A GitHub repository to manage your CI/CD pipeline.
•	Docker Hub Account: An account on Docker Hub to store your Docker images.
•	Basic Knowledge: Understanding of Docker, Docker Compose, and SSH.

Step-by-Step Plan to Start the Project
•	Set Up an AWS Cloud Server (EC2 Instance)
•	Install Docker on the EC2 Instance
•	Create a Dockerfile for WordPress on ec2 instance
•	Set Up MySQL Database
•	Configure GitHub Actions for CI/CD
•	Deploy the Application Using GitHub Actions
•	Create a Bash Script for MySQL Backups
Step 1: Set Up an AWS Cloud Server (EC2 Instance)
1.	Log in to AWS Management Console:
o	Go to the AWS Management Console and log in with your credentials.
2.	Launch a New EC2 Instance:
o	Navigate to the EC2 Dashboard.
o	Click "Launch Instance".
o	Select an Amazon Machine Image (AMI); for simplicity, use Amazon Linux 2 or Ubuntu Server 20.04 LTS.
3.	Choose Instance Type:
o	Select an instance type such as t2.micro (eligible for the free tier).
4.	Configure Instance Details:
o	Default settings are generally fine, but ensure that you allow SSH access.
5.	Add Storage:
o	The default 8 GB is usually sufficient, but increase it if needed.
6.	Configure Security Group:
o	Create a new Security Group with rules to allow SSH (port 22), HTTP (port 80), and HTTPS (port 443).
7.	Launch and Connect to Your EC2 Instance:
o	Launch the instance and download the private key (.pem file).
o	Use SSH to connect to your instance:
bash
Copy code
ssh -i /path/to/your-key.pem ec2-user@your-ec2-public-ip
Install Docker
1.	Update the Package List:
bash
Copy code
sudo apt update -y   # For Ubuntu
sudo yum update -y   # For Amazon Linux

2.	Install Docker:
bash
Copy code
sudo apt update
sudo apt install docker-ce
3.	Start and Enable Docker:
bash
Copy code
sudo systemctl start docker
sudo systemctl enable docker
4.	Verify Docker Installation:
bash
Copy code
sudo docker --version
sudo docker run hello-world
Install Docker Compose
1.	Download Docker Compose:
bash
Copy code
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d\" -f4)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
2.	Apply Executable Permissions:
bash
Copy code
sudo chmod +x /usr/local/bin/docker-compose
3.	Verify Docker Compose Installation:
bash
Copy code
docker-compose –version


Step 3: Create a Docker Compose for WordPress & MYSQL
1.	Create a Directory for Docker Compose:
bash
Copy code
mkdir ~/docker-wordpress
cd ~/docker-wordpress
2.	Create a docker-compose.yml File:

version: '3'
services:
  asset-builder:
    image: habeeb24/build-assets-project-asset-builder:latest
    # Ensure this image is available and correctly tagged in your Docker registry
    volumes:
      - ./build-assets:/assets  # Adjust according to where your build outputs are
    command: npm run build  # or the appropriate command for your build process

  wordpress:
    image: habeeb24/wordpress:latest
    ports:
      - "9590:80"
    environment:
      WORDPRESS_DB_HOST: mysql:3306
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: wordpress-db
    depends_on:
      - mysql
      - asset-builder  # Ensure WordPress waits for asset build
    volumes:
      - ./build-assets:/var/www/html/wp-content/assets  # Mount the built assets

  mysql:
    image: habeeb24/mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress-db
      MYSQL_USER: root
      MYSQL_PASSWORD: password
    volumes:
      - mysql_data:/var/lib/mysql
volumes:
  mysql_data:
  build-assets:  # Define volume for asset builds

Step 4: Create a Bash Script for MySQL Backups
1.	Create a Bash Script to Back Up the MySQL Database: SSH into the EC2 instance and create a backup script:
bash
Copy code
#!/bin/bash


# Configuration
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/home/ec2-user/db_backups "     # Backup Directory
MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL_HOST="mysql-container"
MYSQL_PORT="3306"
MYSQL_DB="wordpress"

# Create the new backup directory
mkdir -p "$BACKUP_DIR" || { echo "Failed to create backup directory"; exit 1; }

# Delete the previous backup directory if it exists
LATEST_BACKUP=$(ls -1 /backup | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" | sort | tail -n 1)

if [ -n "$LATEST_BACKUP" ] && [ "$LATEST_BACKUP" != "$TIMESTAMP" ]; then
    echo "Removing old backup: /backup/$LATEST_BACKUP"
    rm -rf "/backup/$LATEST_BACKUP" || { echo "Failed to remove old backup"; exit 1; }
fi

# Create the new database backup
echo "Backing up database..."
mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -P "$MYSQL_PORT" "$MYSQL_DB" > "$BACKUP_DIR/db_backup.sql" \
    && echo "Backup created successfully at $BACKUP_DIR/db_backup.sql" \
    || { echo "Failed to create backup"; exit 1; }

# Optional: Compress the backup
# gzip "$BACKUP_DIR/db_backup.sql"

# Log completion
echo "Backup process completed."
2.	Make the Script Executable:
bash
Copy code
chmod +x /home/ec2-user/db_backup.sh
3.	Schedule Backups Using Cron: Edit the crontab to schedule the script (e.g., daily at 2 AM):
bash
Copy code
crontab -e

# Add the following line
0 2 * * * /home/ec2-user/db_backup.sh















Local Development Environment
Your local development environment is where you build, test, and modify your application before deploying it to a remote server or cloud environment. This includes the computer or workstation you use to develop your code. For a WordPress project with Docker, here’s what "locally" typically involves:
1. Tools and Software on Your Local Machine
•	Docker:
o	Purpose: To run and test your application containers locally before deploying them to AWS.
o	Installation: Install Docker Desktop on your operating system (Windows, macOS, or Linux) to create and manage containers.
•	Git:
o	Purpose: To manage version control of your codebase, including committing changes, creating branches, and pushing code to GitHub.
o	Installation: Install Git to clone repositories, commit code, and interact with version control.
•	Code Editor:
o	Purpose: To write and edit your code and configuration files. Examples include Visual Studio Code, Sublime Text, or Atom.
o	Installation: Install your preferred code editor to work with your codebase.
•	Programming Languages and Tools:
o	Purpose: Install any required programming languages (e.g., PHP, Node.js) or tools needed for development and testing.
o	Installation: Install these tools as required by your project (e.g., Node.js for JavaScript development).
2. Local Development Workflow
1.	Develop Locally:
o	Write and test your code on your local machine. For a WordPress project, this involves working on themes, plugins, and configuration files.
2.	Run Locally:
o	Use Docker to build and run your WordPress container locally. This allows you to test changes in an environment similar to your production setup without deploying to AWS.
3.	Version Control:
o	Use Git to track changes to your codebase and collaborate with others. Push code changes to your GitHub repository for continuous integration and deployment.
4.	Testing:
o	Test your application locally to ensure everything works as expected before pushing changes to your remote repository or deploying them.
5.	Configuration:
o	Configure Docker, environment variables, and other settings needed for local development. Ensure your Docker setup closely mirrors your production environment for accurate testing.
3. Preparing for Deployment
•	Create Docker Images:
o	Build Docker images of your application and services that you can deploy to your EC2 instance.
•	Push Code to GitHub:
o	Commit your changes and push them to your GitHub repository, which triggers your CI/CD pipeline (e.g., GitHub Actions) to deploy the changes to your EC2 instance.

Using Git Bash with Docker Desktop as Local Development Environment
1.	Open Git Bash
Open Git Bash from your start menu or application launcher.
Setting Up Local Development Environment
2.	**Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/your-repository.git
   cd your-repository
3.	Navigate to Your Project Directory
Change to your project directory where your Dockerfile and docker-compose.yml (if using Docker Compose) are located:
bash
Copy code
cd path/to/your/project
4.	Create docker-compose.yml 
Use Docker Compose to manage multiple containers, create and edit docker-compose.yml:
bash
Copy code
touch docker-compose.yml
nano docker-compose.yml
5.	Build Docker Images
Build your Docker image using the Docker command in Git Bash:
bash
Copy code
docker build -t your-image-name .
Replace your-image-name with a name for your Docker image.
6.	Run Docker Containers
Run your Docker containers:
bash
Copy code
docker run -d -p 8080:80 your-image-name
You can also use Docker Compose if you have a docker-compose.yml file:
bash
Copy code
docker-compose up -d
7.	Check Running Containers
Use Docker commands to check the status of your containers:
bash
Copy code
docker ps
8.	Stop and Remove Containers
Stop and remove containers when you’re done:
bash
Copy code
docker stop container-id
docker rm container-id
If using Docker Compose:
bash
Copy code
docker-compose down

Additional Tips
•	Docker Desktop Dashboard: Use the Docker Desktop dashboard to visually manage your containers, images, and volumes.
•	Networking: Make sure the ports used by your containers do not conflict with other services on your local machine.
•	Logs: Check container logs through Docker Desktop or Git Bash to troubleshoot issues:
bash
Copy code
docker logs container-id


Setup Docker and Docker Compose for WordPress and MySQL on Local Development Environment
1. Create a Directory for Docker Compose:
bash
Copy code
mkdir ~/docker-wordpress
cd ~/docker-wordpress
2. Create a docker-compose.yml File:
yaml
Copy code
version: '3.1'

services:
  wordpress:
    image: wordpress:latest
    ports:
      - 9595:80
    environment:
      WORDPRESS_DB_HOST: mysql:3306
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: wordpress_db
    networks:
      - wp-network

  mysql:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress_db
      MYSQL_USER: root
      MYSQL_PASSWORD: password
    networks:
      - wp-network

networks:
  wp-network:
    driver: bridge


3.	Run Docker Compose Containers docker-compose.yml file
bash
Copy code
docker-compose up -d
4.	Check Running Containers
Use Docker commands to check the status of your containers:
bash
Copy code
docker ps



Step 4: Set Up MySQL Database on Local Development Environment
1.	Pull and Run MySQL Docker Container: 
bash
Copy code
docker run --name wordpressdb -e MYSQL_ROOT_PASSWORD=rootpassword -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=wordpress -d mysql:5.7
2.	Create a Persistent Volume for MySQL Data (optional but recommended):
bash
Copy code
docker volume create mysql_data
docker run --name wordpressdb -v mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=rootpassword -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=wordpress -d mysql:5.7

5.	Start the Containers:
bash
Copy code
sudo docker-compose up -d
6.	Check the Running Containers:
bash
Copy code
sudo docker ps



Step-by-Step Guide to Link MySQL Container with WordPress on Local Development Environment
1. Create a Docker Network:
Create a custom Docker network that both the MySQL and WordPress containers will use to communicate.
docker network create wordpress-network

bash
Copy code
docker network create wordpress-network
2. Run the MySQL Container:
Start the MySQL container using the created network. Make sure to set the root password and database name as environment variables.
docker run -d --name mysql-container --network wordpress-network -e MYSQL_ROOT_PASSWORD=rootpassword -e MYSQL_DATABASE=wordpress mysql:5.7
bash
Copy code
docker run -d --name mysql-container --network wordpress-network -e MYSQL_ROOT_PASSWORD=rootpassword -e MYSQL_DATABASE=wordpress mysql:5.7
•	--name mysql-container gives the container a name (mysql-container).
•	--network wordpress-network connects the container to the wordpress-network.
•	-e MYSQL_ROOT_PASSWORD=rootpassword sets the root password for MySQL.
•	-e MYSQL_DATABASE=wordpress creates a new MySQL database named wordpress.
3. Run the WordPress Container Linked to the MySQL Container:
Run the WordPress container using the same network and link it to the MySQL container by setting the necessary environment variables.
docker run -d --name wordpress-container --network wordpress-network -e WORDPRESS_DB_HOST=mysql-container:3306 -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=rootpassword -e WORDPRESS_DB_NAME=wordpress -p 8080:80 wordpress:latest
bash
Copy code
docker run -d --name wordpress-container --network wordpress-network -e WORDPRESS_DB_HOST=mysql-container:3306 -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=rootpassword -e WORDPRESS_DB_NAME=wordpress -p 8080:80 wordpress:latest
•	--name wordpress-container gives the container a name (wordpress-container).
•	--network wordpress-network connects the container to the wordpress-network.
•	-e WORDPRESS_DB_HOST=mysql-container:3306 sets the MySQL host to the name of the MySQL container (mysql-container) and port 3306.
•	-e WORDPRESS_DB_USER=root sets the MySQL user to root.
•	-e WORDPRESS_DB_PASSWORD=rootpassword sets the MySQL root password.
•	-e WORDPRESS_DB_NAME=wordpress specifies the WordPress database name to connect to (wordpress).
•	-p 8080:80 maps port 80 in the container to port 8080 on your host machine.
Connect the Existing MySQL Container to the Network:
Connect the already running MySQL container to the wordpress-network
•	docker network connect wordpress-network mysql
•	Run the WordPress Container Linked to the MySQL Container:
•	Now, run a WordPress container that is linked to the MySQL container using the same network:
•	docker run -d --name wordpress-container --network wordpress-network -e WORDPRESS_DB_HOST=mysql:3306 -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=rootpassword -e WORDPRESS_DB_NAME=wordpress -p 8080:80 wordpress:latest
•	Replace rootpassword with the actual root password you set for the MySQL container.
•	

4. Access WordPress in the Browser:
Now, you should be able to access WordPress by opening http://localhost:8080 in your browser. You should see the WordPress setup page, where you can complete the installation.
5. Verify the Setup:
•	To check if both containers are running and connected to the same network, run:
•	
•	docker ps
•	docker network inspect wordpress-network
bash
Copy code
docker ps
•	To verify that both containers are on the wordpress-network:
bash
Copy code
docker network inspect wordpress-network
You should see both mysql-container and wordpress-container listed under the network.
Additional Notes
•	Network Configuration: Ensure that both the MySQL and WordPress containers are on the same Docker network to enable communication between them.
•	Nginx Container Managed by Kubernetes: You currently have an Nginx container (k8s_nginx_nginx_default...) managed by Kubernetes, which may conflict with WordPress if using the same ports (like port 80). If this is unnecessary, consider stopping the Kubernetes-managed Nginx container.

6. Troubleshooting:
•	Database Connection Error: If WordPress cannot connect to the database, make sure that the WORDPRESS_DB_HOST, WORDPRESS_DB_USER, WORDPRESS_DB_PASSWORD, and WORDPRESS_DB_NAME environment variables are correctly set and that the MySQL container is running.
•	Port Issues: If you cannot access WordPress at http://localhost:8080, ensure the port mapping is correct and no other service is using port 8080.




Configure and Deploy with GitHub Actions
1.	Create GitHub Secrets:
o	Go to your GitHub repository.
o	Navigate to Settings > Secrets and variables > Actions.
o	Add secrets: DOCKER_USERNAME, DOCKER_PASSWORD, EC2_HOST, and EC2_SSH_PRIVATE_KEY.
2.	Create GitHub Actions Workflow:
name: Deploy WordPress to EC2

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'

      - name: Install dependencies
        run: npm install

      - name: Build assets
        run: npm run build

      - name: Build Docker image
        run: docker build -t your-dockerhub-username/wordpress:latest .

      - name: Push Docker image
        run: docker push your-dockerhub-username/wordpress:latest

      - name: Deploy to EC2
        env:
          SSH_PRIVATE_KEY: ${{ secrets.EC2_SSH_PRIVATE_KEY }}
          EC2_HOST: ${{ secrets.EC2_HOST }}
        run: |
          echo "$SSH_PRIVATE_KEY" > id_rsa
          chmod 600 id_rsa
          ssh -i id_rsa -o StrictHostKeyChecking=no ubuntu@$EC2_HOST << 'EOF'
            docker pull your-dockerhub-username/wordpress:latest
            cd /path/to/your/docker-compose
            docker-compose pull
            docker-compose up -d  #1
          EOF
      
3.	Commit the Workflow File: Save this YAML configuration to .github/workflows/deploy.yml in your GitHub repository.
Verify Deployment
1.	Access Your WordPress Site: Open a web browser and navigate to http://<your-ec2-public-ip>:9595.
2.	Check Container Status:
bash
Copy code
sudo docker ps
3.	Check Logs for Any Errors:
bash
Copy code
sudo docker logs wordpress-container
sudo docker logs mysql-container
Troubleshooting
1.	Cannot Reach the Site:
o	Verify EC2 security group settings.
o	Check Docker container ports and status.
o	Ensure your EC2 instance has a public IP and the domain name resolves correctly.
2.	Container Not Starting:
o	Inspect container logs for errors.
o	Ensure environment variables are correctly set.
o	Verify Docker and Docker Compose configurations.
3.	Database Connection Issues:
o	Ensure MySQL container is running and accessible.
o	Verify database credentials and environment variables.

Additional Notes
•	Security: For production environments, consider securing your site with HTTPS and properly managing database credentials.
•	Backups: Regularly back up your WordPress data and database.
•	Updates: Keep your Docker images and EC2 instance updated for security and performance.

Challenges and Resolutions
Network Connectivity Issues
Challenge: During the deployment process, there were issues with network connectivity, specifically with reaching the EC2 instance from external sources such as GitHub Actions. The primary challenge was ensuring that Docker running on the EC2 instance could connect to Docker Hub for pulling images. This issue led to the failure of the workflow from GitHub Actions due to the inability to retrieve Docker images from the GitHub registry.
Resolution:
1.	Security Group Settings:
o	Issue: The EC2 instance’s security group may not have been configured to allow necessary inbound and outbound traffic, blocking connections required for the Docker operations.
o	Action: Verify and modify the security group settings in the AWS Management Console to ensure that:
	Inbound rules permit HTTP (port 80) and HTTPS (port 443) if your application needs web access.
	Outbound rules allow traffic to Docker Hub’s registry. By default, all outbound traffic is allowed, but it’s worth checking if there are any restrictions.
2.	Network ACLs:
o	Issue: Network Access Control Lists (ACLs) associated with the EC2 instance’s subnet might be restricting traffic.
o	Action: Ensure that the network ACLs allow inbound and outbound traffic on the required ports. Check and update the ACL settings to permit traffic on ports used by Docker and any other services your application relies on.
3.	Instance Connectivity:
o	Issue: The EC2 instance might not have a public IP or might be improperly configured, preventing it from being reachable from the outside or from Docker Hub.
o	Action: Confirm that the EC2 instance has an Elastic IP or public IP address assigned. Verify that the instance is properly configured to allow inbound connections on the necessary ports.

4.	Firewall Settings:
o	Issue: Internal firewalls on the EC2 instance, such as ufw on Ubuntu, might be blocking necessary ports.
o	Action: Configure the internal firewall to allow traffic on ports used by Docker. Use the following commands to open the relevant ports:
bash
Copy code
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
5.	Docker Configuration:
o	Issue: Docker might be misconfigured or unable to resolve Docker Hub’s address.
o	Action: Check Docker's DNS settings and network configuration. Ensure Docker is able to resolve external domain names and communicate with Docker Hub. You can test Docker’s DNS resolution by running:
bash
Copy code
docker run busybox nslookup docker.io
6.	Nginx or Web Server Configuration:
o	Issue: If you’re using Nginx or another web server, it might not be correctly forwarding requests to the Docker containers.
o	Action: Ensure Nginx is configured to listen on the appropriate ports and forward traffic to the Docker containers. Verify that the configuration file (/etc/nginx/sites-available/default or similar) correctly maps requests to the containers.
By addressing these network connectivity issues and ensuring proper configuration of security groups, network ACLs, instance settings, and Docker, you can resolve the connectivity issues that prevented your GitHub Actions workflow from succeeding. This will allow Docker on your EC2 instance to successfully pull images from Docker Hub and ensure a smooth deployment process.

Verification and Testing
1.	Check Running Containers:
bash
Copy code
sudo docker ps
o	Confirm mysql, wordpress, and asset-builder containers are up.

2.	Access Application Logs:
bash
Copy code
sudo docker-compose logs
o	Review logs for errors or confirmation of successful deployment.
3.	Verify WordPress Accessibility:
o	Open http://<EC2_IP_ADDRESS>:9595 in your web browser to check if WordPress is accessible.
4.	Confirm Asset Build:
o	Check if theme assets are correctly built and integrated.
Troubleshooting Tips
•	Check Container Status: Use sudo docker ps and sudo docker-compose logs for debugging.
•	Permissions: Use sudo where necessary for Docker commands on EC2.
•	Port Conflicts: Ensure that no other services are using the configured ports.













Comprehensive Documentation for CI/CD Pipeline and Asset Building
Overview
This documentation details the setup of a CI/CD pipeline for building assets and deploying a WordPress application using Docker. It includes information about the tools and technologies used, the pipeline configuration, challenges faced, solutions implemented, and improvements made. Additionally, it emphasizes the importance of directory structure in GitHub Actions workflows and provides an overview of the directory flow for the pipeline.

Tools and Technologies
1.	Local Development Environment:
o	Git: Version control system for managing source code.
o	GitHub: Repository hosting service for version control and collaboration.
o	GitHub Actions: CI/CD service for automating build and deployment processes.
o	Docker: Containerization platform for building and running applications in isolated environments.
o	Docker Compose: Tool for defining and running multi-container Docker applications.
o	Node.js: Runtime environment for building assets (e.g., compiling SCSS, JavaScript).
2.	Remote Environment (EC2 Instance):
o	Amazon EC2: Virtual server for deploying Docker containers.
o	Docker: Installed on EC2 for managing containers.
o	Docker Compose: Used on EC2 for orchestrating container deployment.
o	Nginx: Web server used to serve the WordPress application (if applicable).
3.	Docker Hub:
o	Docker Hub: Cloud-based Docker registry for storing and managing Docker images.
o	Docker Hub Webhook: Triggers actions when new images are pushed to the repository.
4.	GitHub Actions:
o	GitHub Actions Workflow: Automates the build and deployment pipeline.



Local Development Environment
Directory Structure
Root Directory
•	.github/: Contains GitHub Actions workflows for CI/CD processes.
o	workflows/: Contains YAML files for defining CI/CD workflows.
•	BUILD-ASSETS-PROJECT/: Contains configuration and source files for building and deploying assets.
o	dist/: Directory where built assets are output. This directory is generated during the build process.
o	src/: Source files for the assets, including SCSS and JavaScript files.
o	Dockerfile: Dockerfile for creating a Docker image that builds and deploys the theme assets.
o	docker-compose.yml: Docker Compose configuration file to set up and manage multi-container Docker applications.
o	package.json: Defines project metadata, dependencies, and scripts for the Node.js project.
o	webpack.config.js: Webpack configuration file for bundling SCSS and JavaScript assets.
•	WORDPRESS-PROJECT/: Placeholder for the WordPress project directory. This directory is expected to contain the WordPress theme or project that integrates with the built assets.
•	BreadcrumbsWORDPRESS-CICD-PROJECT/: Placeholder or sub-directory related to WordPress CI/CD processes.
Files and Their Purposes
.github/workflows/
Contains YAML files defining the GitHub Actions workflows. These workflows automate the build, test, and deployment processes. Check the YAML files here to understand the CI/CD pipelines.
dist/
This directory will contain the final output of the asset build process, including the compiled and minified SCSS and JavaScript files. It is populated by the build process and should not be manually edited.
src/
The src directory contains all the source files for your assets. This includes:
•	SCSS Files: Stylesheets written in SCSS that will be compiled into CSS.
•	JavaScript Files: Scripts that will be bundled into a single file or multiple files as needed.
Dockerfile
The Dockerfile describes the steps to create a Docker image for building and deploying the theme assets. It includes instructions for setting up the environment, installing dependencies, and running the build process.
docker-compose.yml
The Docker Compose file defines services, networks, and volumes needed for the Docker containers. It helps to orchestrate multi-container Docker applications.
package.json
The package.json file contains metadata about the project, including dependencies (e.g., Webpack, loaders, plugins), scripts for running build processes, and project information.
webpack.config.js
The Webpack configuration file specifies how to bundle and process SCSS and JavaScript files. It defines entry points, output settings, loaders for handling different file types, and plugins for optimizing the build.

CI/CD Pipeline Setup
1. Local Development and Configuration
1.	Setting Up the Project:
o	Clone Repository:
bash
Copy code
git clone https://github.com/yourusername/your-repo.git
cd your-repo
2.	Docker Configuration:
o	Dockerfile: Defines the build instructions for your Docker images.
o	docker-compose.yml: Defines the multi-container setup including wordpress, mysql, and asset-builder.
Sample docker-compose.yml:
yaml
Copy code
version: '3'
services:
  asset-builder:
    image: habeeb24/build-assets-project-asset-builder:latest
    volumes:
      - ./build-assets:/assets
    command: npm run build

  wordpress:
    image: habeeb24/wordpress:latest
    ports:
      - "9590:80"
    environment:
      WORDPRESS_DB_HOST: mysql:3306
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: wordpress-db
    depends_on:
      - mysql
      - asset-builder
    volumes:
      - ./wordpress-data:/var/www/html
      - ./build-assets:/var/www/html/assets

  mysql:
    image: habeeb24/mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress-db
      MYSQL_USER: root
      MYSQL_PASSWORD: password
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
  wordpress_data:
3.	Build Scripts:
o	npm scripts: Include commands to build assets. Defined in package.json.
{
  "scripts": {
    "build": "npm run build:js",
    "build:js": "webpack --config webpack.config.js"
  },
  "devDependencies": {
    "webpack": "^5.94.0",
    "webpack-cli": "^5.0.0"
  }
}
•	dist/: Directory where built assets are output. This directory is generated during the build process.
•	bundle.js: The bundled JavaScript file output by Webpack. It includes all the JavaScript code from your src/ directory and any dependencies.

const path = require('path');

module.exports = {
  entry: './src/index.js', // Update this to the correct entry file path
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  mode: 'production',
};


•	src/: Source files for the assets, including SCSS and JavaScript files.
•	index.js: The main JavaScript entry point for the project.

// index.js
console.log('Hello, world!');
4.	Dockerfile:
o	Defines how to build the asset-builder Docker image.
Dockerfile for Asset Builder:
dockerfile
Copy code
FROM node:14
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "build"]








Build and Deployment Process
1.	Setup Docker:
o	Build the Docker image using the Dockerfile: docker build -t theme-assets-builder .
o	Start the Docker containers using Docker Compose: docker-compose up
2.	Build Assets:
o	Inside the Docker container, run the build process defined in package.json scripts (e.g., npm run build).
o	This will compile SCSS files, bundle JavaScript files, and output them to the dist/ directory.
3.	Deploy Assets:
o	Copy or deploy the assets from the dist/ directory to the appropriate location in your WordPress project.
4.	CI/CD Integration:
o	GitHub Actions will automatically run the defined workflows to build, test, and deploy the assets on push or pull request events.
Additional Notes
•	Ensure Docker and Docker Compose are installed and configured on your machine.
•	Make sure to update dependencies in package.json as needed.
•	Verify the Webpack configuration to ensure it meets the needs of your project.
•	Regularly review and test GitHub Actions workflows to ensure they are working as expected.

2. GitHub Actions Workflow
1.	Creating GitHub Actions Workflow:
o	Workflow File: .github/workflows/ci-cd.yml
Sample Workflow File:
name: Pull and Push Docker Images

on:
  push:
    branches:
      - main

jobs:
  pull-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Pull WordPress base image
        run: |
          docker pull wordpress:latest
      - name: Tag WordPress image
        run: |
          docker tag wordpress:latest ${{ secrets.DOCKER_USERNAME }}/wordpress:latest
      - name: Push WordPress image to Docker Hub
        run: |
          docker push ${{ secrets.DOCKER_USERNAME }}/wordpress:latest
      - name: Pull MySQL image
        run: |
          docker pull mysql:5.7
      - name: Tag MySQL image
        run: |
          docker tag mysql:5.7 ${{ secrets.DOCKER_USERNAME }}/mysql:5.7
      - name: Push MySQL image to Docker Hub
        run: |
          docker push ${{ secrets.DOCKER_USERNAME }}/mysql:5.7
      - name: Deploy to EC2
        env:
          SSH_PRIVATE_KEY: ${{ secrets.EC2_SSH_PRIVATE_KEY }}
          EC2_HOST: ${{ secrets.EC2_HOST }}
        run: |
          # Create the .ssh directory if it doesn't exist
          mkdir -p ~/.ssh
          
          # Create the SSH key file
          echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          
          # Add the host to known_hosts to prevent host key verification issues
          ssh-keyscan -H $EC2_HOST >> ~/.ssh/known_hosts
          
          # SSH into the EC2 instance and execute commands
          ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -vvv ubuntu@$EC2_HOST << 'EOF'
            # Ensure Docker is installed and running
            sudo systemctl status docker || sudo systemctl start docker
            
            # Pull the latest images from Docker Hub
            sudo docker pull ${{ secrets.DOCKER_USERNAME }}/wordpress:latest
            sudo docker pull ${{ secrets.DOCKER_USERNAME }}/mysql:5.7
            
            # Stop and remove any existing WordPress and MySQL containers
            sudo docker stop wordpress-container mysql-container || true
            sudo docker rm wordpress-container mysql-container || true
            
            # Run the WordPress container
            sudo docker run -d --name wordpress-container \
              -p 9595:80 \
              -e WORDPRESS_DB_HOST=mysql-container:3306 \
              -e WORDPRESS_DB_USER=root \
              -e WORDPRESS_DB_PASSWORD=password \
              -e WORDPRESS_DB_NAME=wordpress-db \
              ${{ secrets.DOCKER_USERNAME }}/wordpress:latest
            
            # Run the MySQL container with corrected configuration
            sudo docker run -d --name mysql-container \
              -e MYSQL_ROOT_PASSWORD=password \
              -e MYSQL_DATABASE=wordpress-db \
              ${{ secrets.DOCKER_USERNAME }}/mysql:5.7
            
            # Optional: Check the status of the containers
            sudo docker ps
          EOF
2.	GitHub Secrets:
o	EC2_HOST: Your EC2 instance hostname or IP address.
o	EC2_USER: Username for SSH access.
o	EC2_SSH_KEY: Private SSH key for access.
3.	Webhook Configuration:
o	Docker Hub Webhook: Set up a webhook in Docker Hub to notify your deployment process when new images are pushed.
3. Deployment to EC2
1.	Connect to EC2 Instance:
o	SSH Access:
bash
Copy code
ssh -i /path/to/your-key.pem ubuntu@your-ec2-ip
2.	Install Docker and Docker Compose:
bash
Copy code
sudo apt-get update
sudo apt-get install docker.io docker-compose
3.	Deploy Containers:
o	Navigate to Docker Compose Directory:
bash
Copy code
cd /home/ubuntu/docker

4.	Create a Dockerfile Directory for WordPress: On your EC2, create a Dockerfile for the Asset-build setup:
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
5.	Create a Directory for Docker Compose:
bash
Copy code
mkdir ~/docker-wordpress
cd ~/docker-wordpress
6.	Create a docker-compose.yml File:

version: '3'
services:
  asset-builder:
    image: habeeb24/build-assets-project-asset-builder:latest
    # Ensure this image is available and correctly tagged in your Docker registry
    volumes:
      - ./build-assets:/assets  # Adjust according to where your build outputs are
    command: npm run build  # or the appropriate command for your build process

  wordpress:
    image: habeeb24/wordpress:latest
    ports:
      - "9590:80"
    environment:
      WORDPRESS_DB_HOST: mysql:3306
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: wordpress-db
    depends_on:
      - mysql
      - asset-builder  # Ensure WordPress waits for asset build
    volumes:
      - ./build-assets:/var/www/html/wp-content/assets  # Mount the built assets

  mysql:
    image: habeeb24/mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress-db
      MYSQL_USER: root
      MYSQL_PASSWORD: password
    volumes:
      - mysql_data:/var/lib/mysql
volumes:
  mysql_data:
  build-assets:  # Define volume for asset builds

o	Run Docker Compose:
bash
Copy code
sudo docker-compose up --build -d

Directory Structure for Pipeline
Proper directory structure is crucial for ensuring that GitHub Actions and Docker operations locate the correct files and directories. Here's how the directory structure should be organized:
Local Repository Structure:
go
Copy code
your-repo/
│
├── BUILD-ASSETS-PROJECT/
│   ├── Dockerfile
│   └── package.json
│
├── WORDPRESS-PROJECT/
│   └── (WordPress specific files)
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
├── docker-compose.yml
└── .gitignore
•	BUILD-ASSETS-PROJECT/: Contains the Dockerfile and other configuration files for building assets.
•	WORDPRESS-PROJECT/: Contains WordPress-specific files and configurations.
•	.github/workflows/ci-cd.yml: GitHub Actions workflow file.
•	docker-compose.yml: Defines services including WordPress, MySQL, and asset builder.
Remote EC2 Directory Structure:
arduino
Copy code
/home/ubuntu/docker/
│
├── docker-compose.yml
└── (Other files or directories used by Docker Compose)
•	docker-compose.yml: Defines how Docker containers are orchestrated and managed.

Challenges Faced and Solutions
1.	No Space Left on Device:
o	Cause: The EC2 instance ran out of disk space.
o	Solution:
	Clean up unused Docker resources:
bash
Copy code
sudo docker system prune -a --volumes
	Free up additional space:
bash
Copy code
df -h
sudo truncate -s 0 /var/log/syslog
sudo truncate -s 0 /var/log/docker.log
2.	Pull Access Denied:
o	Cause: Issues with Docker image access.
o	Solution:
	Ensure correct Docker credentials:
bash
Copy code
sudo docker login
	Verify the image repository and permissions.
3.	Context Canceled:
o	Cause: Likely related to disk space issues.
o	Solution:
	Resolve disk space problems first to avoid interruptions.
4.	GitHub Actions Workflow Directory Issues:
o	Cause: Workflow files not correctly referencing the Dockerfile or context directory.
o	Solution:
	Ensure the correct relative paths are used in the GitHub Actions workflow:
yaml
Copy code
docker build -t habeeb24/build-assets-project-asset-builder:latest -f BUILD-ASSETS-PROJECT/Dockerfile .










CONCLUSION
Deploying a Dockerized WordPress application with a CI/CD pipeline on EC2 using Docker, Docker Compose, and GitHub Actions creates an efficient, automated, and scalable environment for managing web applications. This comprehensive guide provided a clear plan and roadmap for setting up the deployment process, from initial configuration to continuous integration and deployment, including automated backups and asset building.
Key Takeaways:
1.	Comprehensive CI/CD Pipeline with GitHub Actions: The guide details the creation of a CI/CD pipeline using GitHub Actions that automates the deployment of the WordPress project. The pipeline is designed to trigger on each push to the main branch, ensuring that updates are deployed consistently and without manual intervention. Key steps include building theme assets (SCSS and JS), and deploying the application to the cloud server using methods like Rsync or Git. This setup not only streamlines the deployment process but also reduces errors and improves the speed of updates.
2.	Efficient Asset Building and Deployment: The inclusion of an asset-building service within the Docker Compose setup allows for the automation of compiling SCSS and JavaScript assets, integrating seamlessly into the deployment workflow. This ensures that the latest assets are always deployed with the application, enhancing performance and user experience without additional manual steps.
3.	Automated Backup Solution with Bash Scripting: A crucial part of maintaining the integrity of the WordPress application is the regular backup of the MySQL database. The guide includes a customizable bash script for automating this process, making it easy to schedule and run backups, thereby protecting against data loss and ensuring quick recovery in case of failures. This script can be tailored to specific needs and run on a defined schedule using cron jobs, adding an extra layer of data security.
4.	Scalable and Secure Deployment on AWS EC2: By deploying on AWS EC2 with Docker and Docker Compose, the setup provides a scalable and secure environment capable of handling varying loads and application growth. The use of Nginx as a reverse proxy enhances both security and performance, offering optimized content delivery and robust access management.
5.	Structured Directory Management: Proper directory structure plays a vital role in the effective functioning of GitHub Actions and Docker workflows. The guide emphasizes maintaining a well-organized directory structure both locally and on the EC2 instance, ensuring that all services, configurations, and scripts are easily accessible and manageable. This organization minimizes errors during the deployment and simplifies ongoing maintenance.
6.	Automation of Deployment Using Rsync or Git: The deployment process includes automating file synchronization with Rsync or Git, providing flexibility and efficiency in how updates are deployed to the cloud server. This method ensures that only the necessary changes are pushed, reducing deployment time and minimizing bandwidth usage, which is especially beneficial for larger projects with frequent updates.
7.	Challenges Addressed and Solutions Implemented: The guide provides practical solutions to common challenges such as environment variable management, secure access configurations, and dependency handling. Troubleshooting steps are included to help resolve issues that may arise during the setup, ensuring a smooth and reliable deployment process.
8.	Future Enhancements and Scalability: The current deployment setup is designed with scalability in mind, allowing for future enhancements such as advanced monitoring, auto-scaling, and additional security layers. The modularity of Docker Compose facilitates easy adjustments and scaling, making the deployment adaptable to evolving project requirements.
¬______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
This guide equips you with a detailed plan to deploy a WordPress application using a robust CI/CD pipeline with GitHub Actions, automated backups, and asset management. By following the roadmap provided, you can achieve a fully automated, scalable, and secure deployment setup on AWS EC2, tailored to efficiently handle continuous updates and maintenance. The integration of CI/CD pipelines, asset building, and automated backups sets a strong foundation for ongoing development and operational excellence, ensuring that the WordPress application remains resilient, high-performing, and easy to manage as it grows and evolves.
