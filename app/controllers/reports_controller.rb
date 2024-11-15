class ReportsController < ApplicationController
  include ReportsHelper
  def top_urls
    formatted_data = format_page_views(WebStat.top_urls_last_5_days)
    render json: formatted_data, content_type: 'application/json'
  end

  def top_referrers
    formatted_data = format_top_referrers(WebStat.top_referrers_for_top_urls)
    render json: formatted_data, content_type: 'application/json'
  end

end
