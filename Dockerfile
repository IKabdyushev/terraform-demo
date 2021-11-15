# Dockerfile

# inherit from this "empty base image", see https://hub.docker.com/_/python/
FROM python:3.9-alpine

# take some responsibility for this container
MAINTAINER Andrey Shkulipa DO1821

# create working directory
RUN mkdir -p /usr/src/app/

# directory to install the app inside the container
WORKDIR /usr/src/app/

# copy application source code into container vs install python dependencies, this will be cached if the requirements.txt file does not change
COPY . /usr/src/app/
RUN pip install --no-cache-dir -r requirements.txt

# expose this TCP-port
EXPOSE 8080

# run this command at run-time
CMD [ "python", "app.py"  ]
