-- Fix the memberLimit to a more reasonable value
-- 10,000 members is still effectively unlimited but won't cause overflow
-- when multiplied with seatQuota

UPDATE features
SET configs = json_build_object(
  'name', configs->>'name',
  'blobLimit', (configs->>'blobLimit')::bigint,
  'storageQuota', (configs->>'storageQuota')::bigint,
  'historyPeriod', (configs->>'historyPeriod')::bigint,
  'memberLimit', 10000,
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
  'memberLimit', 10000,
  'seatQuota', (configs->>'seatQuota')::bigint
)::json
WHERE id = 4;  -- team_plan_v1

-- Verify the change
SELECT id, feature, configs->>'memberLimit' as member_limit, 
       (configs->>'seatQuota')::bigint * (configs->>'memberLimit')::bigint as calculated_storage
FROM features
WHERE id IN (2, 4);
