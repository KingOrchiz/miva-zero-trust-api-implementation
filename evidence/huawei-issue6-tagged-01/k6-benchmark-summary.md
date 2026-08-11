# k6 Matched Baseline vs Secured Policy-Path Benchmark

This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.

```text
running (0m01.0s), 050/100 VUs, 2040 complete and 0 interrupted iterations
running (0m02.0s), 050/100 VUs, 4835 complete and 0 interrupted iterations
running (0m03.0s), 050/100 VUs, 7560 complete and 0 interrupted iterations
running (0m04.0s), 050/100 VUs, 10206 complete and 0 interrupted iterations
running (0m05.0s), 050/100 VUs, 13058 complete and 0 interrupted iterations
running (0m06.0s), 050/100 VUs, 15714 complete and 0 interrupted iterations
running (0m07.0s), 050/100 VUs, 18484 complete and 0 interrupted iterations
running (0m08.0s), 050/100 VUs, 20782 complete and 0 interrupted iterations
running (0m09.0s), 050/100 VUs, 23519 complete and 0 interrupted iterations
running (0m10.0s), 050/100 VUs, 26145 complete and 0 interrupted iterations
running (0m11.0s), 050/100 VUs, 28703 complete and 0 interrupted iterations
running (0m12.0s), 050/100 VUs, 31312 complete and 0 interrupted iterations
running (0m13.0s), 050/100 VUs, 34129 complete and 0 interrupted iterations
running (0m14.0s), 050/100 VUs, 36746 complete and 0 interrupted iterations
running (0m15.0s), 050/100 VUs, 39559 complete and 0 interrupted iterations
running (0m16.0s), 004/100 VUs, 39661 complete and 0 interrupted iterations
running (0m17.0s), 000/100 VUs, 39665 complete and 0 interrupted iterations
running (0m18.0s), 000/100 VUs, 39665 complete and 0 interrupted iterations
running (0m19.0s), 000/100 VUs, 39665 complete and 0 interrupted iterations
running (0m20.0s), 000/100 VUs, 39665 complete and 0 interrupted iterations
running (0m21.0s), 050/100 VUs, 40467 complete and 0 interrupted iterations
running (0m22.0s), 050/100 VUs, 41295 complete and 0 interrupted iterations
running (0m23.0s), 050/100 VUs, 42092 complete and 0 interrupted iterations
running (0m24.0s), 050/100 VUs, 42859 complete and 0 interrupted iterations
running (0m25.0s), 050/100 VUs, 43677 complete and 0 interrupted iterations
running (0m26.0s), 050/100 VUs, 44477 complete and 0 interrupted iterations
running (0m27.0s), 050/100 VUs, 45330 complete and 0 interrupted iterations
running (0m28.0s), 050/100 VUs, 46122 complete and 0 interrupted iterations
running (0m29.0s), 050/100 VUs, 46954 complete and 0 interrupted iterations
running (0m30.0s), 050/100 VUs, 47801 complete and 0 interrupted iterations
running (0m31.0s), 050/100 VUs, 48625 complete and 0 interrupted iterations
running (0m32.0s), 050/100 VUs, 49433 complete and 0 interrupted iterations
running (0m33.0s), 050/100 VUs, 50217 complete and 0 interrupted iterations
running (0m34.0s), 050/100 VUs, 51052 complete and 0 interrupted iterations
running (0m35.0s), 050/100 VUs, 51845 complete and 0 interrupted iterations
running (0m36.0s), 003/100 VUs, 51912 complete and 0 interrupted iterations
     checks.........................: 100.00% 51915 out of 51915
     data_received..................: 12 MB   335 kB/s
     data_sent......................: 13 MB   353 kB/s
     http_req_duration..............: avg=6.65ms   min=291.61µs med=2.4ms    p(90)=16.19ms  p(95)=22.56ms  p(99)=34.87ms max=3.33s   
     http_req_failed................: 0.00%   0 out of 51915
     iterations.....................: 51915   1442.483903/s
     vus............................: 3       min=0              max=50 
     vus_max........................: 100     min=100            max=100
running (0m36.0s), 000/100 VUs, 51915 complete and 0 interrupted iterations
```
