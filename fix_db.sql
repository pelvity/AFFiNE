INSERT INTO features (id, feature, version, type, configs, created_at, updated_at) 
VALUES (1, 'free_plan_v1', 1, 1, '{"quota": {"blobLimit": 10485760000, "storageLimit": 10737418240, "historyPeriod": 30, "memberLimit": 10}}', NOW(), NOW());

DELETE FROM users;
