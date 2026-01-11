-- Create user dmytro.math@affine.com and add to workspace
-- Workspace ID: 7ed50eac-95f3-4c13-a16d-af46ba7dfc7a

DO $$
DECLARE
    v_user_id VARCHAR;
    v_workspace_id VARCHAR := '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
    v_new_user_email VARCHAR := 'dmytro.math@affine.com';
    v_new_user_name VARCHAR := 'Dmytro';
BEGIN
    -- 1. Ensure Workspace Exists (Should exist from previous step, but keep for robustness)
    IF NOT EXISTS (SELECT 1 FROM workspaces WHERE id = v_workspace_id) THEN
        RAISE NOTICE 'Workspace % not found. Creating it...', v_workspace_id;
        INSERT INTO workspaces (
            id, 
            public, 
            created_at,
            indexed,
            last_check_embeddings,
            enable_url_preview,
            enable_ai,
            enable_doc_embedding
        ) VALUES (
            v_workspace_id,
            false, 
            NOW(),
            false,
            NOW(),
            true,
            true,
            true
        );
        RAISE NOTICE 'Workspace created.';
    ELSE
        RAISE NOTICE 'Workspace % exists.', v_workspace_id;
    END IF;

    -- 2. Ensure User Exists
    SELECT id INTO v_user_id FROM users WHERE email = v_new_user_email;
    
    IF v_user_id IS NULL THEN
        -- Create new user
        INSERT INTO users (id, name, email, email_verified, registered, created_at)
        VALUES (
            gen_random_uuid()::text,
            v_new_user_name,
            v_new_user_email,
            NOW(),
            true,
            NOW()
        )
        RETURNING id INTO v_user_id;
        
        RAISE NOTICE 'Created new user: % (ID: %)', v_new_user_email, v_user_id;
        
        -- Grant free plan
        INSERT INTO user_features (user_id, feature_id, reason, activated, created_at)
        SELECT v_user_id, id, 'auto-grant on signup', true, NOW()
        FROM features WHERE feature = 'free_plan_v1';
    ELSE
         RAISE NOTICE 'User % already exists with ID: %', v_new_user_email, v_user_id;
    END IF;
    
    -- 3. Add User to Workspace
    IF EXISTS (
        SELECT 1 FROM workspace_user_permissions 
        WHERE workspace_id = v_workspace_id AND user_id = v_user_id
    ) THEN
        RAISE NOTICE 'User is already a member of this workspace';
    ELSE
        INSERT INTO workspace_user_permissions (id, workspace_id, user_id, type, accepted, created_at)
        VALUES (gen_random_uuid()::text, v_workspace_id, v_user_id, 99, true, NOW());
        
        RAISE NOTICE 'User % added to workspace with Owner permissions', v_user_id;
    END IF;
END $$;

-- Verify
SELECT u.email, u.name, wup.type, wup.accepted, w.id as workspace_id
FROM workspace_user_permissions wup
JOIN users u ON u.id = wup.user_id
JOIN workspaces w ON w.id = wup.workspace_id
WHERE wup.workspace_id = '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a' AND u.email = 'dmytro.math@affine.com';
