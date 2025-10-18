#!/bin/bash

script_dir=$(dirname $0)
haproxy_certs_dir=${script_dir}/haproxy/certs
mkdir -p $haproxy_certs_dir

if [ ! -f "${haproxy_certs_dir}/haproxy.pem.key" ]; then
    openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
      -keyout "${haproxy_certs_dir}/haproxy.pem.key" -out "${haproxy_certs_dir}/haproxy.pem" -extensions san -config \
      <(echo "[req]";
        echo distinguished_name=req;
        echo "[san]";
        echo subjectAltName=DNS:localhost,DNS:127.0.0.1.nip.io,IP:127.0.0.1
        ) \
      -subj /CN=devhost
    chmod 755 $haproxy_certs_dir
    chmod 644 ${haproxy_certs_dir}/*
fi

down="$1"
if [ "$down" != "" ]; then
    docker compose down
else
    docker compose up -d --build --force-recreate || exit 1
    docker compose logs -f
fi
