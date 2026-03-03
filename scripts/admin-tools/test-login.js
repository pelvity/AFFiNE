const http = require('http');

const data = JSON.stringify({
    email: 'test_auto_login@example.com'
});

const options = {
    hostname: 'localhost',
    port: 3010,
    path: '/api/auth/sign-in',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

function tryLogin(retries = 30) {
    console.log(`Attempting login... (${retries} retries left)`);

    const req = http.request(options, (res) => {
        console.log(`STATUS: ${res.statusCode}`);
        let body = '';
        res.on('data', (chunk) => body += chunk);
        res.on('end', () => {
            console.log('BODY:', body);
            if (res.statusCode === 200 && body.includes('"id"')) {
                console.log('SUCCESS: Logged in immediately!');
                process.exit(0);
            } else {
                console.log('FAILURE: Did not log in immediately or server error.');
                process.exit(1);
            }
        });
    });

    req.on('error', (e) => {
        if (retries > 0) {
            console.log(`Server not ready yet (${e.message}). Retrying in 2s...`);
            setTimeout(() => tryLogin(retries - 1), 2000);
        } else {
            console.error(`Problem with request: ${e.message}`);
            process.exit(1);
        }
    });

    req.write(data);
    req.end();
}

tryLogin();
