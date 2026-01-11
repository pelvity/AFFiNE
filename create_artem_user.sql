-- Create user artem.bmw@affine.com with quota

DO $$
DECLARE
    v_user_id VARCHAR;
    v_feature_id INTEGER;
BEGIN
    -- Check if user exists
    SELECT id INTO v_user_id FROM users WHERE email = 'artem.bmw@affine.com';
    
    IF v_user_id IS NOT NULL THEN
        RAISE NOTICE 'User already exists: %', v_user_id;
    ELSE
        -- Create new user
        INSERT INTO users (id, name, email, email_verified, registered, created_at)
        VALUES (
            gen_random_uuid()::text,
            'Artem',
            'artem.bmw@affine.com',
            NOW(),
            true,
            NOW()
        )
        RETURNING id INTO v_user_id;
        
        RAISE NOTICE 'Created new user: %', v_user_id;
    END IF;
    
    -- Get free_plan_v1 feature ID
    SELECT id INTO v_feature_id FROM features WHERE feature = 'free_plan_v1';
    
    IF v_feature_id IS NULL THEN
        RAISE EXCEPTION 'free_plan_v1 feature not found in database';
    END IF;
    
    -- Delete existing features for this user
    DELETE FROM user_features WHERE user_id = v_user_id;
    
    -- Grant free_plan_v1 feature (type = 1 for Quota)
    INSERT INTO user_features (user_id, feature_id, reason, activated, type, created_at)
    VALUES (v_user_id, v_feature_id, 'manual grant', true, 1, NOW());
    
    RAISE NOTICE 'Granted free_plan_v1 (ID: %) to user %', v_feature_id, v_user_id;
END $$;

-- Verify
SELECT u.id, u.email, f.feature, uf.type, uf.activated
FROM users u
LEFT JOIN user_features uf ON uf.user_id = u.id
LEFT JOIN features f ON f.id = uf.feature_id
WHERE u.email = 'artem.bmw@affine.com';
