# k6 Matched Baseline vs Secured Policy-Path Benchmark

This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.

```text
running (0m01.0s), 050/100 VUs, 212 complete and 0 interrupted iterations
running (0m02.0s), 050/100 VUs, 467 complete and 0 interrupted iterations
running (0m03.0s), 050/100 VUs, 723 complete and 0 interrupted iterations
running (0m04.0s), 050/100 VUs, 990 complete and 0 interrupted iterations
running (0m05.0s), 050/100 VUs, 1250 complete and 0 interrupted iterations
running (0m06.0s), 050/100 VUs, 1539 complete and 0 interrupted iterations
running (0m07.0s), 050/100 VUs, 1803 complete and 0 interrupted iterations
running (0m08.0s), 050/100 VUs, 2080 complete and 0 interrupted iterations
running (0m09.0s), 050/100 VUs, 2360 complete and 0 interrupted iterations
running (0m10.0s), 050/100 VUs, 2566 complete and 0 interrupted iterations
running (0m11.0s), 050/100 VUs, 2833 complete and 0 interrupted iterations
running (0m12.0s), 050/100 VUs, 3056 complete and 0 interrupted iterations
running (0m13.0s), 050/100 VUs, 3136 complete and 0 interrupted iterations
running (0m14.0s), 050/100 VUs, 3264 complete and 0 interrupted iterations
running (0m15.0s), 050/100 VUs, 3409 complete and 0 interrupted iterations
running (0m16.0s), 050/100 VUs, 3663 complete and 0 interrupted iterations
running (0m17.0s), 050/100 VUs, 3929 complete and 0 interrupted iterations
running (0m18.0s), 050/100 VUs, 4204 complete and 0 interrupted iterations
running (0m19.0s), 050/100 VUs, 4422 complete and 0 interrupted iterations
running (0m20.0s), 050/100 VUs, 4692 complete and 0 interrupted iterations
running (0m21.0s), 002/100 VUs, 4753 complete and 0 interrupted iterations
running (0m22.0s), 000/100 VUs, 4755 complete and 0 interrupted iterations
running (0m23.0s), 000/100 VUs, 4755 complete and 0 interrupted iterations
running (0m24.0s), 000/100 VUs, 4755 complete and 0 interrupted iterations
running (0m25.0s), 000/100 VUs, 4755 complete and 0 interrupted iterations
running (0m26.0s), 050/100 VUs, 5907 complete and 0 interrupted iterations
running (0m27.0s), 050/100 VUs, 7174 complete and 0 interrupted iterations
running (0m28.0s), 050/100 VUs, 8537 complete and 0 interrupted iterations
running (0m29.0s), 050/100 VUs, 9558 complete and 0 interrupted iterations
running (0m30.0s), 050/100 VUs, 10772 complete and 0 interrupted iterations
running (0m31.0s), 050/100 VUs, 12011 complete and 0 interrupted iterations
running (0m32.0s), 050/100 VUs, 13097 complete and 0 interrupted iterations
running (0m33.0s), 050/100 VUs, 14460 complete and 0 interrupted iterations
running (0m34.0s), 050/100 VUs, 15634 complete and 0 interrupted iterations
running (0m35.0s), 050/100 VUs, 16871 complete and 0 interrupted iterations
running (0m36.0s), 050/100 VUs, 17935 complete and 0 interrupted iterations
running (0m37.0s), 050/100 VUs, 19290 complete and 0 interrupted iterations
running (0m38.0s), 050/100 VUs, 20610 complete and 0 interrupted iterations
running (0m39.0s), 050/100 VUs, 21920 complete and 0 interrupted iterations
running (0m40.0s), 050/100 VUs, 22928 complete and 0 interrupted iterations
running (0m41.0s), 050/100 VUs, 24259 complete and 0 interrupted iterations
running (0m42.0s), 050/100 VUs, 25536 complete and 0 interrupted iterations
running (0m43.0s), 050/100 VUs, 26783 complete and 0 interrupted iterations
running (0m44.0s), 050/100 VUs, 28075 complete and 0 interrupted iterations
running (0m45.0s), 050/100 VUs, 29363 complete and 0 interrupted iterations
running (0m46.0s), 003/100 VUs, 29467 complete and 0 interrupted iterations
     checks.........................: 100.00% 29470 out of 29470
     data_received..................: 6.8 MB  148 kB/s
     data_sent......................: 7.3 MB  158 kB/s
     http_req_duration..............: avg=18.7ms   min=421.5µs med=5.83ms   p(90)=55ms     p(95)=80.02ms  p(99)=214.06ms max=3.34s   
     http_req_failed................: 0.00%   0 out of 29470
     iterations.....................: 29470   639.84357/s
     vus............................: 3       min=0              max=50 
     vus_max........................: 100     min=100            max=100
running (0m46.1s), 000/100 VUs, 29470 complete and 0 interrupted iterations
```
