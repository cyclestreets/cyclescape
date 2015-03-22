require 'spec_helper'

describe PlanningApplicationWorker do
  before do
    stub_const("#{described_class}::LOCAL_AUTHORITIES", ['London', 'Cam'] )
  end

  let!(:london_req) do
    stub_request(:get, "http://www.planit.org.uk/find/applics/json").
      with(query: {auth: 'London', start_date: (Date.today - 2.days).to_s, end_date: Date.yesterday, pg_sz: 500},
           headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'Host'=>'www.planit.org.uk:80'}).
      to_return(status: 200, body: {
             "count" => 1,
             "page_size" => 500,
             "records" => [ planning_record_no_url ]
           }.to_json)
  end

  let!(:cam_req) do
    stub_request(:get, "http://www.planit.org.uk/find/applics/json").
      with(query: {auth: 'Cam', start_date: (Date.today - 2.days).to_s, end_date: Date.yesterday, pg_sz: 500},
           headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'Host'=>'www.planit.org.uk:80'}).
      to_return(status: 200, body: {
             "count" => 1,
             "page_size" => 500,
             "records" => [ planning_record_no_url.merge('url' => 'www.example.com') ]
           }.to_json)
  end

  let(:planning_record_no_url) do
    {
      "doc_type" => "PlanApplic",
      "name" => "15/01331/TCA",
      "description" => "do this and that",
      "when_updated" => "2015-03-21T03:37:00.690000+00:00",
      "authority_id" => 22,
      "source_url" => "http://www.gov.uk/planing/123",
      "authority_name" => "Bath",
      "link" => "http://www.planit.org.uk/planapplic/15/01331/TCA/",
      "postcode" => "BA1 1AA",
      "address" => "Sandy Gates, BA1 1AA",
      "lat" => 51.419359,
      "lng" => -2.431002,
      "start_date" => "2015-03-19",
      "uid" => "123"
    }
  end

  it 'should pull in planning applications, rejecting invalid ones' do
    expect{ subject.process! }.to change{ PlanningApplication.count }.by(1)
    expect(cam_req).to have_been_made
    expect(london_req).to have_been_made
    planning_ap = PlanningApplication.find_by_uid('123')
    expect(planning_ap.address).to eq('Sandy Gates, BA1 1AA')
  end
end
