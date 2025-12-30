-- Enable team_plan_v1 for the "teacher" workspace with default settings
-- The default team_plan_v1 has: memberLimit=1, but we'll use a reasonable value

-- Update the existing workspace feature to be enabled (type=1)
UPDATE workspace_features
SET type = 1,  -- Enable the feature
    configs = '{}'  -- Use default configs from features table
WHERE workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f'
  AND feature_id = 4;  -- team_plan_v1

-- Verify
SELECT 
  wf.workspace_id,
  f.feature,
  wf.type as enabled,
  f.configs->>'memberLimit' as default_member_limit,
  f.configs->>'storageQuota' as default_storage,
  f.configs->>'seatQuota' as default_seat_quota
FROM workspace_features wf
JOIN features f ON wf.feature_id = f.id
WHERE wf.workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f';
