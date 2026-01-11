-- Create user artem.bmw@affine.com and add to workspace

DO $$
DECLARE
    v_user_id VARCHAR;
    v_workspace_id VARCHAR := '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
BEGIN
    -- Check if user exists
    SELECT id INTO v_user_id FROM users WHERE email = 'artem.bmw@affine.com';
    
    IF v_user_id IS NULL THEN
        -- Create new user
        INSERT INTO users (id, name, email, email_verified, registered, created_at)
        VALUES (
            gen_random_uuid()::text,
            'Artem',
            'artem.bmw@affine.com',
            NOW(),  -- email_verified is a timestamp
            true,
            NOW()
        )
        RETURNING id INTO v_user_id;
        
        RAISE NOTICE 'Created new user: %', v_user_id;
        
        -- Grant free plan to new user
        INSERT INTO user_features (user_id, feature_id, reason, activated, created_at)
        SELECT v_user_id, id, 'auto-grant on signup', true, NOW()
        FROM features WHERE feature = 'free_plan_v1';
    END IF;
    
    -- Check if user is already a member
    IF EXISTS (
        SELECT 1 FROM workspace_user_permissions 
        WHERE workspace_id = v_workspace_id AND user_id = v_user_id
    ) THEN
        RAISE NOTICE 'User is already a member of this workspace';
    ELSE
        -- Add user to workspace with Owner permission (type = 99)
        INSERT INTO workspace_user_permissions (workspace_id, user_id, type, accepted, created_at)
        VALUES (v_workspace_id, v_user_id, 99, true, NOW());
        
        RAISE NOTICE 'User % added to workspace with Owner permissions', v_user_id;
    END IF;
END $$;

-- Verify the addition
SELECT u.email, u.name, wup.type, wup.accepted
FROM workspace_user_permissions wup
JOIN users u ON u.id = wup.user_id
WHERE wup.workspace_id = '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
