require 'spec_helper'

describe PlanningApplicationsController, type: :controller do
  describe 'routing' do
    it { is_expected.to route(:get, '/planning_applications/1').to(action: :show, id: 1) }
    it { is_expected.to route(:get, '/planning_applications/uid/nasty/uid').to(action: :show_uid, uid: 'nasty/uid') }
    it { is_expected.to route(:get, '/planning_applications/1/geometry').to(action: :geometry, id: 1) }
    it { is_expected.to route(:get, '/planning_applications/search').to(action: :search) }
    it { is_expected.to route(:put, '/planning_applications/1/hide').to(action: :hide, id: 1) }
    it { is_expected.to route(:put, '/planning_applications/1/hide').to(action: :unhide, id: 1) }
  end
end
