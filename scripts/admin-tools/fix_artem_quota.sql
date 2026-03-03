-- Fix quota for artem.bmw@affine.com

-- Get user ID
DO $$
DECLARE
    v_user_id VARCHAR;
BEGIN
    SELECT id INTO v_user_id FROM users WHERE email = 'artem.bmw@affine.com';
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User not found';
    END IF;
    
    RAISE NOTICE 'User ID: %', v_user_id;
    
    -- Delete existing user_features for this user to clean up
    DELETE FROM user_features WHERE user_id = v_user_id;
    
    -- Grant free_plan_v1 feature
    INSERT INTO user_features (user_id, feature_id, reason, activated, type, created_at)
    SELECT v_user_id, id, 'manual grant', true, 1, NOW()
    FROM features WHERE feature = 'free_plan_v1';
    
    RAISE NOTICE 'Granted free_plan_v1 to user';
END $$;

-- Verify
SELECT u.email, f.feature, uf.type, uf.activated
FROM user_features uf
JOIN users u ON u.id = uf.user_id
JOIN features f ON f.id = uf.feature_id
WHERE u.email = 'artem.bmw@affine.com';
