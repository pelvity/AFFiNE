/**
 * Script to create a user account for Olek
 * Usage: node create-user-olek.js
 */

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

// Account details
const USER_EMAIL = 'olek@example.com';
const USER_NAME = 'Olek';
const USER_PASSWORD = 'olek2024Secure!';

const prisma = new PrismaClient();

async function createUser() {
    console.log('Creating account for Olek...');

    try {
        const existingUser = await prisma.user.findUnique({
            where: { email: USER_EMAIL },
        });

        if (existingUser) {
            console.log('User already exists.');
            return;
        }

        const hashedPassword = await bcrypt.hash(USER_PASSWORD, 10);

        const user = await prisma.user.create({
            data: {
                email: USER_EMAIL,
                name: USER_NAME,
                password: hashedPassword,
                registered: true,
                emailVerifiedAt: new Date(),
            },
        });

        console.log('✅ User created successfully!');
        console.log(`Email: ${USER_EMAIL}`);
        console.log(`Password: ${USER_PASSWORD}`);

    } catch (error) {
        console.error('Error creating user:', error);
    } finally {
        await prisma.$disconnect();
    }
}

createUser();
