# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_15_062056) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "web_stats", force: :cascade do |t|
    t.text "url", null: false
    t.text "referrer"
    t.datetime "timestamp", null: false
    t.string "record_hash", limit: 32, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referrer"], name: "index_web_stats_on_referrer", where: "(referrer IS NOT NULL)"
    t.index ["timestamp", "url", "referrer"], name: "index_web_stats_on_timestamp_url_referrer"
  end

  create_view "top_referrers_by_days", materialized: true, sql_definition: <<-SQL
      WITH filtered_data AS (
           SELECT web_stats.url,
              web_stats.referrer,
              date(web_stats."timestamp") AS day
             FROM web_stats
            WHERE ((web_stats."timestamp" >= (now() - 'P5D'::interval)) AND (web_stats."timestamp" < (now() - 'P1D'::interval)))
          ), top_10_urls_per_day AS (
           SELECT filtered_data.url AS top_url,
              filtered_data.day,
              count(*) AS visits,
              rank() OVER (PARTITION BY filtered_data.day ORDER BY (count(*)) DESC) AS rank
             FROM filtered_data
            GROUP BY filtered_data.day, filtered_data.url
          ), top_10_filtered AS (
           SELECT top_10_urls_per_day.top_url,
              top_10_urls_per_day.day,
              top_10_urls_per_day.visits,
              top_10_urls_per_day.rank
             FROM top_10_urls_per_day
            WHERE (top_10_urls_per_day.rank <= 10)
          ), top_referrers AS (
           SELECT fd.url,
              fd.day,
              fd.referrer,
              t10.visits AS url_visits,
              count(*) AS referrer_visits,
              rank() OVER (PARTITION BY fd.url, fd.day ORDER BY (count(*)) DESC) AS referrer_rank
             FROM (filtered_data fd
               JOIN top_10_filtered t10 ON (((fd.day = t10.day) AND (fd.url = t10.top_url))))
            WHERE (fd.referrer IS NOT NULL)
            GROUP BY fd.day, fd.url, fd.referrer, t10.visits
          )
   SELECT top_referrers.url,
      top_referrers.day,
      top_referrers.referrer,
      top_referrers.url_visits AS visits,
      top_referrers.referrer_visits
     FROM top_referrers
    WHERE (top_referrers.referrer_rank <= 5)
    ORDER BY top_referrers.day DESC, top_referrers.url_visits DESC, top_referrers.referrer_visits DESC;
  SQL
  create_view "urls_views_last_4_days", materialized: true, sql_definition: <<-SQL
      SELECT web_stats.url,
      date(web_stats."timestamp") AS day,
      count(*) AS visits
     FROM web_stats
    WHERE ((web_stats."timestamp" >= (now() - 'P5D'::interval)) AND (web_stats."timestamp" < (now() - 'P1D'::interval)))
    GROUP BY (date(web_stats."timestamp")), web_stats.url
    ORDER BY (date(web_stats."timestamp")) DESC;
  SQL
end
