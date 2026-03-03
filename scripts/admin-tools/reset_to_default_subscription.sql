-- Clean up and set workspace to default Team Plan (best subscription)
-- Remove all custom workspace features and use the default team_plan_v1

-- 1. Remove ALL custom workspace features
DELETE FROM workspace_features 
WHERE workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f';

-- 2. Add ONLY the default team_plan_v1 (no custom configs)
INSERT INTO workspace_features (workspace_id, feature_id, name, type, activated, reason, configs)
VALUES (
  'd26c28f3-902a-4277-9c97-203ea500fb4f',
  4,  -- team_plan_v1
  'team_plan_v1',
  0,  -- FeatureType.Quota
  true,
  'default_setup',
  '{}'  -- Empty config = use defaults from features table
);

-- 3. Verify the setup
SELECT 
  wf.workspace_id,
  f.feature,
  wf.type as enabled,
  wf.configs as custom_configs,
  f.configs as default_configs
FROM workspace_features wf
JOIN features f ON wf.feature_id = f.id
WHERE wf.workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f';
