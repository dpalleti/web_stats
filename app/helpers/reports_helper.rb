module ReportsHelper
  def format_page_views(data)
    formatted_data = data.group_by { |record| record.respond_to?(:day) ? record.day : record["day"] }
                         .transform_values do |records|
      records.map do |record|
        {
          url: record.respond_to?(:url) ? record.url : record["url"],
          visits: record.respond_to?(:visits) ? record.visits : record["visits"]
        }
      end
    end

    { status: 200, data: formatted_data }
  end

  def format_top_referrers(data)
    formatted_data = data.group_by { |record| record.respond_to?(:day) ? record.day : record["day"] }
                         .transform_values do |records|
      records.group_by { |record| record.respond_to?(:url) ? record.url : record["url"] }
             .map do |url, url_records|
        {
          url: url,
          visits: url_records.first.respond_to?(:visits) ? url_records.first.visits : url_records.first["visits"],
          referrers: url_records.map do |referrer_record|
            {
              url: referrer_record.respond_to?(:referrer) ? referrer_record.referrer : referrer_record["referrer"],
              visits: referrer_record.respond_to?(:referrer_visits) ? referrer_record.referrer_visits : referrer_record["referrer_visits"]
            }
          end
        }
      end
    end

    { status: 200, data: formatted_data }
  end
end
