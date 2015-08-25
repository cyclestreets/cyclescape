require 'spec_helper'

describe GroupsController, type: :controller do

  describe 'routing' do
    it { is_expected.to route(:get, 'http://subdomain.example.com').to(action: :show) }
  end
end

