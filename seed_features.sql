-- ============================================
-- AFFiNE Feature Definitions Seed Script
-- ============================================
-- This script seeds all required feature definitions into the features table.
-- Based on FeatureConfigs from packages/backend/server/src/models/common/feature.ts
--
-- Feature Types:
--   0 = Feature (permission/capability)
--   1 = Quota (storage/usage limits)
--
-- Safe to run multiple times (uses ON CONFLICT DO NOTHING)

-- Insert all feature definitions
INSERT INTO features (id, feature, version, type, configs, created_at, updated_at) VALUES 
-- Quota Features (type = 1)
(1, 'free_plan_v1', 4, 1, '{
  "name": "Free",
  "blobLimit": 10485760,
  "businessBlobLimit": 104857600,
  "storageQuota": 10737418240,
  "historyPeriod": 604800000,
  "memberLimit": 3,
  "copilotActionLimit": 10
}', NOW(), NOW()),

(2, 'pro_plan_v1', 2, 1, '{
  "name": "Pro",
  "blobLimit": 104857600,
  "storageQuota": 107374182400,
  "historyPeriod": 2592000000,
  "memberLimit": 10,
  "copilotActionLimit": 10
}', NOW(), NOW()),

(3, 'lifetime_pro_plan_v1', 1, 1, '{
  "name": "Lifetime Pro",
  "blobLimit": 104857600,
  "storageQuota": 1099511627776,
  "historyPeriod": 2592000000,
  "memberLimit": 10,
  "copilotActionLimit": 10
}', NOW(), NOW()),

(4, 'team_plan_v1', 1, 1, '{
  "name": "Team Workspace",
  "blobLimit": 524288000,
  "storageQuota": 107374182400,
  "seatQuota": 21474836480,
  "historyPeriod": 2592000000,
  "memberLimit": 1
}', NOW(), NOW()),

-- Permission Features (type = 0)
(5, 'administrator', 1, 0, '{}', NOW(), NOW()),

(6, 'early_access', 2, 0, '{"whitelist": []}', NOW(), NOW()),

(7, 'ai_early_access', 1, 0, '{}', NOW(), NOW()),

(8, 'unlimited_copilot', 1, 0, '{}', NOW(), NOW()),

(9, 'unlimited_workspace', 1, 0, '{}', NOW(), NOW()),

(10, 'doc_policy_v1', 1, 0, '{
  "defaultWorkspaceMemberDocRole": 30
}', NOW(), NOW())

-- Use ON CONFLICT to make this script idempotent
ON CONFLICT (id) DO NOTHING;

-- Verify the insert
SELECT COUNT(*) as total_features FROM features;
SELECT feature, version, type FROM features ORDER BY id;
