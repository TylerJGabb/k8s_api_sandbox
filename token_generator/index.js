const express = require("express");
const { GoogleAuth } = require("google-auth-library");

const auth = new GoogleAuth({
  scopes: "https://www.googleapis.com/auth/cloud-platform",
});

const app = express();

// keep in mind that the audience fo JWTs is https://bigquery.googleapis.com/
const getJWT = async () => {
  try {
    const client = await auth.getClient();
    const idToken = await client.fetchIdToken(
      "https://bigquery.googleapis.com/"
    );
    return idToken;
  } catch (err) {
    console.error(`getJWT: ${err}`);
  }
};

const getAccessToken = async () => {
  try {
    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();
    return accessToken.token;
  } catch (err) {
    console.error(`getAccessToken: ${err}`);
  }
};

// on startup verify pod can do what it needs to do
const initialize = async () => {
  console.log("Initializing");
  const accessToken = await getAccessToken();
  if (!accessToken) {
    console.error("getAccessToken: failed to get access token");
    process.exit(1);
  }
  const jwt = await getJWT();
  if (!jwt) {
    console.error("getJWT: failed to get JWT");
    process.exit(1);
  }
  console.log("Initialization complete");
};

app.get("/healthz", async (req, res) => {
  console.log("healthz");
  res.status(200).send("ok");
});

app.get("/access-token", async (req, res) => {
  console.log("token");
  const token = await getAccessToken();
  res.status(200).send(token);
});

app.get("/jwt", async (req, res) => {
  console.log("jwt");
  const token = await getJWT();
  res.status(200).send(token);
});

initialize()
  .then(() => {
    app.listen(80, () => {
      console.log("Listening on port 80");
    });
  })
  .catch((err) => {
    console.error(`Initialization Error: ${err}`);
    process.exit(1);
  });

function keepAlive() {
  setTimeout(() => {
    keepAlive();
  }, 1000);
}

keepAlive();
