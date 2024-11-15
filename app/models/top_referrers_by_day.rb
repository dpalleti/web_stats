class TopReferrersByDay < ApplicationRecord
  self.table_name = "top_referrers_by_days"

  def self.refresh
    Scenic.database.refresh_materialized_view(:top_referrers_by_days, concurrently: false, cascade: false)
  end
end
