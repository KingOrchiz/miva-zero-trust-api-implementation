import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  scenarios: {
    baseline: {
      executor: 'constant-vus',
      vus: Number(__ENV.VUS || 50),
      duration: __ENV.DURATION || '45s',
      startTime: __ENV.BASELINE_START || '0s',
      exec: 'baseline',
    },
    secured: {
      executor: 'constant-vus',
      vus: Number(__ENV.VUS || 50),
      duration: __ENV.DURATION || '45s',
      startTime: __ENV.SECURED_START || '55s',
      exec: 'secured',
    },
  },
  thresholds: {
    'http_req_failed{path:baseline}': ['rate<0.05'],
    'http_req_failed{path:secured}': ['rate<0.05'],
    'http_req_duration{path:baseline}': ['max>=0'],
    'http_req_duration{path:secured}': ['max>=0'],
  },
};

const base = __ENV.SERVICE_URL;

export function baseline() {
  const r = http.get(`${base}/v1/accounts`, {
    headers: {
      'x-demo-scope': 'accounts.read',
      'x-demo-dpop': 'true',
      'x-demo-mtls': 'true',
      'x-benchmark-response': 'true',
      'x-benchmark-bypass': 'true',
    },
    tags: { path: 'baseline' },
  });
  check(r, { 'baseline 200': (res) => res.status === 200 });
}

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
