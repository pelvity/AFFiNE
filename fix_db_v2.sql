DELETE FROM users;

INSERT INTO features (id, feature, version, type, configs, created_at, updated_at) VALUES 
(2, 'administrator', 1, 1, '{}', NOW(), NOW()),
(3, 'early_access', 1, 1, '{}', NOW(), NOW()),
(4, 'pro_plan_v1', 1, 1, '{"quota": {"blobLimit": 107374182400, "storageLimit": 1099511627776, "historyPeriod": 365, "memberLimit": 100}}', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
