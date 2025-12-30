#!/bin/bash
# Check workspace_features for admin user's workspace

echo "=== Admin user's workspace features ==="
docker exec affine_postgres_prod psql -U affine -d affine -t -c "
SELECT 
  wf.workspace_id, 
  f.feature, 
  wf.type as enabled,
  wf.configs
FROM workspace_features wf 
JOIN features f ON wf.feature_id = f.id 
WHERE wf.workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f'
ORDER BY f.id;
"

echo ""
echo "=== Check if workspace has custom configs ==="
docker exec affine_postgres_prod psql -U affine -d affine -t -c "
SELECT 
  wf.workspace_id,
  f.feature,
  wf.configs->>'memberLimit' as custom_member_limit,
  f.configs->>'memberLimit' as default_member_limit
FROM workspace_features wf 
JOIN features f ON wf.feature_id = f.id 
WHERE wf.workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f'
  AND wf.configs IS NOT NULL
  AND wf.configs::text != '{}'::text;
"
