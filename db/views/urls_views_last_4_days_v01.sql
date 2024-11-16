SELECT url, DATE(timestamp) AS day, COUNT(*) AS visits
FROM web_stats
WHERE timestamp >= NOW() - INTERVAL '4 days' AND timestamp < NOW() - INTERVAL '1 day'
GROUP BY DATE(timestamp), url
ORDER BY day DESC;