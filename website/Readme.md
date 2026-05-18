
- Create a parent directory(e.g `static-website`), were all our files will be
- **Download the wegsite**: `wget https://htmlcodex.com/download/3506`
- **Unzip the file**: `unzip 3506` this will extract the content of zipped folder `3506`. the result is  `fitness-website-template`.
- **Move content**:  move all content (files or folders) from `fitness-website-template` to the parent directory `static-website`
- **Create Dockerfile**: Create a dockerfile `Dockerfile` within the parent directory - `touch Dockerfile`
- **Specify the command** as shown below
```Dockerfile
# Use the official Nginx image as a base
FROM nginx:latest

# Set the working directory to /usr/share/nginx/html
WORKDIR /usr/share/nginx/html

# Copy the static HTML files into the container
COPY . /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Set the default command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]
```
- **Build the image**: Run the command to build the image `docker build -t my-static-website .`
    - note that the dot denotes that the iamge should be build with the dockerfile located in the corect directory
- **Create a container** Run a container from the image built `docker run -d -p 8080:80 my-static-website`
- **view website**: Access it on `http://localhost:8080` on a my device

