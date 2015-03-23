require 'spec_helper'

describe PlanningApplicationWorker do
  before do
    stub_const("#{described_class}::LOCAL_AUTHORITIES", ['London', 'Cambridge'] )
  end

  let!(:london_req) do
    no_url = planning_record.dup.tap {|pr| pr.delete 'url' }
    planning_record_alt = planning_record.merge('uid' => '345')
    stub_request(:get, 'http://www.planit.org.uk/find/applics/json').
      with(query: {auth: 'London', start_date: (Date.today - 2.days).to_s, end_date: Date.yesterday, pg_sz: 500},
           headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'Host'=>'www.planit.org.uk:80'}).
      to_return(status: 200, body: {
             'count' => 1,
             'page_size' => 500,
             'records' => [ no_url, planning_record_alt ]
           }.to_json)
  end

  let!(:cam_req) do
    no_lat = planning_record.dup.tap {|pr| pr.delete 'lng' }
    no_uid = planning_record.dup.tap {|pr| pr.delete 'uid' }
    stub_request(:get, 'http://www.planit.org.uk/find/applics/json').
      with(query: {auth: 'Cambridge', start_date: (Date.today - 2.days).to_s, end_date: Date.yesterday, pg_sz: 500},
           headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'Host'=>'www.planit.org.uk:80'}).
      to_return(status: 200, body: {
             'count' => 1,
             'page_size' => 500,
             'records' => [ no_uid, planning_record, no_lat ]
           }.to_json)
  end

  let(:planning_record) do
    {
      'doc_type' => 'PlanApplic',
      'name' => '15/01331/TCA',
      'description' => 'do this and that',
      'when_updated' => '2015-03-21T03:37:00.690000+00:00',
      'authority_id' => 22,
      'source_url' => 'http://www.gov.uk/planing/123',
      'authority_name' => 'Bath',
      'link' => 'http://www.planit.org.uk/planapplic/15/01331/TCA/',
      'postcode' => 'BA1 1AA',
      'address' => 'Sandy Gates, BA1 1AA',
      'lat' => 51.419359,
      'lng' => -2.431002,
      'start_date' => '2015-03-19',
      'uid' => '123',
      'url' => 'http://www.example.com'
    }
  end

  it 'should pull in planning applications, rejecting invalid ones' do
    expect{ subject.process! }.to change{ PlanningApplication.count }.by(2) 
    expect(cam_req).to have_been_made
    expect(london_req).to have_been_made
    planning_ap = PlanningApplication.find_by_uid('123')
    expect(planning_ap.address).to eq('Sandy Gates, BA1 1AA')
  end
end
