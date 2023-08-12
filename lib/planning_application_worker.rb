# frozen_string_literal: true

class PlanningApplicationWorker
  # Update to use
  # http://planit.org.uk/find/areas/json

  def initialize(end_date = Date.current)
    @end_date = end_date
  end

  def process!
    new_planning_applications = local_authorities.map do |la|
      get_authority(la)
    end.flatten
    add_applications new_planning_applications
  end

  def local_authorities
    Rails.cache.fetch("PlanningApplicationWorker.local_authorities", expires_in: 1.day) do
      JSON.parse(
        Excon.new(
          Rails.application.config.planning_areas_url,
          headers: { "Accept" => Mime[:json].to_s, "Content-Type" => Mime[:json].to_s },
          expects: 200, retry_limit: 5
        ).request(
          method: :get, query: api_query.merge(
            select: :area_name, area_type: :active
          )
        ).body
      )["records"].map { |record| record["area_name"] }
    end
  end

  private

  def conn
    @conn ||=
      Excon.new(
        Rails.application.config.planning_applications_url,
        headers: { "Accept" => Mime[:json].to_s, "Content-Type" => Mime[:json].to_s },
        expects: 200, retry_limit: 0
      )
  end

  def ratelimit
    @ratelimit ||= Ratelimit.new("planning_applications")
  end

  def conn_request(req)
    Retryable.retryable(tries: 5, on: [JSON::ParserError, Excon::Error]) do
      ratelimit.exec_within_threshold "req", threshold: 10, interval: 59 do
        ratelimit.add("req")
        JSON.parse(conn.request(req).body)
      end
    end
  rescue StandardError => e
    Rollbar.debug(e, "Issue with req: #{req}")
    { "records" => [] }
  end

  def get_authority(authority)
    total = conn_request(generate_authority_requests(authority))
    if total["count"] == 500
      multi_total = (0..2).map do |days_offset|
        conn_request(generate_authority_requests(authority, days_offset))
      end
      multi_total.map { |resp| resp["records"] }
    else
      total["records"]
    end
  end

  def add_applications(planning_applications)
    PlanningApplication.transaction do
      planning_applications.each do |remote_pa|
        next unless remote_pa["uid"] && remote_pa["url"]

        db_app = PlanningApplication
                 .find_or_initialize_by uid: remote_pa["uid"], authority_name: remote_pa["area_name"]
        %i[address postcode description url start_date app_size app_state app_type associated_id last_difference].each do |attr|
          db_app[attr] = remote_pa[attr.to_s]
        end
        db_app.location = "POINT(#{remote_pa['location_x']} #{remote_pa['location_y']})"
        db_app.save!
      end
    end
  end

  def generate_authority_requests(authority, days_offset = nil)
    dates = { start_date: (@end_date - 14.days), end_date: @end_date }

    if days_offset
      dates = { start_date: (@end_date - 14.days + (5 * days_offset).days),
                end_date: (@end_date - 10.days + (5 * days_offset).days) }
    end
    {
      method: :get, query:
      api_query.merge(
        auth: authority,
        start_date: dates[:start_date].to_date.to_s,
        end_date: dates[:end_date].to_date.to_s,
        sort: "-start_date"
      )
    }
  end

  def api_query
    @api_query ||=
      if SiteConfig.first.planit_api_key
        { apikey: SiteConfig.first.planit_api_key, pg_sz: 500 }
      else
        { pg_sz: 500 }
      end
  end
end
