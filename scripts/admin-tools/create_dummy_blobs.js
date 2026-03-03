const fs = require('fs');
const path = require('path');

const STORAGE_DIR = '/home/pelvity/.affine/dev/storage/blobs';
const dummyBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==';
const dummyBuffer = Buffer.from(dummyBase64, 'base64');
const listPath = path.join(__dirname, 'blobs_list.txt');

try {
    const content = fs.readFileSync(listPath, 'utf8');
    const lines = content.split('\n').map(l => l.trim()).filter(l => l.length > 0);
    let restored = 0;

    for (const line of lines) {
        if (line.includes('WARN')) continue; // Skip docker compose warnings

        // Line format: workspace_id/key
        const [wsId, key] = line.split('/');
        if (!wsId || !key) continue;

        const wsDir = path.join(STORAGE_DIR, wsId);
        const filePath = path.join(wsDir, key);
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
} catch (err) {
    console.error(err);
    process.exit(1);
}
