-- Assign pro_plan_v1 to admin@affine.com
INSERT INTO user_features (user_id, feature_id, reason, created_at, activated)
SELECT 
  id, 
  2, -- pro_plan_v1
  'manual fix', 
  NOW(), 
  true 
FROM users 
WHERE email = 'admin@affine.com'
AND NOT EXISTS (SELECT 1 FROM user_features WHERE user_id = users.id AND feature_id = 2);
