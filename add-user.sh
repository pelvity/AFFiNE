#!/bin/bash
# Add user to AFFiNE database

EMAIL="artem.math@affine.com"
PASSWORD="$1"
NAME="Artem Math"

# Generate UUID
USER_ID=$(cat /proc/sys/kernel/random/uuid)

# Hash password using Node.js bcrypt
HASHED_PASSWORD=$(node -e "
const bcrypt = require('bcrypt');
bcrypt.hash('$PASSWORD', 10).then(hash => console.log(hash));
")

# Insert user into database
docker exec affine_postgres_prod psql -U affine -d affine -c "
INSERT INTO users (id, email, name, password, registered, created_at)
VALUES ('$USER_ID', '$EMAIL', '$NAME', '$HASHED_PASSWORD', true, NOW())
ON CONFLICT (email) DO NOTHING;
"

echo "User $EMAIL created with ID: $USER_ID"
