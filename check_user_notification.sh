#!/bin/bash
# Check artem.math@gmail.com user status and notification settings

echo "=== User Information ==="
docker exec affine_postgres_prod psql -U affine -d affine -c "
SELECT 
  id, 
  email, 
  name, 
  registered, 
  email_verified,
  created_at
FROM users 
WHERE email = 'artem.math@gmail.com';
"

echo ""
echo "=== Workspace Membership ==="
docker exec affine_postgres_prod psql -U affine -d affine -c "
SELECT 
  wup.id as invite_id,
  wup.workspace_id,
  wup.user_id,
  wup.type as role,
  wup.status,
  wup.inviter_id,
  wup.created_at
FROM workspace_user_permissions wup
JOIN users u ON wup.user_id = u.id
WHERE u.email = 'artem.math@gmail.com';
"

echo ""
echo "=== Check Email Configuration ==="
docker exec affine_backend_prod printenv | grep -i "mail\|smtp\|email" || echo "No email configuration found"

echo ""
echo "=== Recent Backend Logs (email/notification) ==="
docker logs affine_backend_prod --since 10m 2>&1 | grep -i "mail\|notification\|invite" | tail -20 || echo "No email/notification logs found"
