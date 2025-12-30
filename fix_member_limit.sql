-- Fix the memberLimit for admin@affine.pro's workspace
-- Set it to a very large but safe number (1 million members)

UPDATE features
SET configs = json_build_object(
  'name', configs->>'name',
  'blobLimit', (configs->>'blobLimit')::bigint,
  'storageQuota', (configs->>'storageQuota')::bigint,
  'historyPeriod', (configs->>'historyPeriod')::bigint,
  'memberLimit', 1000000,
  'copilotActionLimit', COALESCE((configs->>'copilotActionLimit')::int, NULL),
  'seatQuota', COALESCE((configs->>'seatQuota')::bigint, NULL)
)::json
WHERE id = 2;  -- pro_plan_v1

UPDATE features
SET configs = json_build_object(
  'name', configs->>'name',
  'blobLimit', (configs->>'blobLimit')::bigint,
  'storageQuota', (configs->>'storageQuota')::bigint,
  'historyPeriod', (configs->>'historyPeriod')::bigint,
  'memberLimit', 1000000,
  'seatQuota', (configs->>'seatQuota')::bigint
)::json
WHERE id = 4;  -- team_plan_v1

-- Verify the change
SELECT id, feature, configs->>'memberLimit' as member_limit, configs
FROM features
WHERE id IN (2, 4);
