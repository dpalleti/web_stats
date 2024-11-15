
# Web Analysis Prototype

This is a Ruby on Rails application designed for in-house web analysis, providing REST API endpoints to analyze web stats.

This project emphasized the importance of designing solutions that balance data accuracy, speed, and maintainability, showcasing my skills in backend development, database optimization, and performance testing
## Requirements

- **Ruby version**: 3.1.6
- **System dependencies**: PostgreSQL, Redis

---

## Setup

### 1. System Dependencies

- Install **PostgreSQL**:
  ```bash
  make sure you have the postgresql installed
  pg_ctl -D '/opt/homebrew/var/postgresql@14' -l logfile start  (or)
  brew services start postgresql
  ```
- Install **Redis**:
  ```bash
  brew install redis
  brew services start redis
  ```
- Install **Gem Files**:
  ```bash
    bundle install
  ```
---

### 2. Database Setup

1. **Create the database**:
   ```bash
   rails db:create
   ```

2. **Run migrations**:
   ```bash
   rails db:migrate
   ```

3. **Generate the database**:
   ```bash
   rails db:generate_dataset    
   ```


4. **Initialize materialized views**:
   ```bash
   Run the following in the rails console:
   
   Scenic.database.refresh_materialized_view(:urls_views_last_4_days, concurrently: false)
   Scenic.database.refresh_materialized_view(:top_referrers_by_days, concurrently: false)

   ```

---


### 3. Redis setup

1. **Refresh cache and set variables**:
   ```bash
   Rails.cache.clear
   
   request_count_key = "url_views_cache_key_request_count"
   Rails.cache.write(request_count_key, 0, raw: true)
   
   request_count_key = "top_referrers_cache_key_request_count"
   Rails.cache.write(request_count_key, 0, raw: true)


   ```
  Currently these initial values are set through the console -> but this logic can be shifted to the code

4. **Initialize materialized views**:

   ```bash
   
   Run the following in the rails console:
   
   Scenic.database.refresh_materialized_view(:urls_views_last_4_days, concurrently: false)
   Scenic.database.refresh_materialized_view(:top_referrers_by_days, concurrently: false)


- **Limitation**:

    - As this is just a prototype - there is no support for these views to refresh at the start of a day
   Future scope 
    - we can create a simple cron job to refresh these views and it can also be extended to cache (refresh everytime a view is refreshed)
    - Scheduled via a cron job to refresh daily at midnight. 
    - Logs output to `log/cron_log.log`.

   ```

---
### 4. Running the Application

1. **Start the server**:
   ```bash
   rails s
   ```

2. **Access the app**:
   Navigate to `http://localhost:3000` in your browser.

---

## API Endpoints

### 1. Page Views API
- **Endpoint**: `http://localhost:3000/top-urls?use_cache=true`
- **Method**: `GET`
- **Description**: Returns page views per URL grouped by day for the past 5 days. ( set use_cache = false to not use cache)

### 2. Top Referrers API
- **Endpoint**: `http://localhost:3000/top-referrers?use_cache=true`
- **Method**: `GET`
- **Description**: Returns the top 5 referrers for the top 10 URLs, grouped by day for the past 5 days. ( set use_cache = false to not use cache)

---


## Performance Testing

### Load Testing with k6


1. **Install k6**:

   ```bash

   brew install k6

   ```


2. **Run tests**:

   ```bash

   Currently performance files are at - test/performance/

   sample - k6 run url_referrers_pings_test.js --out json=top_referrers_results.json    
  

   ```


   Example scenarios:

   - **Steady load**: Sustained number of virtual users (VUs).

   - **Spike test**: Sudden increase in traffic.


---


## Services



---


### Caching


- **Redis** is used for caching.

- **Conditional Caching in Development**:

  - Create `tmp/caching-dev.txt` to enable caching.

  - Restart the server for changes to take effect.

- **Cache Refresh Mechanism**:

  - Cache updates after every 100 API requests.


---
