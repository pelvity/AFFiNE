-- Grant administrator feature (id 5) to admin@affine.com and the specific user
INSERT INTO user_features (user_id, feature_id, reason, activated, name, type) 
SELECT id, 5, 'manual grant v2', true, 'administrator', 0 FROM users WHERE email IN ('admin@affine.com', 'test@affine.com', 'artembvw@gmail.com')
ON CONFLICT DO NOTHING;
