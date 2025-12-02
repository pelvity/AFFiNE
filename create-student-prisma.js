/**
 * Script to create a student account directly in the database using Prisma
 * Usage: node create-student-prisma.js
 */

const { PrismaClient } = require('@prisma/client');
const crypto = require('crypto');

// Student account details
const STUDENT_EMAIL = 'dmytro.dmtxer@example.com';
const STUDENT_NAME = 'Dmytro Dmtxer';
const STUDENT_PASSWORD = 'dmytro2024Secure!';

const prisma = new PrismaClient();

/**
 * Hash password using bcrypt-compatible method
 * AFFiNE uses bcrypt for password hashing
 */
async function hashPassword(password) {
    const bcrypt = require('bcryptjs');
    const saltRounds = 10;
    return await bcrypt.hash(password, saltRounds);
}

async function createStudentAccount() {
    console.log('Creating student account for AFFiNE using Prisma...');
    console.log(`Email: ${STUDENT_EMAIL}`);
    console.log(`Name: ${STUDENT_NAME}`);
    console.log(`Password: ${STUDENT_PASSWORD}`);
    console.log('');

    try {
        // Check if user already exists
        const existingUser = await prisma.user.findUnique({
            where: { email: STUDENT_EMAIL },
        });

        if (existingUser) {
            console.log('⚠️  User already exists!');
            console.log(`  ID: ${existingUser.id}`);
            console.log(`  Email: ${existingUser.email}`);
            console.log(`  Name: ${existingUser.name}`);
            console.log('');
            console.log('To reset password, you can update the user manually or delete and recreate.');
            process.exit(0);
        }

        // Hash the password
        console.log('Hashing password...');
        const hashedPassword = await hashPassword(STUDENT_PASSWORD);

        // Create the user
        console.log('Creating user in database...');
        const user = await prisma.user.create({
            data: {
                email: STUDENT_EMAIL,
                name: STUDENT_NAME,
                password: hashedPassword,
                registered: true,
                emailVerifiedAt: new Date(), // Mark email as verified
            },
        });

        console.log('✅ Student account created successfully!');
        console.log('');
        console.log('Account Details:');
        console.log(`  ID: ${user.id}`);
        console.log(`  Email: ${user.email}`);
        console.log(`  Name: ${user.name}`);
        console.log(`  Created: ${user.createdAt}`);
        console.log(`  Email Verified: ${user.emailVerifiedAt}`);
        console.log('');
        console.log('Login Credentials:');
        console.log(`  Email: ${STUDENT_EMAIL}`);
        console.log(`  Password: ${STUDENT_PASSWORD}`);
        console.log('');
        console.log('The student can now log in to AFFiNE at http://localhost:3010');

    } catch (error) {
        console.error('❌ Failed to create student account:');
        console.error(error.message);
        if (error.stack) {
            console.error(error.stack);
        }
        process.exit(1);
    } finally {
        await prisma.$disconnect();
    }
}

// Run the script
createStudentAccount();
