const k8s = require("@kubernetes/client-node");
const express = require("express");
const bodyParser = require("body-parser");
const axios = require("axios").default;
const jwt = require("jsonwebtoken");

const NAMESPACE = "terraform-managed-namespace";
const PROJECT = "sb-05-386818";
const PORT = 80;
const FAKE_SIGNING_KEY = "shhhhhh";

axios.defaults.validateStatus = () => true;
const app = express();
const kc = new k8s.KubeConfig();
kc.loadFromCluster();
const k8sApi = kc.makeApiClient(k8s.CoreV1Api);

const getSvcs = async () => {
  try {
    const { response, body } = await k8sApi.listNamespacedService(
      NAMESPACE,
      (labelSelector = 'is_pii_service="true"')
    );
    if (response.statusCode !== 200) {
      console.warn(`getSvcs: status was not ok. ${JSON.stringify(response)}`);
    } else {
      console.log(`getSvcs: found ${body.items.length} services`);
      const forLog = body.items.map((item) => {
        const name = item.metadata.name;
        const pii_permission = item.metadata?.labels?.pii_permission;
        const ip = item.spec.clusterIP;
        return { name, pii_permission, ip };
      });
      console.debug(`getSvcs: ${JSON.stringify(forLog)}`);
      return body.items;
    }
  } catch (err) {
    console.error(`getSvcs: ${err}`);
  }
};

const getAccess = async (svcHostName) => {
  try {
    const url = `http://${svcHostName}/access-token`;
    console.log(`getAccess: URL=${url}`);
    const response = await axios.get(url);
    if (response.status !== 200) {
      console.error("getAccess: status not ok", response);
    }
    return response.data;
  } catch (err) {
    console.error("getAccess: Error", err);
  }
};

const queryBq = async (jwt, query) => {
  const reqBody = {
    query,
    useLegacySql: false,
  };
  const headers = {
    Authorization: `Bearer ${jwt}`,
  };
  const url = `https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT}/queries`;
  const response = await axios.post(url, reqBody, { headers });
  if (response.status !== 200) {
    console.error("queryBq: status not ok", response.data);
  } else {
    console.log("queryBq: success", response.data);
  }
  return {
    data: JSON.stringify(response.data),
    status: response.status,
  };
};

const runQuery = async (res, query, piiPermission) => {
  try {
    const svcs = await getSvcs();
    if (!svcs) {
      return res.status(500).send("Failed to get services");
    }
    const filtered = svcs.filter(
      (svc) => svc.metadata?.labels?.pii_permission === piiPermission
    );
    if (filtered.length === 0) {
      res.status(400).send({
        error: `No services found with pii_permission=${piiPermission}`,
      });
      return;
    }
    const svc = filtered[0];
    const accessTok = await getAccess(svc.spec.clusterIP);
    if (!accessTok) {
      return res.status(500).send("Failed to get jwt");
    }
    const queryResult = await queryBq(accessTok, query);
    res.setHeader("Content-Type", "application/json");
    res.status(queryResult.status).send(queryResult.data);
  } catch (err) {
    console.error("Error", err);
    res.status(500).send(err.toString());
  }
};

// on startup verify pod can do what it needs to do
const initialize = async () => {
  console.log("Initializing");
  const svcs = await getSvcs();
  if (!svcs) {
    console.error("getSvcs: failed to get services");
    process.exit(1);
  }
  console.log("Initialization complete");
};

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.get("/healthz", async (req, res) => {
  console.log("healthz");
  res.status(200).send("ok");
});

app.get("/svcs", async (req, res) => {
  console.log("svcs");
  const svcs = await getSvcs();
  res.status(200).send(svcs);
});

app.get("/fake-token", async (req, res) => {
  console.log("fake-token");
  const { permission } = req.query;
  const token = jwt.sign({ piiPermission: permission }, FAKE_SIGNING_KEY, {
    expiresIn: 300,
  });
  if (!token) {
    return res.status(500).send("Failed to get token");
  }
  res.status(200).send(token);
});

app.post("/query-tok", async (req, res) => {
  try {
    const verifiedTok = jwt.verify(req.body.token, FAKE_SIGNING_KEY);
    console.log("verifiedTok", verifiedTok);
    const piiPermission = verifiedTok.piiPermission;
    const query = req.body.query;
    await runQuery(res, query, piiPermission);
  } catch (err) {
    console.error("Error", err);
    res.status(500).send(err.toString());
  }
});

app.post("/query", async (req, res) => {
  try {
    const { query, piiPermission } = req.body;
    await runQuery(res, query, piiPermission);
  } catch (err) {
    console.error("Error", err);
    res.status(500).send(err.toString());
  }
});

function keepAlive() {
  setTimeout(() => {
    keepAlive();
  }, 1000);
}

keepAlive();

initialize()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Listening on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error(`Initialization Error: ${err}`);
    process.exit(1);
  });
