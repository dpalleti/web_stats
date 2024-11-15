require "digest"
require "distribution"

namespace :db do
  desc "Generate test dataset with 1 million records"
  task generate_dataset: :environment do
    desc "Generate test dataset with 1 million records"

    required_urls = %w[
      http://apple.com https://apple.com https://www.apple.com
      http://developer.apple.com http://en.wikipedia.org http://opensource.org
    ]

    required_referrers = %w[
      http://apple.com https://apple.com https://www.apple.com
      http://developer.apple.com
    ] + [ nil ]

    all_urls = required_urls + %w[
      http://docs.ruby-lang.org http://guides.rubyonrails.org http://github.com
      http://stackoverflow.com https://developer.mozilla.org http://wikipedia.org
      http://example.com http://techcrunch.com http://medium.com
      http://news.ycombinator.com http://reddit.com https://rubygems.org
      http://linuxfoundation.org http://apache.org
    ]

    all_referrers = required_referrers + %w[
      http://en.wikipedia.org http://opensource.org http://github.com
      http://stackoverflow.com http://example.com
    ]


    # day-specific traffic variations
    def generate_timestamp(days_back, base_lambda = 550)
      daily_weight = {
        0 => 0.5, # Sunday (lower traffic)
        1 => 1.0, # Monday
        2 => 1.2, # Tuesday
        3 => 1.0, # Wednesday
        4 => 1.3, # Thursday (peak traffic)
        5 => 1.0, # Friday
        6 => 0.8  # Saturday
      }

      timestamps = []
      days_back.times do |day|
        day_of_week = (Time.now - day.days).wday
        adjusted_lambda = (base_lambda * daily_weight[day_of_week]).round
        num_pings = Distribution::Poisson.rng(adjusted_lambda)

        num_pings.times do
          timestamp = day.days.ago.beginning_of_day + rand(0..23).hours + rand(0..59).minutes
          timestamps << timestamp
        end
      end

      timestamps
    end

    minimum_distinct_days = 10
    minimum_required_records = 1_000_000
    batch_size = 10_000
    id_counter = 0
    timestamps = generate_timestamp(minimum_distinct_days)

    puts "Started data generation for #{minimum_required_records} records."

    # ensuring that all the required data is present - using the combination (not necessary)
    records = []
    required_urls.each do |url|
      required_referrers.each do |referrer|
        id_counter += 1
        timestamp = timestamps.sample
        #timestamp =  Time.now - rand(5).days # generated randomly
        hash_data = { id: id_counter, url: url, referrer: referrer, timestamp: timestamp }.compact
        record_hash = Digest::MD5.hexdigest(hash_data.to_s)
        records << {
          id: id_counter,
          url: url,
          referrer: referrer,
          timestamp: timestamp,
          record_hash: record_hash
        }
      end
    end
    WebStat.insert_all(records) # inserting required records

    while id_counter < minimum_required_records
      records = []
      timestamps = generate_timestamp(minimum_distinct_days)

      batch_size.times do |i|
        id_counter += 1
        url = all_urls.sample
        referrer = all_referrers.sample

        timestamp = timestamps.sample
        #timestamp =  Time.now - rand(10).days # generated randomly

        hash_data = { url: url, referrer: referrer, timestamp: timestamp }.compact
        record_hash = Digest::MD5.hexdigest(hash_data.to_s)

        records << {
          id: id_counter,
          url: url,
          referrer: referrer,
          timestamp: timestamp,
          record_hash: record_hash
        }
      end

      WebStat.insert_all(records)
      puts "Inserted #{id_counter} records."
    end
    puts "Data generation complete"

  end
end
