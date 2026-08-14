import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    secured_standard: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.RATE),
      timeUnit: '1s',
      duration: __ENV.DURATION,
      preAllocatedVUs: Number(__ENV.PRE_VUS),
      maxVUs: Number(__ENV.MAX_VUS),
      exec: 'secured',
      tags: { path: 'secured', standard_rate: String(__ENV.RATE) },
    },
  },
  thresholds: {
    'http_req_failed{path:secured}': ['rate<0.01'],
    'http_req_duration{path:secured}': ['max>=0'],
    dropped_iterations: ['count==0'],
  },
};

const base = __ENV.SERVICE_URL;
export function secured() {
  const r = http.get(`${base}/v1/accounts`, {
    headers: {
      'x-demo-scope': 'accounts.read',
      'x-demo-dpop': 'true',
      'x-demo-mtls': 'true',
      'x-benchmark-response': 'true',
    },
    tags: { path: 'secured' },
  });
  check(r, { 'secured 200': (res) => res.status === 200 });
}
