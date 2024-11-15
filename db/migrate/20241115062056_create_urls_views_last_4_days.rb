class CreateUrlsViewsLast4Days < ActiveRecord::Migration[7.2]
  def change
    create_view :urls_views_last_4_days, materialized: true
  end
end
