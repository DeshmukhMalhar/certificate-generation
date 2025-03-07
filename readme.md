# SSL Certificate Generator

This project automates the generation of **wildcard** SSL certificates using OpenSSL inside a Docker container. The certificates are stored in a volume-mounted `certificates` directory, organized by domain name.

## Instructions

### 1. Update the Domain File

Edit the `domain` file in the project root and add the domain name for which you need a certificate.

It shall not be `*.example.com` this automatically generates wildcard vertificate for `*.example.com`

Specify the base domain only

> eg: `example.com` , `subdomain.example.com`

```bash
echo "example.com" > domain
```

### 2. Set Environment Variables

You can set environment variables manually or use a `.env` file.

#### **Option 1: Set Environment Variables Manually**

```bash
export VALIDITY=730  # Set validity in days (2 years)
export PASSWORD="your-secure-password"
```

#### **Option 2: Use a `.env` File**

Create a file named `.env` in the project root and add the variables:

```
VALIDITY=730
PASSWORD=your-secure-password
```

The `.env` file will be automatically loaded by Docker Compose.

### 3. Build and Run the Container

Use the following command to build and run the container:

```bash
docker compose up --build
```

### 4. Locate the Generated Certificates

Once the container completes execution, the certificates will be available in the `certificates` folder inside a subdirectory named after the specified domain:

```plaintext
certificates/
 ├── example.com/
 │   ├── domain.crt   # Public certificate
 │   ├── domain.key   # Private key
 │   ├── domain.pfx   # PKCS#12 format (includes key & cert)
```

## Configuration

The OpenSSL configuration file `openssl.cnf` is used to generate the certificates. If needed, modify it to customize certificate attributes.

## Cleanup

To remove the generated certificates, stop the container and delete the `certificates` directory:

```bash
docker compose down
rm -rf certificates/
```

## Notes

- The container will exit automatically after generating the certificates.
- Ensure the `domain` file is not empty; otherwise, certificate generation will fail.
- The `VALIDITY` environment variable controls the certificate validity period (defaults to **365 days**).
- The `.pfx` file contains both the private key and the certificate. If `PASSWORD` is set, it will be required when importing the `.pfx`.
- All environment variables can be set manually or via a `.env` file for convenience.
