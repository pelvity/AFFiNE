const { PrismaClient, WorkspaceMemberStatus, WorkspaceMemberSource } = require('@prisma/client');

async function addUserToWorkspace() {
    const prisma = new PrismaClient();

    const email = 'ivan_english@gmail.com';
    const workspaceId = process.argv[2]; // Pass workspace ID as argument

    try {
        // Find user
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            throw new Error('User not found: ' + email);
        }

        console.log('User found:', JSON.stringify({ id: user.id, email: user.email, name: user.name }, null, 2));

        if (!workspaceId) {
            console.log('\nTo add user to workspace, run:');
            console.log('node add-user-to-workspace.js <WORKSPACE_ID>');
            process.exit(0);
        }

        // Add user to workspace as Collaborator
        const res = await prisma.workspaceUserRole.upsert({
            where: {
                workspaceId_userId: {
                    workspaceId,
                    userId: user.id
                }
            },
            update: {
                type: 1, // Collaborator
                status: WorkspaceMemberStatus.Accepted,
                source: WorkspaceMemberSource.Link
            },
            create: {
                workspaceId,
                userId: user.id,
                type: 1, // Collaborator
                status: WorkspaceMemberStatus.Accepted,
                source: WorkspaceMemberSource.Link
            }
        });

        console.log('\n✅ User added to workspace successfully!');
        console.log(JSON.stringify({
            ok: true,
            userId: user.id,
            workspaceId,
            role: res.type,
            status: res.status
        }, null, 2));

    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    } finally {
        await prisma.$disconnect();
    }
}

addUserToWorkspace();
