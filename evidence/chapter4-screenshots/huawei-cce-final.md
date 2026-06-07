# Huawei CCE - iRestrict V3 Workloads Running
Collected: 2026-06-07T22:34:53+01:00

## Cluster Info
[0;32mKubernetes control plane[0m is running at [0;33mhttps://159.138.162.249:5443[0m
[0;32mCoreDNS[0m is running at [0;33mhttps://159.138.162.249:5443/api/v1/namespaces/kube-system/services/coredns:dns/proxy[0m

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

## Version
clientVersion:
  buildDate: "2025-11-11T20:24:51Z"
  compiler: gc
  gitCommit: 5e00b99bac504844579ec74886b6cc5c9611ca19
  gitTreeState: clean
  gitVersion: v1.31.14
  goVersion: go1.24.9
  major: "1"
  minor: "31"
  platform: linux/amd64
kustomizeVersion: v5.4.2
serverVersion:
  buildDate: "2025-12-09T03:53:35Z"
  compiler: gc
  gitCommit: b97fddc211623c07a50cdf8a75ab373c85596866
  gitTreeState: clean
  gitVersion: v1.34.1-r0-34.0.1.8
  goVersion: go1.24.6
  major: "1"
  minor: "34"
  platform: linux/amd64

WARNING: version difference between client (1.31) and server (1.34) exceeds the supported minor version skew of +/-1

## Nodes
NAME         STATUS   ROLES    AGE     VERSION             INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                  KERNEL-VERSION                              CONTAINER-RUNTIME
10.83.1.14   Ready    <none>   5h10m   v1.34.1-r0-34.0.6   10.83.1.14    <none>        EulerOS 2.0 (SP9x86_64)   4.18.0-147.5.1.6.h1524.eulerosv2r9.x86_64   containerd://1.7.29-1-g9859417d3

## Namespaces
NAME                      STATUS   AGE
default                   Active   5h13m
irestrict-apps            Active   103m
irestrict-identity        Active   103m
irestrict-observability   Active   103m
irestrict-security        Active   103m
irestrict-system          Active   103m
kube-node-lease           Active   5h13m
kube-public               Active   5h13m
kube-system               Active   5h13m

## All Pods
NAMESPACE                 NAME                                      READY   STATUS    RESTARTS       AGE     IP            NODE         NOMINATED NODE   READINESS GATES
irestrict-apps            sample-financial-api-768dbf748c-mmrf5     1/1     Running   0              102m    172.16.0.25   10.83.1.14   <none>           <none>
irestrict-apps            sample-financial-api-768dbf748c-v58xl     1/1     Running   0              102m    172.16.0.24   10.83.1.14   <none>           <none>
irestrict-apps            synthetic-client-smoke-test-5ddr7         0/1     Error     0              102m    172.16.0.26   10.83.1.14   <none>           <none>
irestrict-identity        keycloak-7cd5dddcfc-sbmn9                 1/1     Running   0              12m     172.16.0.27   10.83.1.14   <none>           <none>
irestrict-observability   otel-collector-57465ddff6-8st2v           1/1     Running   0              102m    172.16.0.23   10.83.1.14   <none>           <none>
irestrict-security        opa-69bd5cff65-kfwvb                      1/1     Running   0              102m    172.16.0.22   10.83.1.14   <none>           <none>
irestrict-security        spire-agent-hwkxx                         1/1     Running   8 (61m ago)    103m    172.16.0.20   10.83.1.14   <none>           <none>
irestrict-security        spire-server-0                            1/1     Running   0              103m    172.16.0.19   10.83.1.14   <none>           <none>
kube-system               coredns-798b675b7-2h8gn                   0/1     Pending   0              5h12m   <none>        <none>       <none>           <none>
kube-system               coredns-798b675b7-jfs54                   1/1     Running   0              5h12m   172.16.0.16   10.83.1.14   <none>           <none>
kube-system               everest-csi-controller-86cf486db5-24bcr   0/1     Pending   0              5h12m   <none>        <none>       <none>           <none>
kube-system               everest-csi-controller-86cf486db5-rqcbd   1/1     Running   16 (42s ago)   5h12m   172.16.0.18   10.83.1.14   <none>           <none>
kube-system               everest-csi-driver-782nx                  1/1     Running   0              5h10m   10.83.1.14    10.83.1.14   <none>           <none>

## All Deployments
NAMESPACE                 NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
irestrict-apps            sample-financial-api     2/2     2            2           102m
irestrict-identity        keycloak                 1/1     1            1           102m
irestrict-observability   otel-collector           1/1     1            1           102m
irestrict-security        opa                      1/1     1            1           102m
kube-system               coredns                  1/2     2            1           5h12m
kube-system               everest-csi-controller   1/2     2            1           5h12m

## All StatefulSets
NAMESPACE            NAME           READY   AGE
irestrict-security   spire-server   1/1     103m

## All DaemonSets
NAMESPACE            NAME                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
irestrict-security   spire-agent          1         1         1       1            1           <none>          103m
kube-system          everest-csi-driver   1         1         1       1            1           <none>          5h12m

## All Services
NAMESPACE                 NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default                   kubernetes                          ClusterIP   10.247.0.1       <none>        443/TCP                  5h13m
irestrict-apps            sample-financial-api                ClusterIP   10.247.166.74    <none>        80/TCP                   102m
irestrict-identity        keycloak                            ClusterIP   10.247.51.218    <none>        8080/TCP                 102m
irestrict-observability   otel-collector                      ClusterIP   10.247.139.163   <none>        4317/TCP,4318/TCP        102m
irestrict-security        opa                                 ClusterIP   10.247.234.97    <none>        8181/TCP                 102m
irestrict-security        spire-server                        ClusterIP   10.247.225.202   <none>        8081/TCP                 103m
kube-system               coredns                             ClusterIP   10.247.3.10      <none>        53/UDP,53/TCP,8080/TCP   5h12m
kube-system               etcd-server-proxy                   ClusterIP   10.247.0.6       <none>        4001/TCP                 5h13m
kube-system               external-controller-manager-proxy   ClusterIP   10.247.0.9       <none>        8091/TCP                 5h13m
kube-system               kube-controller-proxy               ClusterIP   10.247.0.8       <none>        10257/TCP                5h13m
kube-system               kube-scheduler-proxy                ClusterIP   10.247.0.7       <none>        10259/TCP                5h13m
kube-system               proxy-exporter                      ClusterIP   10.247.0.5       <none>        10451/TCP                5h13m

## All ConfigMaps (iRestrict)
irestrict-apps            kube-root-ca.crt                                       1      103m
irestrict-apps            sample-financial-api-code                              1      102m
irestrict-identity        kube-root-ca.crt                                       1      103m
irestrict-observability   kube-root-ca.crt                                       1      103m
irestrict-observability   otel-collector-config                                  1      102m
irestrict-security        kube-root-ca.crt                                       1      103m
irestrict-security        miva-api-policies                                      1      102m
irestrict-security        spire-agent-config                                     1      103m
irestrict-security        spire-server-config                                    1      103m
irestrict-system          kube-root-ca.crt                                       1      103m

## ClusterRoles (iRestrict)
irestrict-spire-agent-workload-attestor                                2026-06-07T19:51:40Z
irestrict-spire-server-tokenreview                                     2026-06-07T19:51:40Z

## ClusterRoleBindings (iRestrict)
irestrict-spire-agent-workload-attestor                         ClusterRole/irestrict-spire-agent-workload-attestor                                103m
irestrict-spire-server-tokenreview                              ClusterRole/irestrict-spire-server-tokenreview                                     103m

## Keycloak Pod Logs (last 5 lines)
2026-06-07 21:26:57,108 WARN  [io.agroal.pool] (main) Datasource '<default>': JDBC resources leaked: 1 ResultSet(s) and 0 Statement(s)
2026-06-07 21:26:57,224 INFO  [io.quarkus] (main) Keycloak 26.0.7 on JVM (powered by Quarkus 3.15.1) started in 12.811s. Listening on: http://0.0.0.0:8080
2026-06-07 21:26:57,224 INFO  [io.quarkus] (main) Profile dev activated. 
2026-06-07 21:26:57,225 INFO  [io.quarkus] (main) Installed features: [agroal, cdi, hibernate-orm, jdbc-h2, keycloak, narayana-jta, opentelemetry, reactive-routes, rest, rest-jackson, smallrye-context-propagation, vertx]
2026-06-07 21:26:57,230 WARN  [org.keycloak.quarkus.runtime.KeycloakMain] (main) Running the server in development mode. DO NOT use this configuration in production.

## OPA Pod Logs (last 5 lines)
{"client_addr":"172.16.0.17:35812","level":"info","msg":"Sent response.","req_id":623,"req_method":"GET","req_path":"/health","resp_bytes":3,"resp_duration":0.263605,"resp_status":200,"time":"2026-06-07T21:34:43Z"}
{"client_addr":"172.16.0.17:35814","level":"info","msg":"Received request.","req_id":624,"req_method":"GET","req_path":"/health","time":"2026-06-07T21:34:49Z"}
{"client_addr":"172.16.0.17:35814","level":"info","msg":"Sent response.","req_id":624,"req_method":"GET","req_path":"/health","resp_bytes":3,"resp_duration":0.265598,"resp_status":200,"time":"2026-06-07T21:34:49Z"}
{"client_addr":"172.16.0.17:35816","level":"info","msg":"Received request.","req_id":625,"req_method":"GET","req_path":"/health","time":"2026-06-07T21:34:53Z"}
{"client_addr":"172.16.0.17:35816","level":"info","msg":"Sent response.","req_id":625,"req_method":"GET","req_path":"/health","resp_bytes":3,"resp_duration":0.277026,"resp_status":200,"time":"2026-06-07T21:34:53Z"}

## SPIRE Server Logs (last 5 lines)
time="2026-06-07T20:36:43Z" level=info msg="Starting Server APIs" address=/tmp/spire-server/private/api.sock network=unix subsystem_name=endpoints
time="2026-06-07T20:36:44Z" level=info msg="Health check recovered" check=server details="{true true {} {}}" duration=1.002438306 error="subsystem is not live or ready" failures=1 subsystem_name=health
time="2026-06-07T20:38:21Z" level=info msg="Agent attestation request completed" address="172.16.0.17:34598" agent_id="spiffe://miva.local/spire/agent/k8s_psat/miva-cluster/4c1f759d-35bd-4947-8acc-ab74fc67d129" authorized_as=nobody authorized_via= caller_addr="172.16.0.17:34598" method=AttestAgent node_attestor_type=k8s_psat request_id=40ac4c1f-131c-4dde-ba85-612fe17f6c6f service=agent.v1.Agent subsystem_name=api
time="2026-06-07T21:06:16Z" level=info msg="Agent attestation request completed" address="172.16.0.17:34620" agent_id="spiffe://miva.local/spire/agent/k8s_psat/miva-cluster/4c1f759d-35bd-4947-8acc-ab74fc67d129" authorized_as=nobody authorized_via= caller_addr="172.16.0.17:34620" method=AttestAgent node_attestor_type=k8s_psat request_id=55982a85-b89b-400a-950f-f8d5ab7408ca service=agent.v1.Agent subsystem_name=api
time="2026-06-07T21:34:43Z" level=info msg="Agent attestation request completed" address="172.16.0.17:34642" agent_id="spiffe://miva.local/spire/agent/k8s_psat/miva-cluster/4c1f759d-35bd-4947-8acc-ab74fc67d129" authorized_as=nobody authorized_via= caller_addr="172.16.0.17:34642" method=AttestAgent node_attestor_type=k8s_psat request_id=0806a91f-32e6-497e-9a45-4ec1d3277118 service=agent.v1.Agent subsystem_name=api

## Sample API Logs (last 5 lines)
Found 2 pods, using pod/sample-financial-api-768dbf748c-mmrf5
{"ts": 1780867859.961185, "client": "172.16.0.17", "message": "\"GET /healthz HTTP/1.1\" 200 -"}
{"ts": 1780867863.2619712, "client": "172.16.0.17", "message": "\"GET /healthz HTTP/1.1\" 200 -"}
{"ts": 1780867869.9600315, "client": "172.16.0.17", "message": "\"GET /healthz HTTP/1.1\" 200 -"}
{"ts": 1780867873.2614276, "client": "172.16.0.17", "message": "\"GET /healthz HTTP/1.1\" 200 -"}
{"ts": 1780867879.9607232, "client": "172.16.0.17", "message": "\"GET /healthz HTTP/1.1\" 200 -"}
