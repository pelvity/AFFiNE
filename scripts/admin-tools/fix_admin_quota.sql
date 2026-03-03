-- Fix quota for admin@affine.com

DO $$
DECLARE
    v_user_id VARCHAR;
    v_feature_id INTEGER;
BEGIN
    -- Get admin user ID
    SELECT id INTO v_user_id FROM users WHERE email = 'admin@affine.com';
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Admin user not found';
    END IF;
    
    RAISE NOTICE 'Admin user ID: %', v_user_id;
    
    -- Get lifetime_pro_plan_v1 feature ID
    SELECT id INTO v_feature_id FROM features WHERE feature = 'lifetime_pro_plan_v1';
    
    IF v_feature_id IS NULL THEN
        RAISE EXCEPTION 'lifetime_pro_plan_v1 feature not found';
    END IF;
    
    -- Check existing features
    RAISE NOTICE 'Current features for admin:';
    PERFORM f.feature FROM user_features uf 
    JOIN features f ON f.id = uf.feature_id 
    WHERE uf.user_id = v_user_id;
    
    -- Delete all existing quota features (type = 1) to avoid conflicts
    DELETE FROM user_features 
    WHERE user_id = v_user_id AND type = 1;
    
    -- Grant lifetime_pro_plan_v1 feature (type = 1 for Quota)
    INSERT INTO user_features (user_id, feature_id, reason, activated, type, created_at)
    VALUES (v_user_id, v_feature_id, 'admin grant', true, 1, NOW());
    
    RAISE NOTICE 'Granted lifetime_pro_plan_v1 to admin user';
END $$;

-- Verify all features for admin
SELECT u.email, f.feature, uf.type, uf.activated
FROM user_features uf
JOIN users u ON u.id = uf.user_id
JOIN features f ON f.id = uf.feature_id
WHERE u.email = 'admin@affine.com'
ORDER BY uf.type, f.feature;
