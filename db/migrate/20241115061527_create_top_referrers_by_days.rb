class CreateTopReferrersByDays < ActiveRecord::Migration[7.2]
  def change
    create_view :top_referrers_by_days, materialized: true
  end
end
