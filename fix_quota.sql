-- Add default quota configuration
INSERT INTO app_configs (id, value, created_at, updated_at)
VALUES (
  'quota',
  '{
    "user": {
      "blobLimit": 10737418240,
      "storageQuota": 10737418240,
      "historyPeriod": 30,
      "memberLimit": 10,
      "copilotActionLimit": 100
    },
    "workspace": {
      "blobLimit": 10737418240,
      "storageQuota": 10737418240,
      "historyPeriod": 30,
      "memberLimit": 10,
      "copilotActionLimit": 100
    }
  }',
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET value = EXCLUDED.value;
