#!/bin/bash

set -e

echo "==> $(date +%H:%M:%S) ==> Starting up environment containers for v1.61.0..."

# Create build directory if it doesn't exist. Clean up the directory if it exists.
BUILD_DIR=../build
rm -rf $BUILD_DIR && mkdir -p $BUILD_DIR

# Download the 'out' of the Safe Wallet Web
git clone --branch v1.61.0 --single-branch https://github.com/nhancv/safe-wallet-web-out.git $BUILD_DIR/ui-build

# Start the environment
docker compose -f ../docker-compose.ui.yml down -v \
  && docker compose -f ../docker-compose.ui.yml pull \
  && docker compose -f ../docker-compose.ui.yml up -d \
  && echo "==> $(date +%H:%M:%S) ==> Creating super-user for Safe Config Service... (may take a while)" \
  && docker compose exec cfg-web python src/manage.py createsuperuser --noinput \
  && echo "==> $(date +%H:%M:%S) ==> Creating super-user for Safe Transaction Service... (may take a while)" \
  && docker compose exec txs-web \
  bash -c "DJANGO_SUPERUSER_USERNAME=root DJANGO_SUPERUSER_EMAIL= DJANGO_SUPERUSER_PASSWORD=admin python manage.py createsuperuser --noinput"

echo "==> $(date +%H:%M:%S) ==> All set! Next steps:
- Your admin user is root/admin
- Add your ChainInfo at http://localhost:8000/cfg/admin/chains/chain/add/
- Add your MasterCopies and ProxyFactories at http://localhost:8000/txs/admin/
- Add your webhooks
- Your web app here http://localhost:8000/
- Read docs/running_locally.md for more information."
