const bcrypt = require('bcrypt');

const password = process.argv[2] || 'defaultPassword';
const saltRounds = 10;

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log(hash);
});
