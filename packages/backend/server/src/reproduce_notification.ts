
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    const email = `test-${Date.now()}@example.com`;
    console.log(`Testing with email: ${email}`);

    // 1. Find or create a workspace
    let workspace = await prisma.workspace.findFirst();
    if (!workspace) {
        workspace = await prisma.workspace.create({ data: { public: false } });
    }
    console.log(`Using workspace: ${workspace.id}`);

    // 2. Find an inviter
    const inviter = await prisma.user.findFirst({ where: { registered: true } });
    if (!inviter) {
        console.error('No inviter found');
        return;
    }
    console.log(`Using inviter: ${inviter.id}`);

    // 3. Create unregistered user (simulating inviteMembers)
    const user = await prisma.user.create({
        data: {
            email,
            registered: false,
        }
    });
    console.log(`Created unregistered user: ${user.id}`);

    // 4. Create pending role
    const role = await prisma.workspaceUserPermission.create({
        data: {
            workspaceId: workspace.id,
            userId: user.id,
            type: 1, // Collaborator (WorkspaceRole.Collaborator is 1)
            status: 'Pending',
            source: 'Email',
            inviterId: inviter.id,
        }
    });
    console.log(`Created pending role: ${role.id}`);

    // 5. Simulate the notification creation (since we can't easily trigger the job/event here)
    // In reality, the job would do this.
    const notificationBody = {
        workspaceId: workspace.id,
        createdByUserId: inviter.id,
        inviteId: role.id,
    };

    const notification = await prisma.notification.create({
        data: {
            userId: user.id,
            type: 'Invitation',
            level: 'Default',
            body: notificationBody,
        }
    });
    console.log(`Created notification: ${notification.id}`);

    // 6. Query notifications (simulating findManyByUserId)
    const notifications = await prisma.notification.findMany({
        where: { userId: user.id }
    });
    console.log('Query result:', JSON.stringify(notifications, null, 2));

    // 7. Check if body has what's needed
    const body = notifications[0].body as any;
    console.log('Notification body:', body);

    if (body.workspaceId && body.createdByUserId && body.inviteId) {
        console.log('SUCCESS: Notification record looks correct in DB.');
    } else {
        console.log('FAILURE: Notification record is missing fields.');
    }

    // Clean up
    await prisma.notification.delete({ where: { id: notification.id } });
    await prisma.workspaceUserPermission.delete({ where: { id: role.id } });
    await prisma.user.delete({ where: { id: user.id } });
}

main().catch(console.error).finally(() => prisma.$disconnect());
