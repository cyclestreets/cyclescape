require 'spec_helper'

describe PagesController do
  it 'should render the template given in the page param' do
    get :show, page: 'changelog'
    response.should render_template('changelog')
  end

  it 'should return 404 if the page is not found' do
    get :show, page: 'some-other'
    response.status.should == 404
  end
end
