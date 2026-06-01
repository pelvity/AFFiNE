DO $$
DECLARE
    v_workspace_id VARCHAR := '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
    v_artem_id VARCHAR := '348beaec-134b-4df8-b7d7-a724f5198f6d';
BEGIN
    INSERT INTO workspace_features (workspace_id, name, type, configs, activated, reason, created_at)
    VALUES (
        v_workspace_id,
        'team_plan_v1',
        1,
        jsonb_build_object(
            'name', 'Team Workspace (Unlimited)',
            'blobLimit', 524288000,
            'storageQuota', 107374182400,
            'seatQuota', 21474836480,
            'historyPeriod', 2592000000,
            'memberLimit', 1000
        ),
        true,
        'Manual limit increase',
        NOW()
    )
    ON CONFLICT (workspace_id, name) DO UPDATE 
    SET configs = EXCLUDED.configs, activated = true, reason = EXCLUDED.reason;

    INSERT INTO workspace_user_permissions (id, workspace_id, user_id, type, status, created_at)
    VALUES (
        gen_random_uuid()::text,
        v_workspace_id,
        v_artem_id,
        1,
        'Accepted',
        NOW()
    )
    ON CONFLICT (workspace_id, user_id) DO UPDATE 
    SET type = 1, status = 'Accepted';
END $$;

SELECT workspace_id, name, configs->>'memberLimit' as limit FROM workspace_features WHERE workspace_id = '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
SELECT u.email, wup.type, wup.status FROM workspace_user_permissions wup JOIN users u ON u.id = wup.user_id WHERE wup.workspace_id = '7ed50eac-95f3-4c13-a16d-af46ba7dfc7a';
