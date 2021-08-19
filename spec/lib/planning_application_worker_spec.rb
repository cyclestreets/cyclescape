# frozen_string_literal: true

require "spec_helper"
require "planning_filter"

describe PlanningApplicationWorker do
  before do
    stub_const("PlanningFilter::LOCAL_AUTHORITIES", %w[London Cambridge])
  end

  let(:planning_record_alt) { planning_record.merge("uid" => "345") }

  let!(:london_req) do
    no_url = planning_record.dup.tap { |pr| pr.delete "url" }
    stub_request(:get, Rails.application.config.planning_applications_url)
      .with(query: { apikey: "planit_api_key", auth: "London", start_date: (Date.today - 14.days).to_s, end_date: Date.today, sort: "-start_date", pg_sz: 500 },
            headers: { "Accept" => "application/json", "Content-Type" => "application/json", "Host" => "www.planit.org.uk:443" })
      .to_return(status: 200, body: {
        "count" => 1,
        "page_size" => 500,
        "records" => [no_url, planning_record_alt]
      }.to_json)
  end

  let!(:cam_req) do
    no_lat = planning_record.dup.merge("uid" => "123").tap { |pr| pr.delete "lng" }
    no_uid = planning_record.dup.tap { |pr| pr.delete "uid" }
    stub_request(:get, Rails.application.config.planning_applications_url)
      .with(query: { apikey: "planit_api_key", auth: "Cambridge", start_date: (Date.today - 14.days).to_s, end_date: Date.today, sort: "-start_date", pg_sz: 500 },
            headers: { "Accept" => "application/json", "Content-Type" => "application/json", "Host" => "www.planit.org.uk:443" })
      .to_return(status: 200, body: {
        "count" => 1, "page_size" => 500, "records" => [no_uid, planning_record, no_lat]
      }.to_json)
  end

  let(:planning_record) do
    {
      "address"        => "163 - 167 Mill Road Cambridge Cambridgeshire CB1 3AN",
      "altid"          => nil,
      "app_size"       => "Small",
      "app_state"      => "Undecided",
      "app_type"       => "Conditions",
      "associated_id"  => "P131535",
      "area_id"        => 22,
      "area_name"      => "Cambridge",
      "consulted_date" => nil,
      "decided_date"   => nil,
      "description"    => "make shop bigger",
      "distance"       => nil,
      "location_x"     => 51.459,
      "link"           => "http://www.planit.org.uk/planapplic/07/0811/FUL",
      "location_y"     => -2.4302,
      "name"           => "07/0811/FUL",
      "postcode"       => "CB1 3AN",
      "rec_type"       => "PlanApplic",
      "reference"      => nil,
      "source_url"     => "http://www.gov.uk/planing/123",
      "start_date"     => "2015-03-19",
      "uid"            => "07/0811/FUL",
      "url"            => "http://www.example.com",
      "last_difference"=> "2015-03-21T03:37:00.690000+00:00",
    }
  end

  it "should pull in planning applications, rejecting invalid ones" do
    expect { subject.process! }.to change { PlanningApplication.count }.by(3)
    expect(cam_req).to have_been_made
    expect(london_req).to have_been_made
    planning_ap = PlanningApplication.find_by(uid: "07/0811/FUL")
    expect(planning_ap.address).to eq("163 - 167 Mill Road Cambridge Cambridgeshire CB1 3AN")
    expect(planning_ap.start_date).to eq("2015-03-19".to_date)
  end

  context "with an authority with more than 500 planning applications" do
    before do
      stub_const("PlanningFilter::LOCAL_AUTHORITIES", ["Multi Page LA"])
    end

    let!(:multi_page_tot_req) do
      stub_request(:get, Rails.application.config.planning_applications_url)
        .with(query: { apikey: "planit_api_key", auth: "Multi Page LA", start_date: (Date.today - 14.days).to_s, end_date: Date.today, sort: "-start_date", pg_sz: 500 })
        .to_return(status: 200, body: {
          "count" => 500, "page_size" => 500, "records" => [planning_record]
        }.to_json)
    end

    let!(:multi_page_0_req) do
      stub_request(:get, Rails.application.config.planning_applications_url)
        .with(query: { apikey: "planit_api_key", auth: "Multi Page LA", start_date: (Date.today - 14.days).to_s, end_date: (Date.today - 10.days), sort: "-start_date", pg_sz: 500 })
        .to_return(status: 200, body: {
          "count" => 500, "page_size" => 500, "records" => [planning_record]
        }.to_json)
    end

    let!(:multi_page_1_req) do
      stub_request(:get, Rails.application.config.planning_applications_url)
        .with(query: { apikey: "planit_api_key", auth: "Multi Page LA", start_date: (Date.today - 9.days).to_s, end_date: (Date.today - 5.days), sort: "-start_date", pg_sz: 500 })
        .to_return(status: 200, body: {
          "count" => 500, "page_size" => 500, "records" => [planning_record]
        }.to_json)
    end

    let!(:multi_page_2_req) do
      stub_request(:get, Rails.application.config.planning_applications_url)
        .with(query: { apikey: "planit_api_key", auth: "Multi Page LA", start_date: (Date.today - 4.days).to_s, end_date: (Date.today - 0.days), sort: "-start_date", pg_sz: 500 })
        .to_return(status: 200, body: {
          "count" => 500, "page_size" => 500, "records" => [planning_record_alt]
        }.to_json)
    end

    it "should split the reqs into five day intervals" do
      expect { subject.process! }.to change { PlanningApplication.count }.by(2)

      [multi_page_tot_req, multi_page_0_req, multi_page_1_req, multi_page_2_req].each do |req|
        expect(req).to have_been_made
      end
    end
  end
end
