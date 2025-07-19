// hash.js
const bcrypt = require("bcrypt");

const password = "191910"; // mật khẩu muốn hash

bcrypt.hash(password, 10).then((hash) => {
  console.log("Hashed password:", hash);
});
