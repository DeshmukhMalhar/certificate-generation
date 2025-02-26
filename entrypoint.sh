#!/bin/sh

# Define paths
DOMAIN_FILE="/domain"  # File containing the domain name
CERTS_DIR="/certificates"  # Mounted volume path
OPENSSL_CNF="/etc/ssl/openssl.cnf"  # OpenSSL config file
# Set certificate validity in days if not already set in the environment
VALIDITY=${VALIDITY:-365}

# Read domain name from file
if [ ! -f "$DOMAIN_FILE" ]; then
    echo "Error: Domain file not found at $DOMAIN_FILE!"
    exit 1
fi

DOMAIN=$(cat "$DOMAIN_FILE" | tr -d '[:space:]')

# Validate domain is not empty
if [ -z "$DOMAIN" ]; then
    echo "Error: Domain name is empty!"
    exit 1
fi

# Ensure OpenSSL config file exists
if [ ! -f "$OPENSSL_CNF" ]; then
    echo "Error: OpenSSL config file not found at $OPENSSL_CNF!"
    exit 1
fi

cp /etc/ssl/openssl.cnf /tmp/openssl.cnf
sed -i "s/DEFAULT_DOMAIN/$DOMAIN/g" /tmp/openssl.cnf

# Replace placeholder in OpenSSL config
# sed -i "s/DEFAULT_DOMAIN/$DOMAIN/g" "$OPENSSL_CNF"
cat /tmp/openssl.cnf

# Create directory for storing certificates
DOMAIN_PATH="$CERTS_DIR/$DOMAIN"
mkdir -p "$DOMAIN_PATH"

echo "Generating SSL certificates for $DOMAIN using $OPENSSL_CNF..."

# Generate private key and certificate using OpenSSL config
openssl req -x509 -nodes -days $VALIDITY \
    -newkey rsa:2048 \
    -keyout "/certificates/$DOMAIN/$DOMAIN.key" \
    -out "/certificates/$DOMAIN/$DOMAIN.crt" \
    -config /tmp/openssl.cnf

# Convert to PFX format (for Windows/IIS compatibility)
openssl pkcs12 -export -out "$DOMAIN_PATH/$DOMAIN.pfx" \
    -inkey "$DOMAIN_PATH/$DOMAIN.key" \
    -in "$DOMAIN_PATH/$DOMAIN.crt" \
	-passout pass:${PASSWORD:-}   # Empty password if PASSWORD environment variable is not set

echo "Certificates generated in: $DOMAIN_PATH"

# Keep container running for debugging (optional)
# exec tail -f /dev/null
