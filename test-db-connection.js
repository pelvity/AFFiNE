const { Client } = require('pg');

const client = new Client({
    connectionString: 'postgresql://affine:pelvity@localhost:5432/affine'
});

client.connect()
    .then(() => {
        console.log('✓ Connected successfully!');
        return client.query('SELECT version()');
    })
    .then(res => {
        console.log('✓ Query result:', res.rows[0].version);
        return client.end();
    })
    .then(() => {
        console.log('✓ Connection closed');
        process.exit(0);
    })
    .catch(err => {
        console.error('✗ Connection failed:', err.message);
        process.exit(1);
    });
