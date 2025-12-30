#!/bin/bash
# Check the current memberLimit values and workspace features

echo "=== Checking features table ==="
docker exec affine_postgres_prod psql -U affine -d affine -t -c "SELECT id, feature, configs FROM features WHERE id IN (2, 4);"

echo ""
echo "=== Checking workspace_features for admin user ==="
docker exec affine_postgres_prod psql -U affine -d affine -t -c "SELECT wf.workspace_id, wf.feature_id, wf.type, f.feature FROM workspace_features wf JOIN features f ON wf.feature_id = f.id WHERE wf.workspace_id = 'd26c28f3-902a-4277-9c97-203ea500fb4f';"

echo ""
echo "=== Checking recent backend errors ==="
docker logs affine_backend_prod --tail 100 2>&1 | grep -i "safeint\|error" | tail -20
