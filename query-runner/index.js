const k8s = require("@kubernetes/client-node");
const express = require("express");

const NAMESPACE = "terraform-managed-namespace";

const app = express();
const kc = new k8s.KubeConfig();
kc.loadFromCluster();
const k8sApi = kc.makeApiClient(k8s.CoreV1Api);

const getSvcs = async () => {
  try {
    const { response, body } = await k8sApi.listNamespacedService(NAMESPACE);
    console.debug(
      `getSvcs: status=${response.statusCode}, response=${JSON.stringify(
        response
      )}`
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

app.get("/healthz", async (req, res) => {
  console.log("healthz");
  res.status(200).send("ok");
});

app.get("/svcs", async (req, res) => {
  console.log("svcs");
  const svcs = await getSvcs();
  res.status(200).send(svcs);
});

app.get("/query", async (req, res) => {
  // not implemented yet
  res.status(200).send("ok");
});

function keepAlive() {
  setTimeout(() => {
    keepAlive();
  }, 1000);
}

keepAlive();

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
