class UrlsViewsLast4Day < ApplicationRecord
  self.table_name = "urls_views_last_4_days"
  def self.refresh
    Scenic.database.refresh_materialized_view(:urls_views_last_4_days, concurrently: false)
  end
  def readonly
    true
  end
end
