=== Huawei CCE Cluster Evidence ===
Collected: 2026-06-07T20:53:28+01:00

## Cluster Info
[0;32mKubernetes control plane[0m is running at [0;33mhttps://159.138.162.249:5443[0m
[0;32mCoreDNS[0m is running at [0;33mhttps://159.138.162.249:5443/api/v1/namespaces/kube-system/services/coredns:dns/proxy[0m

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

## Nodes
NAME         STATUS   ROLES    AGE     VERSION             INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                  KERNEL-VERSION                              CONTAINER-RUNTIME
10.83.1.14   Ready    <none>   3h29m   v1.34.1-r0-34.0.6   10.83.1.14    <none>        EulerOS 2.0 (SP9x86_64)   4.18.0-147.5.1.6.h1524.eulerosv2r9.x86_64   containerd://1.7.29-1-g9859417d3

## Namespaces
NAME                      STATUS   AGE
default                   Active   3h32m
irestrict-apps            Active   111s
irestrict-identity        Active   111s
irestrict-observability   Active   111s
irestrict-security        Active   111s
irestrict-system          Active   111s
kube-node-lease           Active   3h32m
kube-public               Active   3h32m
kube-system               Active   3h32m

## All Deployments
NAMESPACE                 NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
irestrict-apps            sample-financial-api     0/2     2            0           91s
irestrict-identity        keycloak                 0/1     1            0           92s
irestrict-observability   otel-collector           0/1     1            0           91s
irestrict-security        opa                      0/1     1            0           91s
kube-system               coredns                  1/2     2            1           3h31m
kube-system               everest-csi-controller   1/2     2            1           3h31m

## All StatefulSets
NAMESPACE            NAME           READY   AGE
irestrict-security   spire-server   0/1     108s

## All DaemonSets
NAMESPACE            NAME                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
irestrict-security   spire-agent          1         1         0       1            0           <none>          108s
kube-system          everest-csi-driver   1         1         1       1            1           <none>          3h31m

## All Pods
NAMESPACE                 NAME                                      READY   STATUS             RESTARTS       AGE
irestrict-apps            sample-financial-api-768dbf748c-mmrf5     0/1     ErrImagePull       0              91s
irestrict-apps            sample-financial-api-768dbf748c-v58xl     0/1     ErrImagePull       0              91s
irestrict-apps            synthetic-client-smoke-test-5ddr7         0/1     ErrImagePull       0              89s
irestrict-identity        keycloak-86b6c8f666-2dccm                 0/1     ErrImagePull       0              91s
irestrict-observability   otel-collector-57465ddff6-8st2v           0/1     ErrImagePull       0              91s
irestrict-security        opa-69bd5cff65-kfwvb                      0/1     ErrImagePull       0              91s
irestrict-security        spire-agent-hwkxx                         0/1     ImagePullBackOff   0              108s
irestrict-security        spire-server-0                            0/1     ImagePullBackOff   0              108s
kube-system               coredns-798b675b7-2h8gn                   0/1     Pending            0              3h31m
kube-system               coredns-798b675b7-jfs54                   1/1     Running            0              3h31m
kube-system               everest-csi-controller-86cf486db5-24bcr   0/1     Pending            0              3h31m
kube-system               everest-csi-controller-86cf486db5-rqcbd   1/1     Running            2 (2m7s ago)   3h31m
kube-system               everest-csi-driver-782nx                  1/1     Running            0              3h29m

## All Services
NAMESPACE                 NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default                   kubernetes                          ClusterIP   10.247.0.1       <none>        443/TCP                  3h32m
irestrict-apps            sample-financial-api                ClusterIP   10.247.166.74    <none>        80/TCP                   91s
irestrict-identity        keycloak                            ClusterIP   10.247.51.218    <none>        8080/TCP                 92s
irestrict-observability   otel-collector                      ClusterIP   10.247.139.163   <none>        4317/TCP,4318/TCP        91s
irestrict-security        opa                                 ClusterIP   10.247.234.97    <none>        8181/TCP                 91s
irestrict-security        spire-server                        ClusterIP   10.247.225.202   <none>        8081/TCP                 108s
kube-system               coredns                             ClusterIP   10.247.3.10      <none>        53/UDP,53/TCP,8080/TCP   3h31m
kube-system               etcd-server-proxy                   ClusterIP   10.247.0.6       <none>        4001/TCP                 3h31m
kube-system               external-controller-manager-proxy   ClusterIP   10.247.0.9       <none>        8091/TCP                 3h31m
kube-system               kube-controller-proxy               ClusterIP   10.247.0.8       <none>        10257/TCP                3h31m
kube-system               kube-scheduler-proxy                ClusterIP   10.247.0.7       <none>        10259/TCP                3h31m
kube-system               proxy-exporter                      ClusterIP   10.247.0.5       <none>        10451/TCP                3h31m

## All ConfigMaps
NAMESPACE                 NAME                                                   DATA   AGE
default                   kube-root-ca.crt                                       1      3h31m
irestrict-apps            kube-root-ca.crt                                       1      111s
irestrict-apps            sample-financial-api-code                              1      91s
irestrict-identity        kube-root-ca.crt                                       1      111s
irestrict-observability   kube-root-ca.crt                                       1      111s
irestrict-observability   otel-collector-config                                  1      91s
irestrict-security        kube-root-ca.crt                                       1      111s
irestrict-security        miva-api-policies                                      1      91s
irestrict-security        spire-agent-config                                     1      108s
irestrict-security        spire-server-config                                    1      108s
irestrict-system          kube-root-ca.crt                                       1      111s
kube-node-lease           kube-root-ca.crt                                       1      3h31m
kube-public               kube-root-ca.crt                                       1      3h31m
kube-system               cluster-config                                         2      3h31m
kube-system               cluster-versions                                       1      3h31m
kube-system               coredns                                                1      3h31m
kube-system               everest-driver-th-config                               2      3h31m
kube-system               extension-apiserver-authentication                     6      3h32m
kube-system               kube-apiserver-legacy-service-account-token-tracking   1      3h32m
kube-system               kube-root-ca.crt                                       1      3h31m
kube-system               scheduler-config                                       1      3h31m

## All Jobs
NAMESPACE        NAME                          STATUS    COMPLETIONS   DURATION   AGE
irestrict-apps   synthetic-client-smoke-test   Running   0/1           89s        89s

## ClusterRoles (iRestrict)
irestrict-spire-agent-workload-attestor                                2026-06-07T19:51:40Z
irestrict-spire-server-tokenreview                                     2026-06-07T19:51:40Z

## ClusterRoleBindings (iRestrict)
irestrict-spire-agent-workload-attestor                         ClusterRole/irestrict-spire-agent-workload-attestor                                111s
irestrict-spire-server-tokenreview                              ClusterRole/irestrict-spire-server-tokenreview                                     111s

## Version
Client Version: v1.31.14
Kustomize Version: v5.4.2
Server Version: v1.34.1-r0-34.0.1.8
