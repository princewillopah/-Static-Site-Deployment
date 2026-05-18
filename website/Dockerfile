FROM nginx:latest

# Set the working directory to /usr/share/nginx/html
WORKDIR /usr/share/nginx/html

# Copy the static HTML files into the container
COPY . /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Set the default command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]