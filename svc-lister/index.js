const k8s = require("@kubernetes/client-node");

console.log("Hello world!");

const kc = new k8s.KubeConfig();
kc.loadFromCluster();

const k8sApi = kc.makeApiClient(k8s.CoreV1Api);
k8sApi
  .listNamespacedService("terraform-managed-namespace")
  .then((res) => {
    const { response, body } = res;

    //log a message with the status code
    console.log(
      `status=${response.statusCode}, response=${JSON.stringify(response)}`
    );
    console.log(`Found ${body.items.length} services`);
    body.items.forEach((item) => {
      console.log(item.metadata.name);
    });
  })
  .catch((err) => {
    console.log(err);
  });

function keepAlive() {
  setTimeout(() => {
    keepAlive();
  }, 1000);
}

keepAlive();
