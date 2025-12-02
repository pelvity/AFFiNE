# Student Accounts (Self-hosted AFFiNE)

These accounts are created in your self-hosted AFFiNE instance and can be used for classes to collaborate in real time.

- Server (local): http://localhost:3010/
- If using tunnel: your Cloudflare URL when active

## Accounts

- Email: admin@example.com
  Password: AdminSecure2025!

- Email: dmytro@example.com
  Password: DmytroSecure2025!

- Email: class-guest@example.com
  Password: pelvity

- Email: artem_bmw@example.com
  Password: Artem_BMW!2025

- Email: olek@example.com
  Password: pelvity

- Email: dmtxer@example.com
  Password: dmytro#2025!

## Add accounts to a workspace (optional)
Use the workspace ID from the URL, e.g.
`http://localhost:3010/workspace/0a0c96bb-d5a6-4961-aabe-a8104a95498c/all`

To add a user as Collaborator (edit access) via Docker (run in PowerShell):

```
# Replace <WORKSPACE_ID> and <EMAIL>
$ws = "0a0c96bb-d5a6-4961-aabe-a8104a95498c"
$email = "class-guest@example.com"

docker exec affine_server node -e "const {PrismaClient, WorkspaceMemberStatus, WorkspaceMemberSource} = require('@prisma/client'); (async () => { const prisma = new PrismaClient(); const workspaceId = '$ws'; const email = '$email'; const user = await prisma.user.findUnique({ where: { email } }); if (!user) { throw new Error('User not found: ' + email); } const res = await prisma.workspaceUserRole.upsert({ where: { workspaceId_userId: { workspaceId, userId: user.id } }, update: { type: 1, status: WorkspaceMemberStatus.Accepted, source: WorkspaceMemberSource.Link }, create: { workspaceId, userId: user.id, type: 1, status: WorkspaceMemberStatus.Accepted, source: WorkspaceMemberSource.Link } }); console.log(JSON.stringify({ ok: true, userId: user.id, workspaceId, role: res.type, status: res.status }, null, 2)); })().catch(e => { console.error(e); process.exit(1); });"
```

- `type: 1` = Collaborator
- `type: 10` = Admin (be careful)
- `type: 99` = Owner (do not set via this route)

## Backups
- Database path: `%USERPROFILE%\.affine\self-host\postgres\pgdata`
- File uploads: `%USERPROFILE%\.affine\self-host\storage`

Postgres backup example:
```
docker exec -i affine_postgres pg_dump -U affine -d affine > affine-backup.sql
```
