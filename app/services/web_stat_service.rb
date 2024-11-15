# app/services/web_stat_service.rb
require "ostruct"

class WebStatService
  CACHE_REQUEST_THRESHOLD = 100

  def initialize(use_cache)
    @use_cache = use_cache
  end

  def top_urls
    fetch_or_compute(:url_views_cache_key, :top_urls_last_5_days)
  end

  def top_referrers
    fetch_or_compute(:top_referrers_cache_key, :top_referrers_for_top_urls_last_5_days)
  end

  private

  def fetch_or_compute(cache_key_name, compute_method)
    if @use_cache
      refresh_cache_if_needed(cache_key_name)
      cache_key = WebStat.send(cache_key_name)
      Rails.cache.fetch(cache_key) do
        WebStat.send(compute_method).as_json
      end
    else
      WebStat.send(compute_method)
    end
  end

  def refresh_cache_if_needed(cache_key_name)
    request_count_key = "#{cache_key_name}_request_count"

    request_count = Rails.cache.increment(request_count_key)

    if request_count == 1  # cache init or refresh
      Rails.logger.info "[CACHE REFRESH/INIT] Refreshing cache for #{cache_key_name} after #{request_count} requests"
      cache_key = WebStat.send(cache_key_name)
      data = compute_cache_data(cache_key_name)
      Rails.cache.write(cache_key, data.as_json)
      Rails.cache.write(request_count_key, request_count, raw: true)
    end

    Rails.logger.info "[CACHE COUNTER] Incremented request count for #{request_count_key}: #{request_count}"
    if request_count >= CACHE_REQUEST_THRESHOLD
      Rails.cache.write(request_count_key, 0, raw: true) # Reset counter
    end

  end

  def compute_cache_data(cache_key_name)
    case cache_key_name
    when :url_views_cache_key
      WebStat.top_urls_last_5_days
    when :top_referrers_cache_key
      WebStat.top_referrers_for_top_urls_last_5_days
    end
  end
end
