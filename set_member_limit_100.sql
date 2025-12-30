-- Set memberLimit to 100 members (reasonable limit)

UPDATE features
SET configs = json_build_object(
  'name', configs->>'name',
  'blobLimit', (configs->>'blobLimit')::bigint,
  'storageQuota', (configs->>'storageQuota')::bigint,
  'historyPeriod', (configs->>'historyPeriod')::bigint,
  'memberLimit', 100,
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
  'memberLimit', 100,
  'seatQuota', (configs->>'seatQuota')::bigint
)::json
WHERE id = 4;  -- team_plan_v1

-- Verify
SELECT id, feature, configs->>'memberLimit' as member_limit FROM features WHERE id IN (2, 4);
