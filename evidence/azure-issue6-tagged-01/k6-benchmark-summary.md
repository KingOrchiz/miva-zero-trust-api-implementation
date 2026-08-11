# k6 Matched Baseline vs Secured Policy-Path Benchmark

This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.

```text
running (0m01.0s), 050/100 VUs, 1227 complete and 0 interrupted iterations
running (0m02.0s), 050/100 VUs, 2372 complete and 0 interrupted iterations
running (0m03.0s), 050/100 VUs, 3712 complete and 0 interrupted iterations
running (0m04.0s), 050/100 VUs, 5023 complete and 0 interrupted iterations
running (0m05.0s), 050/100 VUs, 6345 complete and 0 interrupted iterations
running (0m06.0s), 050/100 VUs, 7680 complete and 0 interrupted iterations
running (0m07.0s), 050/100 VUs, 9025 complete and 0 interrupted iterations
running (0m08.0s), 050/100 VUs, 10208 complete and 0 interrupted iterations
running (0m09.0s), 050/100 VUs, 11465 complete and 0 interrupted iterations
running (0m10.0s), 050/100 VUs, 12651 complete and 0 interrupted iterations
running (0m11.0s), 050/100 VUs, 13791 complete and 0 interrupted iterations
running (0m12.0s), 050/100 VUs, 14996 complete and 0 interrupted iterations
running (0m13.0s), 050/100 VUs, 16395 complete and 0 interrupted iterations
running (0m14.0s), 050/100 VUs, 17652 complete and 0 interrupted iterations
running (0m15.0s), 050/100 VUs, 18969 complete and 0 interrupted iterations
running (0m16.0s), 007/100 VUs, 19067 complete and 0 interrupted iterations
running (0m17.0s), 000/100 VUs, 19074 complete and 0 interrupted iterations
running (0m18.0s), 000/100 VUs, 19074 complete and 0 interrupted iterations
running (0m19.0s), 000/100 VUs, 19074 complete and 0 interrupted iterations
running (0m20.0s), 000/100 VUs, 19074 complete and 0 interrupted iterations
running (0m21.0s), 050/100 VUs, 19339 complete and 0 interrupted iterations
running (0m22.0s), 050/100 VUs, 19534 complete and 0 interrupted iterations
running (0m23.0s), 050/100 VUs, 19767 complete and 0 interrupted iterations
running (0m24.0s), 050/100 VUs, 20037 complete and 0 interrupted iterations
running (0m25.0s), 050/100 VUs, 20288 complete and 0 interrupted iterations
running (0m26.0s), 050/100 VUs, 20566 complete and 0 interrupted iterations
running (0m27.0s), 050/100 VUs, 20828 complete and 0 interrupted iterations
running (0m28.0s), 050/100 VUs, 21098 complete and 0 interrupted iterations
running (0m29.0s), 050/100 VUs, 21400 complete and 0 interrupted iterations
running (0m30.0s), 050/100 VUs, 21671 complete and 0 interrupted iterations
running (0m31.0s), 050/100 VUs, 21957 complete and 0 interrupted iterations
running (0m32.0s), 050/100 VUs, 22171 complete and 0 interrupted iterations
running (0m33.0s), 050/100 VUs, 22418 complete and 0 interrupted iterations
running (0m34.0s), 050/100 VUs, 22678 complete and 0 interrupted iterations
running (0m35.0s), 050/100 VUs, 22958 complete and 0 interrupted iterations
running (0m36.0s), 004/100 VUs, 23009 complete and 0 interrupted iterations
     checks.........................: 100.00% 23013 out of 23013
     data_received..................: 5.3 MB  148 kB/s
     data_sent......................: 5.7 MB  158 kB/s
     http_req_duration..............: avg=17.04ms  min=408.2µs med=5.7ms   p(90)=53.65ms  p(95)=73.88ms  p(99)=129.44ms max=1.67s   
     http_req_failed................: 0.00%   0 out of 23013
     iterations.....................: 23013   639.225802/s
     vus............................: 4       min=0              max=50 
     vus_max........................: 100     min=100            max=100
running (0m36.0s), 000/100 VUs, 23013 complete and 0 interrupted iterations
```
