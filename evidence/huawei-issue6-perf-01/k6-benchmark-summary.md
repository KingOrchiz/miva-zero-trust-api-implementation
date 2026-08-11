# k6 Matched Baseline vs Secured Policy-Path Benchmark

This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.

```text
running (0m01.0s), 050/100 VUs, 2414 complete and 0 interrupted iterations
running (0m02.0s), 050/100 VUs, 5214 complete and 0 interrupted iterations
running (0m03.0s), 050/100 VUs, 7928 complete and 0 interrupted iterations
running (0m04.0s), 050/100 VUs, 10772 complete and 0 interrupted iterations
running (0m05.0s), 050/100 VUs, 13491 complete and 0 interrupted iterations
running (0m06.0s), 050/100 VUs, 16233 complete and 0 interrupted iterations
running (0m07.0s), 050/100 VUs, 18867 complete and 0 interrupted iterations
running (0m08.0s), 050/100 VUs, 21498 complete and 0 interrupted iterations
running (0m09.0s), 050/100 VUs, 24152 complete and 0 interrupted iterations
running (0m10.0s), 050/100 VUs, 26987 complete and 0 interrupted iterations
running (0m11.0s), 050/100 VUs, 29678 complete and 0 interrupted iterations
running (0m12.0s), 050/100 VUs, 32310 complete and 0 interrupted iterations
running (0m13.0s), 050/100 VUs, 34827 complete and 0 interrupted iterations
running (0m14.0s), 050/100 VUs, 37555 complete and 0 interrupted iterations
running (0m15.0s), 050/100 VUs, 40127 complete and 0 interrupted iterations
running (0m16.0s), 050/100 VUs, 42848 complete and 0 interrupted iterations
running (0m17.0s), 050/100 VUs, 45347 complete and 0 interrupted iterations
running (0m18.0s), 050/100 VUs, 48236 complete and 0 interrupted iterations
running (0m19.0s), 050/100 VUs, 51086 complete and 0 interrupted iterations
running (0m20.0s), 050/100 VUs, 53803 complete and 0 interrupted iterations
running (0m21.0s), 006/100 VUs, 53917 complete and 0 interrupted iterations
running (0m22.0s), 000/100 VUs, 53923 complete and 0 interrupted iterations
running (0m23.0s), 000/100 VUs, 53923 complete and 0 interrupted iterations
running (0m24.0s), 000/100 VUs, 53923 complete and 0 interrupted iterations
running (0m25.0s), 000/100 VUs, 53923 complete and 0 interrupted iterations
running (0m26.0s), 050/100 VUs, 54452 complete and 0 interrupted iterations
running (0m27.0s), 050/100 VUs, 55221 complete and 0 interrupted iterations
running (0m28.0s), 050/100 VUs, 56012 complete and 0 interrupted iterations
running (0m29.0s), 050/100 VUs, 56817 complete and 0 interrupted iterations
running (0m30.0s), 050/100 VUs, 57660 complete and 0 interrupted iterations
running (0m31.0s), 050/100 VUs, 58432 complete and 0 interrupted iterations
running (0m32.0s), 050/100 VUs, 59263 complete and 0 interrupted iterations
running (0m33.0s), 050/100 VUs, 60013 complete and 0 interrupted iterations
running (0m34.0s), 050/100 VUs, 60791 complete and 0 interrupted iterations
running (0m35.0s), 050/100 VUs, 61607 complete and 0 interrupted iterations
running (0m36.0s), 050/100 VUs, 62426 complete and 0 interrupted iterations
running (0m37.0s), 050/100 VUs, 63203 complete and 0 interrupted iterations
running (0m38.0s), 050/100 VUs, 64015 complete and 0 interrupted iterations
running (0m39.0s), 050/100 VUs, 64839 complete and 0 interrupted iterations
running (0m40.0s), 050/100 VUs, 65654 complete and 0 interrupted iterations
running (0m41.0s), 050/100 VUs, 66195 complete and 0 interrupted iterations
running (0m42.0s), 050/100 VUs, 66956 complete and 0 interrupted iterations
running (0m43.0s), 050/100 VUs, 67757 complete and 0 interrupted iterations
running (0m44.0s), 050/100 VUs, 68522 complete and 0 interrupted iterations
running (0m45.0s), 050/100 VUs, 69314 complete and 0 interrupted iterations
running (0m46.0s), 001/100 VUs, 69380 complete and 0 interrupted iterations
     checks.........................: 100.00% 69381 out of 69381
     data_received..................: 16 MB   348 kB/s
     data_sent......................: 17 MB   368 kB/s
     http_req_duration..............: avg=6.73ms   min=292.37µs med=2.32ms   p(90)=15.46ms  p(95)=21.6ms   p(99)=35.58ms max=6.6s   
     http_req_failed................: 0.00%   0 out of 69381
     iterations.....................: 69381   1499.061362/s
     vus............................: 1       min=0              max=50 
     vus_max........................: 100     min=100            max=100
running (0m46.3s), 000/100 VUs, 69381 complete and 0 interrupted iterations
```
