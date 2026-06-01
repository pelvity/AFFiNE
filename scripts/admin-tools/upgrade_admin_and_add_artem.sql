-- Upgrade member limit for admin plans and add artem.romera@affine.com to workspace
-- Target Workspace: 7ed50eac-95f3-4c13-a16d-af46ba7dfc7a

DO $$
DECLARE
    v_user_id VARCHAR;
    v_workspace_id VARCHAR := '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
    v_target_email VARCHAR := 'artem.romera@affine.com';
BEGIN
    -- 1. Increase member limit for Pro and Team plans
    -- Setting to 1000 (generous but safe)
    UPDATE features
    SET configs = (
        SELECT jsonb_set(configs::jsonb, '{memberLimit}', '1000'::jsonb)::json
    )
    WHERE feature IN ('pro_plan_v1', 'lifetime_pro_plan_v1', 'team_plan_v1');
    
    RAISE NOTICE 'Increased memberLimit to 1000 for relevant plans.';

    -- 2. Add artem.romera@affine.com to the workspace
    SELECT id INTO v_user_id FROM users WHERE email = v_target_email;
    
    IF v_user_id IS NULL THEN
        RAISE NOTICE 'User % not found. Please ensure they have signed up first.', v_target_email;
    ELSE
        IF EXISTS (
            SELECT 1 FROM workspace_user_permissions 
            WHERE workspace_id = v_workspace_id AND user_id = v_user_id
        ) THEN
            RAISE NOTICE 'User % is already a member of workspace %', v_target_email, v_workspace_id;
        ELSE
            -- Add user as Owner (type 99) to match user request if implied, or regular member (type 0)
            -- Using 99 (Owner) as seen in other admin scripts for manual additions
            INSERT INTO workspace_user_permissions (id, workspace_id, user_id, type, accepted, created_at)
            VALUES (gen_random_uuid()::text, v_workspace_id, v_user_id, 99, true, NOW());
            
            RAISE NOTICE 'User % added to workspace % with Owner permissions', v_target_email, v_workspace_id;
        END IF;
    END IF;
END $$;

-- Verification
SELECT f.feature, f.configs->>'memberLimit' as member_limit
FROM features f
WHERE f.feature IN ('pro_plan_v1', 'lifetime_pro_plan_v1', 'team_plan_v1');

SELECT u.email, u.name, wup.type, wup.accepted
FROM workspace_user_permissions wup
JOIN users u ON u.id = wup.user_id
WHERE wup.workspace_id = '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a' 
AND u.email = 'artem.romera@affine.com';
