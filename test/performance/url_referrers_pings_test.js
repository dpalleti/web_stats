import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

export let options = {
    scenarios: {
        steady_load: {
            executor: 'constant-vus',
            vus: 10, // variable values 10, 20, 50, 100
            duration: '1m', // can be adjusted 30s, 1m, 3m, etc.
        },
        spike_test: {
            executor: 'ramping-vus',
            startVUs: 1,
            stages: [
                { duration: '30s', target: 5 },
                { duration: '30s', target: 10 },
                { duration: '30s', target: 40 },
                { duration: '30s', target: 5 }, // Ramp down to 5
            ],
        },
    },
    thresholds: {
        http_req_duration: ['p(95)<1000'], // 95% of requests should complete in < 1000ms
    },
};

const responseTime = new Trend('response_time');

export default function () {
    const res = http.get('http://0.0.0.0:3000/top-referrers');

    check(res, {
        'status is 200': (r) => r.status === 200,
        'response time < 500ms': (r) => r.timings.duration < 500,
    });

    responseTime.add(res.timings.duration);
    sleep(1); // can be adjusted - 0.5s, 1s, or 2s
}
