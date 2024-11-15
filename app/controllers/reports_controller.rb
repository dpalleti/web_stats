class ReportsController < ApplicationController
  include ReportsHelper

  # with cache

  def top_urls
    use_cache = params[:use_cache] == "true"
    service = WebStatService.new(use_cache)
    formatted_data = format_page_views(service.top_urls)
    render json: formatted_data, content_type: "application/json"
  end

  def top_referrers
    use_cache = params[:use_cache] == "true"
    service = WebStatService.new(use_cache)
    formatted_data = format_top_referrers(service.top_referrers)
    render json: formatted_data, content_type: "application/json"
  end

  # without cache

  # def top_urls
  #   formatted_data = format_page_views(WebStat.top_urls_last_5_days)
  #   render json: formatted_data, content_type: 'application/json'
  # end
  #
  # def top_referrers
  #   formatted_data = format_top_referrers(WebStat.top_referrers_for_top_urls)
  #   render json: formatted_data, content_type: 'application/json'
  # end

end
