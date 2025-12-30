-- Set password for artem.math@gmail.com
-- Password: Artem123

-- First, let's check if the user exists
SELECT id, email, name, registered FROM users WHERE email = 'artem.math@gmail.com';

-- Update the user to set password
-- Note: AFFiNE uses bcrypt hashing for passwords
-- We'll need to generate the hash using the backend's password hashing

-- For now, let's just verify the user exists and is registered
-- We'll use a Node.js script to properly hash the password
