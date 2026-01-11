-- Assign free plan to artem.math@affine.com
INSERT INTO user_features (id, user_id, feature_id, reason, created_at, activated)
SELECT 
  gen_random_uuid(), 
  id, 
  1, -- free_plan_v1
  'manual fix', 
  NOW(), 
  true 
FROM users 
WHERE email = 'artem.math@affine.com'
AND NOT EXISTS (SELECT 1 FROM user_features WHERE user_id = users.id);
