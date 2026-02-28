#!/bin/bash

set -o errexit # terminate on error

SERVER="localhost:5000"  # docker registry endpoint
CLIENT="localhost:5050"  # user interface endpoint


running() { # returns 1 (true) if container is running, 0 (false) otherwise
    [ "$(docker inspect --format '{{.State.Running}}' "$1" 2>/dev/null)" == "true" ]
}

echo "========== REGISTRY =========="

# Start Registry Server
if ! running registry-server; then
    echo "Starting registry server..."

    docker run --publish 5000:5000 --restart=always --detach \
        --volume .data/registry:/var/lib/registry \
        --env REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin="[http://$CLIENT]" \
        --env REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods="[HEAD,GET,OPTIONS,DELETE,PUT,POST]" \
        --env REGISTRY_HTTP_HEADERS_Access-Control-Allow-Headers="[Authorization,Accept,Cache-Control,Content-Type]" \
        --env REGISTRY_HTTP_HEADERS_Access-Control-Expose-Headers="[Docker-Content-Digest]" \
        --env REGISTRY_HTTP_HEADERS_Access-Control-Allow-Credentials="[true]" \
        --env REGISTRY_STORAGE_DELETE_ENABLED="true" \
        --name registry-server docker.io/registry:latest

    echo "Registry server started at $SERVER"
else
    echo "Registry server is already running at $SERVER"
fi

# Start Registry Client
if ! running registry-client; then
    echo "Starting registry client..."

    docker run --publish 5050:80 --restart=always --detach \
        --env REGISTRY_URL="http://$SERVER" \
        --env DELETE_IMAGES="true" \
        --name registry-client docker.io/joxit/docker-registry-ui:latest

    echo "Registry client started at $CLIENT"
else
    echo "Registry client is already running at $CLIENT"
fi

echo "========== STORAGE =========="

# Database Operator
docker pull ghcr.io/cloudnative-pg/cloudnative-pg:1.28.0
docker tag ghcr.io/cloudnative-pg/cloudnative-pg:1.28.0 $SERVER/database-operator:latest
docker push $SERVER/database-operator:latest

# Database Tenant
docker pull ghcr.io/cloudnative-pg/postgresql:18-standard-trixie # pgvector, pgaudit, failover slots
docker tag ghcr.io/cloudnative-pg/postgresql:18-standard-trixie $SERVER/database-tenant:latest
docker push $SERVER/database-tenant:latest

# Database Admin
docker pull dpage/pgadmin4:9.11
docker tag dpage/pgadmin4:9.11 $SERVER/database-admin:latest
docker push $SERVER/database-admin:latest

# Object Storage
docker pull quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z
docker tag quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z $SERVER/object-storage:latest
docker push $SERVER/object-storage:latest

echo "========== APPLICATION =========="

# Website with Libraries
# docker build --target libs --tag $SERVER/website:latest ../website
# docker push $SERVER/website:latest

# Frontend with Libraries
docker build --target libs --tag $SERVER/frontend:latest ../frontend
docker push $SERVER/frontend:latest

# Backend with Libraries
# docker build --target libs --tag $SERVER/backend:latest ../backend
# docker push $SERVER/backend:latest

echo "========== WORKFLOW =========="

echo "Done!"