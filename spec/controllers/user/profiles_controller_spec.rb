require 'spec_helper'

describe User::ProfilesController, type: :controller do
  describe 'routing' do
    it { is_expected.to route(:get, '/settings').to(action: :show) }
    it { is_expected.to route(:get, '/settings/edit').to(action: :edit) }
    it { is_expected.to route(:get, '/users/1/profile').to(action: :show, user_id: 1) }
    it { is_expected.to route(:get, '/users/1/profile/edit').to(action: :edit, user_id: '1') }
    it { is_expected.to route(:put, '/users/1/profile').to(action: :update, user_id: '1') }
  end

  context 'profile visibility' do
    let(:user_profile) { FactoryGirl.create(:user_profile) }
    let(:user) { user_profile.user }

    context 'with public profile' do
      context 'as a guest' do
        it 'should be visible' do
          get :show, user_id: user.id
          expect(response).to be_success
        end
      end
    end

    context 'with group-only profile' do
      before do
        user.profile.update_column(:visibility, 'group')
      end

      context 'as a guest' do
        it 'should be hidden' do
          expect {get :show, user_id: user.id}.to raise_error(ActionController::RoutingError)
        end
      end

      context 'as yourself' do
        include_context 'signed in as a site user'

        before do
          FactoryGirl.create :user_profile, user: current_user, visibility: 'group'
          sign_in current_user.reload
        end

        it 'should be visible' do
          get :show, user_id: current_user.id # NB current_user
          expect(response).to be_success
        end
      end

      context 'as a site member' do
        include_context 'signed in as a site user'

        before do
          sign_in current_user
        end

        it 'should be hidden' do
          expect {get :show, user_id: user.id}.to raise_error(ActionController::RoutingError)
        end
      end

      context 'as a group member' do
        include_context 'signed in as a group member'

        let!(:group_membership) { FactoryGirl.create(:group_membership, user: user, group: current_group) }

        before do
          sign_in current_user
        end

        it 'should be visible' do
          get :show, user_id: user.id
          expect(response).to be_success
        end
      end

      context 'as an admin' do
        include_context 'signed in as admin'

        before do
          sign_in current_user
        end

        it 'should be visible regardless of groups' do
          get :show, user_id: user.id
          expect(response).to be_success
        end
      end
    end
  end
end
