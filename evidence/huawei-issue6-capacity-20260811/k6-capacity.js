import http from 'k6/http';
import { check } from 'k6';

const rates = [500, 1000, 2000, 5000, 10000];
const scenarios = {};
for (let i = 0; i < rates.length; i++) {
  const name = `rps_${rates[i]}`;
  scenarios[name] = {
    executor: 'constant-arrival-rate',
    rate: rates[i],
    timeUnit: '1s',
    duration: '10s',
    startTime: `${i * 15}s`,
    preAllocatedVUs: Math.min(1200, Math.max(100, Math.ceil(rates[i] * 0.12))),
    maxVUs: 1600,
    exec: 'secured',
    tags: { offered_rate: String(rates[i]) },
  };
}

const thresholds = {};
for (const rate of rates) {
  thresholds[`http_req_duration{offered_rate:${rate}}`] = ['max>=0'];
  thresholds[`http_req_failed{offered_rate:${rate}}`] = ['rate<1'];
}

export const options = { scenarios, thresholds };
const base = __ENV.SERVICE_URL;

export function secured() {
  const r = http.get(`${base}/v1/accounts`, {
    headers: {
      'x-demo-scope': 'accounts.read',
      'x-demo-dpop': 'true',
      'x-demo-mtls': 'true',
      'x-benchmark-response': 'true',
    },
  });
  check(r, { 'secured 200': (res) => res.status === 200 });
}
