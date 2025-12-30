const { PrismaClient } = require('@prisma/client');

async function findWorkspaces() {
    const prisma = new PrismaClient();

    try {
        const workspaces = await prisma.workspace.findMany({
            select: {
                id: true,
                createdAt: true,
            }
        });

        console.log('Found', workspaces.length, 'workspaces:');
        console.log(JSON.stringify(workspaces, null, 2));

        // Try to find workspace metadata/names
        for (const ws of workspaces) {
            const members = await prisma.workspaceUserRole.findMany({
                where: { workspaceId: ws.id },
                include: { user: { select: { email: true, name: true } } }
            });

            console.log(`\nWorkspace ${ws.id}:`);
            console.log(`  Created: ${ws.createdAt}`);
            console.log(`  Members (${members.length}):`);
            members.forEach(m => {
                console.log(`    - ${m.user.email} (${m.user.name}) - Role: ${m.type}`);
            });
        }

    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    } finally {
        await prisma.$disconnect();
    }
}

findWorkspaces();
