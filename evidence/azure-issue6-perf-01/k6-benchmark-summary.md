# k6 Matched Baseline vs Secured Policy-Path Benchmark

This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.

```text
running (0m00.9s), 050/100 VUs, 977 complete and 0 interrupted iterations
running (0m01.9s), 050/100 VUs, 1942 complete and 0 interrupted iterations
running (0m02.9s), 050/100 VUs, 3124 complete and 0 interrupted iterations
running (0m03.9s), 050/100 VUs, 4498 complete and 0 interrupted iterations
running (0m04.9s), 050/100 VUs, 5838 complete and 0 interrupted iterations
running (0m05.9s), 050/100 VUs, 7203 complete and 0 interrupted iterations
running (0m06.9s), 050/100 VUs, 8183 complete and 0 interrupted iterations
running (0m07.9s), 050/100 VUs, 9512 complete and 0 interrupted iterations
running (0m08.9s), 050/100 VUs, 10849 complete and 0 interrupted iterations
running (0m09.9s), 050/100 VUs, 11859 complete and 0 interrupted iterations
running (0m10.9s), 050/100 VUs, 13148 complete and 0 interrupted iterations
running (0m11.9s), 050/100 VUs, 14428 complete and 0 interrupted iterations
running (0m12.9s), 050/100 VUs, 15764 complete and 0 interrupted iterations
running (0m13.9s), 050/100 VUs, 17088 complete and 0 interrupted iterations
running (0m14.9s), 050/100 VUs, 18403 complete and 0 interrupted iterations
running (0m15.9s), 050/100 VUs, 19405 complete and 0 interrupted iterations
running (0m16.9s), 050/100 VUs, 20692 complete and 0 interrupted iterations
running (0m17.9s), 050/100 VUs, 21995 complete and 0 interrupted iterations
running (0m18.9s), 050/100 VUs, 23383 complete and 0 interrupted iterations
running (0m19.9s), 050/100 VUs, 24642 complete and 0 interrupted iterations
running (0m20.9s), 011/100 VUs, 24797 complete and 0 interrupted iterations
running (0m21.9s), 000/100 VUs, 24808 complete and 0 interrupted iterations
running (0m22.9s), 000/100 VUs, 24808 complete and 0 interrupted iterations
running (0m23.9s), 000/100 VUs, 24808 complete and 0 interrupted iterations
running (0m24.9s), 000/100 VUs, 24808 complete and 0 interrupted iterations
running (0m25.9s), 050/100 VUs, 24813 complete and 0 interrupted iterations
running (0m26.9s), 050/100 VUs, 24948 complete and 0 interrupted iterations
running (0m27.9s), 050/100 VUs, 25207 complete and 0 interrupted iterations
running (0m28.9s), 050/100 VUs, 25477 complete and 0 interrupted iterations
running (0m29.9s), 050/100 VUs, 25702 complete and 0 interrupted iterations
running (0m30.9s), 050/100 VUs, 25960 complete and 0 interrupted iterations
running (0m31.9s), 050/100 VUs, 26205 complete and 0 interrupted iterations
running (0m32.9s), 050/100 VUs, 26470 complete and 0 interrupted iterations
running (0m33.9s), 050/100 VUs, 26702 complete and 0 interrupted iterations
running (0m34.9s), 050/100 VUs, 26970 complete and 0 interrupted iterations
running (0m35.9s), 050/100 VUs, 27242 complete and 0 interrupted iterations
running (0m36.9s), 050/100 VUs, 27478 complete and 0 interrupted iterations
running (0m37.9s), 050/100 VUs, 27722 complete and 0 interrupted iterations
running (0m38.9s), 050/100 VUs, 28005 complete and 0 interrupted iterations
running (0m39.9s), 050/100 VUs, 28236 complete and 0 interrupted iterations
running (0m40.9s), 050/100 VUs, 28515 complete and 0 interrupted iterations
running (0m41.9s), 050/100 VUs, 28771 complete and 0 interrupted iterations
running (0m42.9s), 050/100 VUs, 29044 complete and 0 interrupted iterations
running (0m43.9s), 050/100 VUs, 29313 complete and 0 interrupted iterations
running (0m44.9s), 050/100 VUs, 29583 complete and 0 interrupted iterations
running (0m45.9s), 004/100 VUs, 29652 complete and 0 interrupted iterations
     checks.........................: 100.00% 29656 out of 29656
     data_received..................: 6.9 MB  150 kB/s
     data_sent......................: 7.3 MB  159 kB/s
     http_req_duration..............: avg=19.3ms   min=419.7µs med=5.7ms    p(90)=57.46ms p(95)=80.74ms  p(99)=145.5ms  max=1.84s  
     http_req_failed................: 0.00%   0 out of 29656
     iterations.....................: 29656   644.298386/s
     vus............................: 4       min=0              max=50 
     vus_max........................: 100     min=100            max=100
running (0m46.0s), 000/100 VUs, 29656 complete and 0 interrupted iterations
```
