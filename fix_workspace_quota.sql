-- Remove pro_plan_v1 from the workspace and keep only team_plan_v1
-- This will prevent the NaN error since team_plan_v1 has seatQuota

-- First, let's see what we have
SELECT wf.id, wf.workspace_id, f.feature, wf.type, wf.created_at
FROM workspace_features wf 
JOIN features f ON wf.feature_id = f.id 
WHERE wf.workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f'
  AND f.feature IN ('pro_plan_v1', 'team_plan_v1')
ORDER BY wf.created_at;

-- Delete pro_plan_v1 from this workspace
DELETE FROM workspace_features
WHERE workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f'
  AND feature_id = 2;  -- pro_plan_v1

-- Verify only team_plan_v1 remains
SELECT wf.id, wf.workspace_id, f.feature, wf.type, wf.created_at
FROM workspace_features wf 
JOIN features f ON wf.feature_id = f.id 
WHERE wf.workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f'
  AND wf.type = 1
ORDER BY wf.created_at;
