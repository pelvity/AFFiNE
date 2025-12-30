#!/usr/bin/env node

// Script to set password for a user in AFFiNE
// Usage: node set_password.js <email> <password>

const crypto = require('crypto');
const { execSync } = require('child_process');

const email = process.argv[2] || 'artem.math@gmail.com';
const password = process.argv[3] || 'Artem123';

// AFFiNE uses bcrypt with 10 rounds
// We'll use the backend container to hash the password
console.log(`Setting password for ${email}...`);

// First, check if user exists
const checkUserQuery = `SELECT id, email, registered FROM users WHERE email = '${email}';`;
console.log('\nChecking if user exists...');
try {
    const result = execSync(`docker exec affine_postgres_prod psql -U affine -d affine -t -c "${checkUserQuery}"`, { encoding: 'utf-8' });
    console.log('User info:', result.trim());

    if (!result.trim()) {
        console.error('User not found!');
        process.exit(1);
    }
} catch (error) {
    console.error('Error checking user:', error.message);
    process.exit(1);
}

// Generate bcrypt hash using Node.js bcrypt
// We'll use the backend container's Node.js environment
const hashScript = `
const bcrypt = require('bcrypt');
bcrypt.hash('${password}', 10).then(hash => {
  console.log(hash);
}).catch(err => {
  console.error(err);
  process.exit(1);
});
`;

console.log('\nGenerating password hash...');
let passwordHash;
try {
    passwordHash = execSync(`docker exec affine_backend_prod node -e "${hashScript.replace(/\n/g, ' ')}"`, { encoding: 'utf-8' }).trim();
    console.log('Hash generated successfully');
} catch (error) {
    console.error('Error generating hash:', error.message);
    process.exit(1);
}

// Update user password
const updateQuery = `UPDATE users SET password = '${passwordHash}', registered = true WHERE email = '${email}';`;
console.log('\nUpdating password...');
try {
    execSync(`docker exec affine_postgres_prod psql -U affine -d affine -c "${updateQuery}"`, { encoding: 'utf-8' });
    console.log('✅ Password updated successfully!');
    console.log(`\nUser: ${email}`);
    console.log(`Password: ${password}`);
} catch (error) {
    console.error('Error updating password:', error.message);
    process.exit(1);
}
