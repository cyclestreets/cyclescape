require 'spec_helper'

describe PagesController do
  it 'should render the template given in the page param' do
    get :show, page: 'changelog'
    expect(response).to render_template('changelog')
  end

  it 'should return 404 if the page is not found' do
    get :show, page: 'some-other'
    expect(response.status).to eq(404)
  end
end
