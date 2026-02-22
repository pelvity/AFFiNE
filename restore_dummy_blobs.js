const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const client = new Client({
    connectionString: process.env.DATABASE_URL || 'postgresql://affine_dev:dev_password_change_me@postgres:5432/affine_dev',
});

const dummyBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==';
const dummyBuffer = Buffer.from(dummyBase64, 'base64');
const STORAGE_DIR = '/root/.affine/storage/blobs';

async function main() {
    await client.connect();
    const res = await client.query('SELECT workspace_id, key, size, mime FROM blobs');
    let restored = 0;

    for (const row of res.rows) {
        const wsDir = path.join(STORAGE_DIR, row.workspace_id);
        const filePath = path.join(wsDir, row.key);
        const metaPath = filePath + '.metadata.json';

        if (!fs.existsSync(filePath)) {
            if (!fs.existsSync(wsDir)) {
                fs.mkdirSync(wsDir, { recursive: true });
            }

            fs.writeFileSync(filePath, dummyBuffer);
            fs.writeFileSync(metaPath, JSON.stringify({
                contentLength: dummyBuffer.length,
                contentType: 'image/png',
                lastModified: Date.now()
            }));
            restored++;
        }
    }

    console.log(`Created ${restored} missing placeholder blobs.`);
    await client.end();
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
