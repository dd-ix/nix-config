#!/usr/bin/env bash

dir=$(mktemp -d)

openssl ecparam -name secp384r1 -genkey -noout -out "$dir/ec384.key"
openssl req -new -key "$dir/ec384.key" -out "$dir/ec384.csr" \
  -subj "/C=DE/ST=SN/L=DD/O=DD-IX Dresden Internet Exchange e.V./OU=IT/CN=svc-log01.dd-ix.net"
openssl x509 -req -in "$dir/ec384.csr" -signkey "$dir/ec384.key" -out "$dir/ec384.crt" -days 3650
cat "$dir/ec384.crt" "$dir/ec384.key" > "$dir/ec384-combined.pem"

echo ""
echo "Generated cert to $dir"
ls -la "$dir"
