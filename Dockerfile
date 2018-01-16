FROM nginx:1.13-alpine
LABEL maintainer="Joel Gilley gilleyj@gmail.com"

# Load ash profile on launch
ENV ENV=/etc/profile
ENV DOCKER_GEN_VERSION 0.7.3
ENV DOCKER_HOST unix:///tmp/docker.sock

# Setup ash profile prompt and my old man alias
# Create work directory
RUN mv /etc/profile.d/color_prompt /etc/profile.d/color_prompt.sh && \
	echo alias dir=\'ls -alh --color\' >> /etc/profile && \
	mkdir -p /app

# Install wget and install/updates certificates
RUN apk add --no-cache --virtual .run-deps \
    ca-certificates bash wget openssl \
    && update-ca-certificates

# Install Forego use RUN & wget so we can leverage caching
# ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN wget https://github.com/jwilder/forego/releases/download/v0.16.1/forego -O /usr/local/bin/forego && \
    chmod u+x /usr/local/bin/forego

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
 tar -C /usr/local/bin -xvzf docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
 rm /docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

# Configure Nginx and apply fix for very long server names
COPY nginx.conf /etc/nginx/nginx.conf

COPY . /app/
WORKDIR /app/

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
