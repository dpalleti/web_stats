
# Web Analysis Prototype

This is a Ruby on Rails application designed for in-house web analysis, providing REST API endpoints to analyze web stats efficiently.

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

### 3. Running the Application

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

[//]: # ()
[//]: # (## Performance Testing)

[//]: # ()
[//]: # (### Load Testing with k6)

[//]: # ()
[//]: # (1. **Install k6**:)

[//]: # (   ```bash)

[//]: # (   brew install k6)

[//]: # (   ```)

[//]: # ()
[//]: # (2. **Run tests**:)

[//]: # (   ```bash)

[//]: # (   k6 run <path-to-test-script.js>)

[//]: # (   ```)

[//]: # ()
[//]: # (   Example scenarios:)

[//]: # (   - **Steady load**: Sustained number of virtual users &#40;VUs&#41;.)

[//]: # (   - **Spike test**: Sudden increase in traffic.)

[//]: # ()
[//]: # (---)

[//]: # ()
[//]: # (## Services)

[//]: # ()
[//]: # (### Materialized Views)

[//]: # ()
[//]: # (- **Scenic Gem**: Used to manage materialized views.)

[//]: # (- **Refresh Materialized View**:)

[//]: # (  ```bash)

[//]: # (  rails scenic:refresh MATERIALIZED_VIEW=web_stats_view)

[//]: # (  ```)

[//]: # (- **Automated Refresh**:)

[//]: # (  - Scheduled via a cron job to refresh daily at midnight.)

[//]: # (  - Logs output to `log/cron_log.log`.)

[//]: # ()
[//]: # (---)

[//]: # ()
[//]: # (### Caching)

[//]: # ()
[//]: # (- **Redis** is used for caching.)

[//]: # (- **Conditional Caching in Development**:)

[//]: # (  - Create `tmp/caching-dev.txt` to enable caching.)

[//]: # (  - Restart the server for changes to take effect.)

[//]: # (- **Cache Refresh Mechanism**:)

[//]: # (  - Cache updates after every 100 API requests.)

[//]: # ()
[//]: # (---)

[//]: # ()
[//]: # (## Deployment Instructions)

[//]: # ()
[//]: # (1. Set environment variables for production.)

[//]: # (2. Precompile assets:)

[//]: # (   ```bash)

[//]: # (   rails assets:precompile)

[//]: # (   ```)

[//]: # (3. Run database migrations:)

[//]: # (   ```bash)

[//]: # (   rails db:migrate RAILS_ENV=production)

[//]: # (   ```)

[//]: # (4. Start the server using a production server like Puma.)

[//]: # ()
[//]: # (---)

[//]: # ()
[//]: # (## Testing)

[//]: # ()
[//]: # (### Run the test suite:)

[//]: # (```bash)

[//]: # (bundle exec rspec)

[//]: # (```)

[//]: # ()
[//]: # (---)
