const { GoogleAuth } = require("google-auth-library");

async function loopingMain() {
  const auth = new GoogleAuth({
    scopes: "https://www.googleapis.com/auth/cloud-platform",
  });
  try {
    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();
    const idToken = await client.fetchIdToken();
    console.log({
      accessToken,
      idToken,
    });
  } catch (err) {
    console.error(err);
  }
}

function keepAlive() {
  loopingMain().catch((err) => console.error(err));
  setTimeout(() => {
    keepAlive();
  }, 10000);
}

keepAlive();
