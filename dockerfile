FROM alpine:latest

# Install OpenSSL
RUN apk add --no-cache openssl

# Set work directory
WORKDIR /

# Copy script and OpenSSL config into container
COPY entrypoint.sh /entrypoint.sh
COPY openssl.cnf /etc/ssl/openssl.cnf

# Make script executable
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
