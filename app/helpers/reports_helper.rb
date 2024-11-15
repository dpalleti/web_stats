module ReportsHelper
  def format_page_views(data)
    formatted_data = data.group_by(&:day).transform_values do |records|
      records.map { |record| { url: record.url, visits: record.visits } }
    end
    { status: 200, data: formatted_data }
  end

  def format_top_referrers(data)
    formatted_data = data.group_by(&:day).transform_values do |records|
      records.group_by(&:url).map do |url, url_records|
        {
          url: url,
          visits: url_records.first.visits,
          referrers: url_records.map do |referrer_record|
            {
              url: referrer_record.referrer,
              visits: referrer_record.referrer_visits
            }
          end
        }
      end
    end

    { status: 200, data: formatted_data }
  end

end