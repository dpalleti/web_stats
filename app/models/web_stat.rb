class WebStat < ApplicationRecord
  # Add validations to check data integrity
  validates :url, presence: true
  validates :created_at, presence: true
  validates :hash, presence: true, length: { is: 32 }
  # With views

  scope :current_day_data, -> { where("timestamp >= ?", Time.current.beginning_of_day) }

  def self.top_urls_last_5_days
    # Query from the materialized view for the last 4 days
    last_4_days = UrlsViewsLast4Day.select("url, day::DATE AS day, visits")

    current_day = current_day_data
                    .group("DATE(timestamp)", "url")
                    .select("url as top_url, DATE(timestamp) AS day, COUNT(*) AS visits")

    # Combine the results and order them
    from("(#{last_4_days.to_sql} UNION ALL #{current_day.to_sql}) AS combined")
      .select("day, url, visits")
      .order("day DESC, visits DESC")

  end

  def self.top_referrers_for_top_urls_last_5_days
    # Query top referrers for the top 10 URLs for the past 4 days from the materialized view
    last_4_days_top_referrers = TopReferrersByDay.select("day, url, referrer, visits , referrer_visits")

    top_10_urls_today = current_day_data
                          .group("DATE(timestamp)", "url")
                          .select("url, DATE(timestamp) AS day, COUNT(*) AS visits")
                          .order(Arel.sql("visits DESC"))
                          .limit(10)

    today_top_referrers_with_rank = current_day_data
                                      .joins("JOIN (#{top_10_urls_today.to_sql}) AS top_urls ON top_urls.day = DATE(web_stats.timestamp) AND top_urls.url = web_stats.url")
                                      .where.not(referrer: nil)
                                      .select("DATE(timestamp) AS day,
                                           web_stats.url,
                                           referrer,
                                           top_urls.visits,
                                           COUNT(*) AS referrer_visits,
                                           RANK() OVER (PARTITION BY DATE(timestamp), web_stats.url ORDER BY COUNT(*) DESC) AS referrer_rank")
                                      .group("DATE(timestamp), web_stats.url, referrer, top_urls.visits")

    today_top_referrers = from("(#{today_top_referrers_with_rank.to_sql}) AS ranked_data")
                            .where("referrer_rank <= 5")
                            .select("day, url, referrer, visits, referrer_visits")# Filter for the top 5 referrers per URL per day
                            .order("day DESC, visits DESC, referrer_visits DESC")


    combined_data = from("(#{last_4_days_top_referrers.to_sql} UNION ALL #{today_top_referrers.to_sql}) AS combined")

    # Aggregate the total url_visits over the last 5 days for each URL
    combined_data
      .select("day, url, referrer, referrer_visits, visits")
      .order("day DESC, visits DESC, referrer_visits DESC")

  end



  # Without views

  scope :last_5_days, -> { where("timestamp >= ?", 4.days.ago.beginning_of_day) }

  scope :grouped_by_day_and_url, -> {
    last_5_days
      .group("DATE(timestamp)", :url)
      .select("url as url, DATE(timestamp) AS day, COUNT(*) AS visits")
  }

  scope :grouped_by_day_and_url_with_rank, -> {
    last_5_days
      .select("url as top_url, DATE(timestamp) AS day, COUNT(*) AS visits,
                RANK() OVER (PARTITION BY DATE(timestamp) ORDER BY COUNT(*) DESC) AS rank")
      .group("url, DATE(timestamp)")
  }

  def self.page_views_per_url
    grouped_by_day_and_url.order("day DESC, visits DESC")
  end

  def self.top_referrers_for_top_urls

    top_10_urls_per_day = from("(#{grouped_by_day_and_url_with_rank.to_sql}) AS top_10_urls")
                            .where("rank <= 10")
                            .select("top_10_urls.top_url, top_10_urls.day, top_10_urls.visits")

    top_referrers_with_rank = last_5_days
                                .joins("INNER JOIN (#{top_10_urls_per_day.to_sql}) AS top_urls
                                    ON top_urls.day = DATE(timestamp) AND top_urls.top_url = url")
                                .where.not(referrer: nil)
                                .select("url, DATE(timestamp) AS day, referrer,
                                     top_urls.visits AS visits,
                                     COUNT(*) AS referrer_visits,
                                     RANK() OVER (PARTITION BY url,
                                     DATE(timestamp) ORDER BY COUNT(*) DESC) AS referrer_rank")
                                .group("url, DATE(timestamp), referrer, top_urls.visits")

    from("(#{top_referrers_with_rank.to_sql}) AS ranked_referrers")
      .where("referrer_rank <= 5")
      .select("url, day, referrer, visits, referrer_visits")
      .order("day DESC, visits DESC, referrer_visits DESC")
  end

end
