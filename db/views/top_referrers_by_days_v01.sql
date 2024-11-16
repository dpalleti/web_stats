WITH filtered_data AS (
    SELECT
        url,
        referrer,
    DATE(timestamp) AS day
FROM
    web_stats
WHERE timestamp >= NOW() - INTERVAL '4 days' AND timestamp < NOW() - INTERVAL '1 day'
    ),

    top_10_urls_per_day AS (
SELECT
    url AS top_url,
    day,
    COUNT(*) AS visits,
    RANK() OVER (PARTITION BY day ORDER BY COUNT(*) DESC) AS rank
FROM
    filtered_data
GROUP BY
    day, url
    ),

    top_10_filtered AS (
SELECT *
FROM top_10_urls_per_day
WHERE rank <= 10
    ),

    top_referrers AS (
SELECT
    fd.url,
    fd.day,
    fd.referrer,
    t10.visits AS url_visits,
    COUNT(*) AS referrer_visits,
    RANK() OVER (PARTITION BY fd.url, fd.day ORDER BY COUNT(*) DESC) AS referrer_rank
FROM
    filtered_data fd
    JOIN
    top_10_filtered t10 ON
    fd.day = t10.day AND fd.url = t10.top_url
WHERE
    fd.referrer IS NOT NULL
GROUP BY
    fd.day, fd.url, fd.referrer, t10.visits
    )
SELECT
    url,
    day,
    referrer,
    url_visits AS visits,
    referrer_visits
FROM
    top_referrers
WHERE
    referrer_rank <= 5
ORDER BY
    day DESC, visits DESC, referrer_visits DESC;
