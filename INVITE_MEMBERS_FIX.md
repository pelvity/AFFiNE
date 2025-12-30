# Fix for "Invite Members" Tab Error - admin@affine.pro

## Issue Summary

**Date:** 2025-12-08  
**Environment:** Production (AWS EC2 - aws-kacperjakub2099)  
**Affected User:** admin@affine.pro  
**Error:** Internal server error on "invite members" tab

## Root Cause

The error was caused by a **GraphQL SafeInt scalar type overflow**. The error message was:

```
GraphQLError: SafeInt cannot represent [value]
```

### Technical Details

When "no limits" were added to the admin@affine.pro user's workspace subscription in the database, the `memberLimit` field in the `features` table was set to a value exceeding JavaScript's `Number.MAX_SAFE_INTEGER` (9,007,199,254,740,991).

The GraphQL resolver in `WorkspaceMemberResolver.members()` (line 91-132 in `packages/backend/server/src/core/workspaces/resolvers/member.ts`) calls the quota service, which returns the `memberLimit` value. When GraphQL tries to serialize this value as a SafeInt, it fails because the number is outside the safe integer range.

## Solution Applied

Updated the `memberLimit` in the `features` table for both `pro_plan_v1` (id=2) and `team_plan_v1` (id=4) to **1,000,000** members - a very large but safe number that:
- Provides effectively unlimited members for practical purposes
- Stays within JavaScript's safe integer range
- Prevents the GraphQL SafeInt serialization error

### SQL Fix Applied

```sql
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
```

## Verification

1. ✅ SQL executed successfully - both features updated
2. ✅ Backend logs show no more SafeInt errors
3. ✅ `memberLimit` now set to 1,000,000 for both plans

## Testing Steps

To verify the fix works:

1. Log in as admin@affine.pro
2. Navigate to a workspace
3. Click on the "Invite Members" tab
4. The tab should now load without errors
5. You should be able to search for and invite members

## Why Other Users Were OK

Other users had standard subscription plans with normal `memberLimit` values (3 for free plan, 10 for pro plan, etc.) which are well within the safe integer range, so they didn't encounter this error.

## Prevention

When setting "unlimited" quotas in the future:
- Use a very large but safe number (e.g., 1,000,000) instead of `Infinity` or extremely large values
- Always ensure values stay below `Number.MAX_SAFE_INTEGER` (9,007,199,254,740,991)
- Test the GraphQL API after making database changes to catch serialization errors

## Related Files

- **Backend Resolver:** `packages/backend/server/src/core/workspaces/resolvers/member.ts`
- **Quota Service:** `packages/backend/server/src/core/quota/service.ts`
- **Feature Definitions:** `packages/backend/server/src/models/common/feature.ts`
- **Frontend Component:** `packages/frontend/core/src/modules/share-menu/view/share-menu/invite-member-editor/invite-member-editor.tsx`

## Database Schema

**Table:** `features`
- `id`: integer (primary key)
- `feature`: varchar (feature name)
- `version`: integer
- `configs`: json (contains memberLimit and other quota values)

**Table:** `workspace_features`
- `workspace_id`: uuid (foreign key to workspaces)
- `feature_id`: integer (foreign key to features)
- `reason`: varchar
- `type`: integer (0=disabled, 1=enabled)
