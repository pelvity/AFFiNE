/**
 * Script to create a student account in AFFiNE
 * Usage: node create-student-account.js
 */

const http = require('http');

// Student account details
const STUDENT_EMAIL = 'dmytro.dmtxer@example.com';
const STUDENT_NAME = 'Dmytro Dmtxer';
const STUDENT_PASSWORD = 'dmytro2024Secure!';

// GraphQL mutation to create user
const CREATE_USER_MUTATION = `
mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    id
    email
    name
    createdAt
  }
}
`;

async function makeGraphQLRequest(query, variables = {}) {
    const data = JSON.stringify({
        query,
        variables,
    });

    const options = {
        hostname: 'localhost',
        port: 3010,
        path: '/graphql',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': data.length,
        },
    };

    return new Promise((resolve, reject) => {
        const req = http.request(options, (res) => {
            let body = '';

            res.on('data', (chunk) => {
                body += chunk;
            });

            res.on('end', () => {
                try {
                    const response = JSON.parse(body);
                    resolve(response);
                } catch (error) {
                    reject(new Error(`Failed to parse response: ${body}`));
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        req.write(data);
        req.end();
    });
}

async function createStudentAccount() {
    console.log('Creating student account for AFFiNE...');
    console.log(`Email: ${STUDENT_EMAIL}`);
    console.log(`Name: ${STUDENT_NAME}`);
    console.log(`Password: ${STUDENT_PASSWORD}`);
    console.log('');

    try {
        // Create the user
        const result = await makeGraphQLRequest(CREATE_USER_MUTATION, {
            input: {
                email: STUDENT_EMAIL,
                name: STUDENT_NAME,
                password: STUDENT_PASSWORD,
            },
        });

        if (result.errors) {
            console.error('❌ Error creating user:');
            result.errors.forEach((error, index) => {
                console.error(`\nError ${index + 1}:`);
                console.error(`  Message: ${error.message}`);
                if (error.extensions) {
                    console.error(`  Extensions:`, JSON.stringify(error.extensions, null, 2));
                }
                if (error.path) {
                    console.error(`  Path:`, error.path);
                }
            });
            process.exit(1);
        }

        if (result.data && result.data.createUser) {
            console.log('✅ Student account created successfully!');
            console.log('');
            console.log('Account Details:');
            console.log(`  ID: ${result.data.createUser.id}`);
            console.log(`  Email: ${result.data.createUser.email}`);
            console.log(`  Name: ${result.data.createUser.name}`);
            console.log(`  Created: ${result.data.createUser.createdAt}`);
            console.log('');
            console.log('Login Credentials:');
            console.log(`  Email: ${STUDENT_EMAIL}`);
            console.log(`  Password: ${STUDENT_PASSWORD}`);
        } else {
            console.error('❌ Unexpected response format:');
            console.error(JSON.stringify(result, null, 2));
            process.exit(1);
        }
    } catch (error) {
        console.error('❌ Failed to create student account:');
        console.error(error.message);
        if (error.stack) {
            console.error(error.stack);
        }
        process.exit(1);
    }
}

// Run the script
createStudentAccount();
