class CreateWebStats < ActiveRecord::Migration[7.2]
  def change
    create_table :web_stats do |t|
      t.text :url, null: false
      t.text :referrer
      t.datetime :timestamp, null: false
      t.string :record_hash, limit: 31, null: false

      t.timestamps
    end
    # Adding a partial index on the referrer column where referrer is not null
    add_index :web_stats, :referrer, name: "index_web_stats_on_referrer", where: "referrer IS NOT NULL"

    # Adding a composite index on timestamp, url, and referrer columns
    add_index :web_stats, [:timestamp, :url, :referrer], name: "index_web_stats_on_timestamp_url_referrer"

  end
end
