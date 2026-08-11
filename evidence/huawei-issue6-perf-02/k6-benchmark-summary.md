# k6 Matched Baseline vs Secured Policy-Path Benchmark

This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.

```text
running (0m01.0s), 050/100 VUs, 481 complete and 0 interrupted iterations
running (0m02.0s), 050/100 VUs, 810 complete and 0 interrupted iterations
running (0m03.0s), 050/100 VUs, 1302 complete and 0 interrupted iterations
running (0m04.0s), 050/100 VUs, 1468 complete and 0 interrupted iterations
running (0m05.0s), 050/100 VUs, 1781 complete and 0 interrupted iterations
running (0m06.0s), 050/100 VUs, 1966 complete and 0 interrupted iterations
running (0m07.0s), 050/100 VUs, 2344 complete and 0 interrupted iterations
running (0m08.0s), 050/100 VUs, 2595 complete and 0 interrupted iterations
running (0m09.0s), 050/100 VUs, 2871 complete and 0 interrupted iterations
running (0m10.0s), 050/100 VUs, 3109 complete and 0 interrupted iterations
running (0m11.0s), 050/100 VUs, 3325 complete and 0 interrupted iterations
running (0m12.0s), 050/100 VUs, 3487 complete and 0 interrupted iterations
running (0m13.0s), 050/100 VUs, 3639 complete and 0 interrupted iterations
running (0m14.0s), 050/100 VUs, 3857 complete and 0 interrupted iterations
running (0m15.0s), 050/100 VUs, 4129 complete and 0 interrupted iterations
running (0m16.0s), 050/100 VUs, 4797 complete and 0 interrupted iterations
running (0m17.0s), 050/100 VUs, 5057 complete and 0 interrupted iterations
running (0m18.0s), 050/100 VUs, 5580 complete and 0 interrupted iterations
running (0m19.0s), 050/100 VUs, 6269 complete and 0 interrupted iterations
running (0m20.0s), 050/100 VUs, 7035 complete and 0 interrupted iterations
running (0m21.0s), 025/100 VUs, 7079 complete and 0 interrupted iterations
running (0m22.0s), 015/100 VUs, 7089 complete and 0 interrupted iterations
running (0m23.0s), 010/100 VUs, 7094 complete and 0 interrupted iterations
running (0m24.0s), 007/100 VUs, 7097 complete and 0 interrupted iterations
running (0m25.0s), 003/100 VUs, 7101 complete and 0 interrupted iterations
running (0m26.0s), 052/100 VUs, 9239 complete and 0 interrupted iterations
running (0m27.0s), 051/100 VUs, 11649 complete and 0 interrupted iterations
running (0m28.0s), 050/100 VUs, 14294 complete and 0 interrupted iterations
running (0m29.0s), 050/100 VUs, 16881 complete and 0 interrupted iterations
running (0m30.0s), 050/100 VUs, 19695 complete and 0 interrupted iterations
running (0m31.0s), 050/100 VUs, 22388 complete and 0 interrupted iterations
running (0m32.0s), 050/100 VUs, 25056 complete and 0 interrupted iterations
running (0m33.0s), 050/100 VUs, 27577 complete and 0 interrupted iterations
running (0m34.0s), 050/100 VUs, 30318 complete and 0 interrupted iterations
running (0m35.0s), 050/100 VUs, 32895 complete and 0 interrupted iterations
running (0m36.0s), 050/100 VUs, 35732 complete and 0 interrupted iterations
running (0m37.0s), 050/100 VUs, 38163 complete and 0 interrupted iterations
running (0m38.0s), 050/100 VUs, 40867 complete and 0 interrupted iterations
running (0m39.0s), 050/100 VUs, 43511 complete and 0 interrupted iterations
running (0m40.0s), 050/100 VUs, 46034 complete and 0 interrupted iterations
running (0m41.0s), 050/100 VUs, 48792 complete and 0 interrupted iterations
running (0m42.0s), 050/100 VUs, 51632 complete and 0 interrupted iterations
running (0m43.0s), 050/100 VUs, 54147 complete and 0 interrupted iterations
running (0m44.0s), 050/100 VUs, 56956 complete and 0 interrupted iterations
running (0m45.0s), 050/100 VUs, 59878 complete and 0 interrupted iterations
running (0m46.0s), 002/100 VUs, 60006 complete and 0 interrupted iterations
     checks.........................: 100.00% 60008 out of 60008
     data_received..................: 14 MB   303 kB/s
     data_sent......................: 15 MB   323 kB/s
     http_req_duration..............: avg=3.37ms   min=290.82µs med=1.98ms   p(90)=5.31ms   p(95)=7.47ms   p(99)=14.74ms  max=3.32s  
     http_req_failed................: 0.00%   0 out of 60008
     iterations.....................: 60008   1304.425879/s
     vus............................: 2       min=2              max=52 
     vus_max........................: 100     min=100            max=100
running (0m46.0s), 000/100 VUs, 60008 complete and 0 interrupted iterations
```
