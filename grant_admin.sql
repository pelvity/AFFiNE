-- Grant Admin Privileges
-- User ID: 919e5fde-d2e2-4022-9801-8f1f6bbbc5fd (admin@affine.com)

-- 1. Remove existing features to ensure clean state (e.g. remove free plan)
DELETE FROM user_features WHERE user_id = '919e5fde-d2e2-4022-9801-8f1f6bbbc5fd';

-- 2. Insert new features
INSERT INTO user_features (user_id, feature_id, reason, activated, type) VALUES
-- Quota: Lifetime Pro (ID 3)
('919e5fde-d2e2-4022-9801-8f1f6bbbc5fd', 3, 'admin grant', true, 1),

-- Feature: Administrator (ID 5)
('919e5fde-d2e2-4022-9801-8f1f6bbbc5fd', 5, 'admin grant', true, 0),

-- Feature: Early Access (ID 6)
('919e5fde-d2e2-4022-9801-8f1f6bbbc5fd', 6, 'admin grant', true, 0),

-- Feature: AI Early Access (ID 7)
('919e5fde-d2e2-4022-9801-8f1f6bbbc5fd', 7, 'admin grant', true, 0),

-- Feature: Unlimited Copilot (ID 8)
('919e5fde-d2e2-4022-9801-8f1f6bbbc5fd', 8, 'admin grant', true, 0),

-- Feature: Unlimited Workspace (ID 9)
('919e5fde-d2e2-4022-9801-8f1f6bbbc5fd', 9, 'admin grant', true, 0);

-- Verify
SELECT u.email, f.feature, uf.type 
FROM user_features uf
JOIN users u ON u.id = uf.user_id
JOIN features f ON f.id = uf.feature_id
WHERE u.id = '919e5fde-d2e2-4022-9801-8f1f6bbbc5fd';
