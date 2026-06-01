-- Upgrade member limit and add user for workspace 7ed50eac-95f3-4c13-a16d-af46ba7dfc7a

DO $$
DECLARE
    v_workspace_id VARCHAR := '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
    v_artem_id VARCHAR := '348beaec-134b-4df8-b7d7-a724f5198f6d';
BEGIN
    -- 1. Increase member limit by adding/updating workspace_features override
    -- name: 'team_plan_v1' is used as the base for workspace-level quota
    -- type: 1 (FeatureType.Quota)
    INSERT INTO workspace_features (workspace_id, name, type, configs, activated, reason, created_at)
    VALUES (
        v_workspace_id,
        'team_plan_v1',
        1,
        jsonb_build_object(
            'name', 'Team Workspace (Unlimited)',
            'blobLimit', 524288000,          -- 500MB
            'storageQuota', 107374182400,    -- 100GB
            'seatQuota', 21474836480,        -- 20GB
            'historyPeriod', 2592000000,    -- 30 days
            'memberLimit', 1000              -- Increased limit
        ),
        true,
        'Manual limit increase for admin',
        NOW()
    )
    ON CONFLICT (workspace_id, name) DO UPDATE 
    SET configs = EXCLUDED.configs, activated = true, reason = EXCLUDED.reason;

    RAISE NOTICE 'Workspace member limit increased to 1000.';

    -- 2. Add artem.romera@affine.com (ID: 348beaec-134b-4df8-b7d7-a724f5198f6d)
    -- type: 1 (Collaborator)
    IF EXISTS (SELECT 1 FROM users WHERE id = v_artem_id) THEN
        INSERT INTO workspace_user_permissions (id, workspace_id, user_id, type, status, accepted, created_at)
        VALUES (
            gen_random_uuid()::text,
            v_workspace_id,
            v_artem_id,
            1, -- WorkspaceRole.Collaborator
            'Accepted', -- WorkspaceMemberStatus.Accepted
            true,
            NOW()
        )
        ON CONFLICT (workspace_id, user_id) DO UPDATE 
        SET type = 1, status = 'Accepted', accepted = true;
        
        RAISE NOTICE 'User artem.romera@affine.com added to workspace.';
    ELSE
        RAISE NOTICE 'User ID 348beaec-134b-4df8-b7d7-a724f5198f6d not found.';
    END IF;
END $$;

-- Verification
SELECT workspace_id, name, configs->>'memberLimit' as limit 
FROM workspace_features 
WHERE workspace_id = '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';

SELECT u.email, wup.type, wup.status, wup.accepted 
FROM workspace_user_permissions wup 
JOIN users u ON u.id = wup.user_id 
WHERE wup.workspace_id = '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
