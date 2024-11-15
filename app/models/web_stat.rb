class WebStat < ApplicationRecord
  # Add validations to check data integrity
  validates :url, presence: true
  validates :created_at, presence: true
  validates :hash, presence: true, length: { is: 32 }

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
