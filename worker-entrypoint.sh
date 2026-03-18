#!/usr/bin/env bash
set -eo pipefail

echo "++++ Pixelfed Worker starting... ++++"

# Wait for DB to be ready
until php artisan migrate:status > /dev/null 2>&1; do
    echo "Waiting for database..."
    sleep 3
done

# Check if initialized
if [[ ! -e storage/.docker.init ]]; then
    echo "Database is not initialized yet, waiting..."
    sleep 5
    exit 1
fi

# Check for pending migrations
if php artisan migrate:status 2>&1 | grep -qE 'No|Pending'; then
    echo "Database needs migrations, waiting for web container..."
    sleep 5
    exit 1
fi

echo "++++ Starting Horizon... ++++"
exec php artisan horizon
