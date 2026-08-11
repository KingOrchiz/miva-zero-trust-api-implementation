# k6 Matched Baseline vs Secured Policy-Path Benchmark

This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.

```text
running (0m00.9s), 050/100 VUs, 243 complete and 0 interrupted iterations
running (0m01.9s), 050/100 VUs, 470 complete and 0 interrupted iterations
running (0m02.9s), 050/100 VUs, 735 complete and 0 interrupted iterations
running (0m03.9s), 050/100 VUs, 1003 complete and 0 interrupted iterations
running (0m04.9s), 050/100 VUs, 1247 complete and 0 interrupted iterations
running (0m05.9s), 050/100 VUs, 1510 complete and 0 interrupted iterations
running (0m06.9s), 050/100 VUs, 1782 complete and 0 interrupted iterations
running (0m07.9s), 050/100 VUs, 2060 complete and 0 interrupted iterations
running (0m08.9s), 050/100 VUs, 2284 complete and 0 interrupted iterations
running (0m09.9s), 050/100 VUs, 2556 complete and 0 interrupted iterations
running (0m10.9s), 050/100 VUs, 2841 complete and 0 interrupted iterations
running (0m11.9s), 050/100 VUs, 3115 complete and 0 interrupted iterations
running (0m13.0s), 050/100 VUs, 3320 complete and 0 interrupted iterations
running (0m13.9s), 050/100 VUs, 3596 complete and 0 interrupted iterations
running (0m14.9s), 050/100 VUs, 3868 complete and 0 interrupted iterations
running (0m15.9s), 003/100 VUs, 3926 complete and 0 interrupted iterations
running (0m16.9s), 000/100 VUs, 3929 complete and 0 interrupted iterations
running (0m17.9s), 000/100 VUs, 3929 complete and 0 interrupted iterations
running (0m18.9s), 000/100 VUs, 3929 complete and 0 interrupted iterations
running (0m19.9s), 000/100 VUs, 3929 complete and 0 interrupted iterations
running (0m20.9s), 050/100 VUs, 5178 complete and 0 interrupted iterations
running (0m21.9s), 050/100 VUs, 6249 complete and 0 interrupted iterations
running (0m22.9s), 050/100 VUs, 7630 complete and 0 interrupted iterations
running (0m23.9s), 050/100 VUs, 8738 complete and 0 interrupted iterations
running (0m24.9s), 050/100 VUs, 10131 complete and 0 interrupted iterations
running (0m25.9s), 050/100 VUs, 11398 complete and 0 interrupted iterations
running (0m26.9s), 050/100 VUs, 12777 complete and 0 interrupted iterations
running (0m27.9s), 050/100 VUs, 14002 complete and 0 interrupted iterations
running (0m28.9s), 050/100 VUs, 15176 complete and 0 interrupted iterations
running (0m29.9s), 050/100 VUs, 16568 complete and 0 interrupted iterations
running (0m30.9s), 050/100 VUs, 17899 complete and 0 interrupted iterations
running (0m31.9s), 050/100 VUs, 19254 complete and 0 interrupted iterations
running (0m32.9s), 050/100 VUs, 20637 complete and 0 interrupted iterations
running (0m33.9s), 050/100 VUs, 21976 complete and 0 interrupted iterations
running (0m34.9s), 050/100 VUs, 22986 complete and 0 interrupted iterations
running (0m35.9s), 004/100 VUs, 23092 complete and 0 interrupted iterations
     checks.........................: 100.00% 23096 out of 23096
     data_received..................: 5.4 MB  149 kB/s
     data_sent......................: 5.7 MB  158 kB/s
     http_req_duration..............: avg=17.47ms  min=407.7µs med=5.5ms    p(90)=55.5ms   p(95)=76.88ms  p(99)=141.08ms max=1.68s   
     http_req_failed................: 0.00%   0 out of 23096
     iterations.....................: 23096   641.727843/s
     vus............................: 4       min=0              max=50 
     vus_max........................: 100     min=100            max=100
running (0m36.0s), 000/100 VUs, 23096 complete and 0 interrupted iterations
```
