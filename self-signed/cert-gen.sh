#!/bin/bash
# PARAMETERS
CA_CN="ca.local"
CA_KEYPASSWORD="changeme"
CA_DAYS=3650
CA_COUNTRY="UK"
CA_STATE="South Yorks"
CA_LOCATION="Doncaster"
CA_ORG="Local CA"
CA_UNIT="CA dept"
CA_EMAIL="noreply@ca.local"

CERT_CN="www.exampleforyou.net"
CERT_ALT_NAME="*.exampleforyou.net"
CERT_KEYPASSWORD="changeme"
CERT_DAYS=3650
CERT_COUNTRY="UK"
CERT_STATE="South Yorks"
CERT_LOCATION="Doncaster"
CERT_ORG="Exampleforyou"
CERT_UNIT="Developers"
CERT_EMAIL="noreply@exampleforyou.net"

# Create ext file
/bin/cat > "$CERT_CN.ext" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
C=$CERT_COUNTRY
ST=$CERT_STATE
L=$CERT_LOCATION
O=$CERT_ORG
OU=$CERT_UNIT
CN=$CERT_CN

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1=$CERT_CN
DNS.2=$CERT_ALT_NAME
EOF

# CA Cert
# Create private key for local CA
/usr/bin/openssl genrsa -des3 -out local_ca.key -passout pass:"$CA_KEYPASSWORD" 2048

# Create root certificate
/usr/bin/openssl req -x509 -new -nodes -key local_ca.key -sha256 -days "$CA_DAYS" -passin pass:"$CA_KEYPASSWORD" -subj "/C=$CA_COUNTRY/ST=$CA_STATE/L=$CA_LOCATION/O=$CA_ORG/OU=$CA_UNIT/CN=$CA_CN/emailAddress=$CA_EMAIL" -out local_ca.pem

# Certificate
# Create prevate key for host
/usr/bin/openssl genrsa -des3 -out "$CERT_CN.key" -passout pass:"$CERT_KEYPASSWORD" 2048

# Generate Certificate Signing Request
/usr/bin/openssl req -new -key "$CERT_CN.key" -out "$CERT_CN.csr" -passin pass:"$CERT_KEYPASSWORD" -days $CERT_DAYS -subj "/C=$CERT_COUNTRY/ST=$CERT_STATE/L=$CERT_LOCATION/O=$CERT_ORG/OU=$CERT_UNIT/CN=$CERT_CN/emailAddress=$CERT_EMAIL"

# Create Certificate
openssl x509 -req -in "$CERT_CN.csr" -CA local_ca.pem -CAkey local_ca.key -CAcreateserial -passin pass:"$CA_KEYPASSWORD" -out "$CERT_CN.pem" -days "$CERT_DAYS" -sha256 -extfile "$CERT_CN.ext"

