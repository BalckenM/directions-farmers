const http = require("http");

const loginBody = JSON.stringify({
  email: "balckfarmer@gmail.com",
  password: "password123",
});

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = "";
      res.on("data", (c) => (data += c));
      res.on("end", () => resolve({ status: res.statusCode, body: data }));
    });
    req.on("error", reject);
    if (body) req.write(body);
    req.end();
  });
}

async function main() {
  const loginRes = await request(
    {
      hostname: "localhost",
      port: 3000,
      path: "/v1/auth/login",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(loginBody),
      },
    },
    loginBody,
  );

  console.log("login status:", loginRes.status);
  const loginJson = JSON.parse(loginRes.body);
  const token = loginJson.data?.token || loginJson.token;
  if (!token) {
    console.log("no token, body:", loginRes.body);
    return;
  }

  const animalsRes = await request({
    hostname: "localhost",
    port: 3000,
    path: "/v1/livestock/animals?species=cattle",
    headers: { Authorization: "Bearer " + token },
  });

  console.log("animals status:", animalsRes.status);
  console.log("animals body:", animalsRes.body.substring(0, 1000));
}

main().catch(console.error);
