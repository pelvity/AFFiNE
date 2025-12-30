-- Manually approve artem.math@gmail.com and set status to Accepted
-- Since email notifications are not configured, we'll directly accept the user

UPDATE workspace_user_permissions
SET status = 'Accepted'
WHERE user_id = (SELECT id FROM users WHERE email = 'artem.math@gmail.com')
  AND workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f';

-- Verify the update
SELECT 
  u.email,
  wup.status,
  wup.type as role,
  wup.created_at
FROM workspace_user_permissions wup
JOIN users u ON wup.user_id = u.id
WHERE u.email = 'artem.math@gmail.com'
  AND wup.workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f';
