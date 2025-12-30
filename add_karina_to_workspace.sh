#!/bin/bash
# Add karina_math@gmail.com to teacher workspace

WORKSPACE_ID="d26c28f3-902a-4277-9c97-203ea500fb4f"
EMAIL="karina_math@gmail.com"
ADMIN_ID="d4406d28-1d8b-4143-938e-32baecd6dca5"  # admin@affine.pro

echo "Adding $EMAIL to teacher workspace..."

# Check if user exists, if not create them
echo "Checking if user exists..."
USER_EXISTS=$(docker exec affine_postgres_prod psql -U affine -d affine -t -c "SELECT id FROM users WHERE email = '$EMAIL';")

if [ -z "$USER_EXISTS" ]; then
  echo "Creating new user..."
  docker exec affine_postgres_prod psql -U affine -d affine -c "
    INSERT INTO users (email, name, registered, created_at)
    VALUES ('$EMAIL', 'karina_math', false, NOW())
    RETURNING id, email;
  "
else
  echo "User already exists: $USER_EXISTS"
fi

# Get user ID
USER_ID=$(docker exec affine_postgres_prod psql -U affine -d affine -t -c "SELECT id FROM users WHERE email = '$EMAIL';" | tr -d ' ')

echo "User ID: $USER_ID"

# Check if already a member
EXISTING_MEMBER=$(docker exec affine_postgres_prod psql -U affine -d affine -t -c "
  SELECT id FROM workspace_user_permissions 
  WHERE workspace_id = '$WORKSPACE_ID' AND user_id = '$USER_ID';
")

if [ -z "$EXISTING_MEMBER" ]; then
  echo "Adding user to workspace..."
  docker exec affine_postgres_prod psql -U affine -d affine -c "
    INSERT INTO workspace_user_permissions (workspace_id, user_id, type, status, source, inviter_id, created_at)
    VALUES (
      '$WORKSPACE_ID',
      '$USER_ID',
      'Collaborator',
      'Accepted',  -- Directly approve since no email
      'Email',
      '$ADMIN_ID',
      NOW()
    )
    RETURNING id, user_id, type, status;
  "
  echo "✅ User added successfully!"
else
  echo "User is already a member. Updating status to Accepted..."
  docker exec affine_postgres_prod psql -U affine -d affine -c "
    UPDATE workspace_user_permissions
    SET status = 'Accepted'
    WHERE workspace_id = '$WORKSPACE_ID' AND user_id = '$USER_ID'
    RETURNING id, user_id, type, status;
  "
fi

# Verify
echo ""
echo "=== Current workspace members ==="
docker exec affine_postgres_prod psql -U affine -d affine -c "
  SELECT 
    u.email,
    wup.type as role,
    wup.status,
    wup.created_at
  FROM workspace_user_permissions wup
  JOIN users u ON wup.user_id = u.id
  WHERE wup.workspace_id = '$WORKSPACE_ID'
  ORDER BY wup.created_at;
"
