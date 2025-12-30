#!/bin/bash
# Set password for artem.math@gmail.com

EMAIL="artem.math@gmail.com"
PASSWORD="Artem123"

echo "Setting password for $EMAIL..."

# Check if user exists
echo "Checking if user exists..."
USER_INFO=$(docker exec affine_postgres_prod psql -U affine -d affine -t -c "SELECT id, email, registered FROM users WHERE email = '$EMAIL';")

if [ -z "$USER_INFO" ]; then
  echo "❌ User not found!"
  exit 1
fi

echo "User found: $USER_INFO"

# Generate bcrypt hash using the backend container
echo "Generating password hash..."
HASH=$(docker exec affine_backend_prod node -e "const bcrypt = require('bcrypt'); bcrypt.hash('$PASSWORD', 10).then(h => console.log(h));")

if [ -z "$HASH" ]; then
  echo "❌ Failed to generate password hash!"
  exit 1
fi

echo "Hash generated: ${HASH:0:20}..."

# Update password in database
echo "Updating password..."
docker exec affine_postgres_prod psql -U affine -d affine -c "UPDATE users SET password = '$HASH', registered = true WHERE email = '$EMAIL';"

echo ""
echo "✅ Password updated successfully!"
echo "Email: $EMAIL"
echo "Password: $PASSWORD"
