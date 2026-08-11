# k6 Matched Baseline vs Secured Policy-Path Benchmark

This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.

```text
running (0m01.0s), 050/100 VUs, 857 complete and 0 interrupted iterations
running (0m02.0s), 050/100 VUs, 1810 complete and 0 interrupted iterations
running (0m03.0s), 050/100 VUs, 2775 complete and 0 interrupted iterations
running (0m04.0s), 050/100 VUs, 3794 complete and 0 interrupted iterations
running (0m05.0s), 050/100 VUs, 4702 complete and 0 interrupted iterations
running (0m06.0s), 050/100 VUs, 5652 complete and 0 interrupted iterations
running (0m07.0s), 050/100 VUs, 6563 complete and 0 interrupted iterations
running (0m08.0s), 050/100 VUs, 7535 complete and 0 interrupted iterations
running (0m09.0s), 050/100 VUs, 8546 complete and 0 interrupted iterations
running (0m10.0s), 050/100 VUs, 9529 complete and 0 interrupted iterations
running (0m11.0s), 050/100 VUs, 10388 complete and 0 interrupted iterations
running (0m12.0s), 050/100 VUs, 11412 complete and 0 interrupted iterations
running (0m13.0s), 050/100 VUs, 12446 complete and 0 interrupted iterations
running (0m14.0s), 050/100 VUs, 13406 complete and 0 interrupted iterations
running (0m15.0s), 050/100 VUs, 14337 complete and 0 interrupted iterations
running (0m16.0s), 000/100 VUs, 14395 complete and 0 interrupted iterations
running (0m17.0s), 000/100 VUs, 14395 complete and 0 interrupted iterations
running (0m18.0s), 000/100 VUs, 14395 complete and 0 interrupted iterations
running (0m19.0s), 000/100 VUs, 14395 complete and 0 interrupted iterations
running (0m20.0s), 000/100 VUs, 14395 complete and 0 interrupted iterations
running (0m21.0s), 050/100 VUs, 17099 complete and 0 interrupted iterations
running (0m22.0s), 050/100 VUs, 19719 complete and 0 interrupted iterations
running (0m23.0s), 050/100 VUs, 22575 complete and 0 interrupted iterations
running (0m24.0s), 050/100 VUs, 25434 complete and 0 interrupted iterations
running (0m25.0s), 050/100 VUs, 28031 complete and 0 interrupted iterations
running (0m26.0s), 050/100 VUs, 30688 complete and 0 interrupted iterations
running (0m27.0s), 050/100 VUs, 33541 complete and 0 interrupted iterations
running (0m28.0s), 050/100 VUs, 36320 complete and 0 interrupted iterations
running (0m29.0s), 050/100 VUs, 39214 complete and 0 interrupted iterations
running (0m30.0s), 050/100 VUs, 41971 complete and 0 interrupted iterations
running (0m31.0s), 050/100 VUs, 44635 complete and 0 interrupted iterations
running (0m32.0s), 050/100 VUs, 47464 complete and 0 interrupted iterations
running (0m33.0s), 050/100 VUs, 50303 complete and 0 interrupted iterations
running (0m34.0s), 050/100 VUs, 53060 complete and 0 interrupted iterations
running (0m35.0s), 050/100 VUs, 55883 complete and 0 interrupted iterations
running (0m36.0s), 006/100 VUs, 55965 complete and 0 interrupted iterations
     checks.........................: 100.00% 55971 out of 55971
     data_received..................: 13 MB   360 kB/s
     data_sent......................: 14 MB   379 kB/s
     http_req_duration..............: avg=6.51ms   min=284.22µs med=2.54ms   p(90)=15.03ms  p(95)=19.79ms  p(99)=31.51ms  max=1.68s  
     http_req_failed................: 0.00%   0 out of 55971
     iterations.....................: 55971   1549.563042/s
     vus............................: 6       min=0              max=50 
     vus_max........................: 100     min=100            max=100
running (0m36.1s), 000/100 VUs, 55971 complete and 0 interrupted iterations
```
