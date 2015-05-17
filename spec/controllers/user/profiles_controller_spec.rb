require 'spec_helper'

describe User::ProfilesController, type: :controller do
  describe 'routing' do
    it { is_expected.to route(:get, '/profile').to(action: :show) }
    it { is_expected.to route(:get, '/profile/edit').to(action: :edit) }
    it { is_expected.to route(:get, '/users/1/profile').to(action: :show, user_id: 1) }
    it { is_expected.to route(:get, '/users/1/profile/edit').to(action: :edit, user_id: '1') }
    it { is_expected.to route(:put, '/users/1/profile').to(action: :update, user_id: '1') }
  end

  context 'profile visibility' do
    let(:user) { FactoryGirl.create(:user) }

    context 'with public profile' do
      context 'as a guest' do
        it 'should be visible' do
          get :show, user_id: user.id
          expect(assigns(:profile_visible)).to be_truthy
        end
      end
    end

    context 'with group-only profile' do
      before do
        user.prefs.update_column(:profile_visibility, 'group')
      end

      context 'as a guest' do
        it 'should be hidden' do
          get :show, user_id: user.id
          expect(assigns(:profile_visible)).to be_falsey
        end
      end

      context 'as yourself' do
        include_context 'signed in as a site user'

        before do
          current_user.prefs.update_column(:profile_visibility, 'group')
          sign_in current_user
        end

        it 'should be visible' do
          current_user.prefs.update_column(:profile_visibility, 'group')
          get :show, user_id: current_user.id # NB current_user
          expect(assigns(:profile_visible)).to be_truthy
        end
      end

      context 'as a site member' do
        include_context 'signed in as a site user'

        before do
          sign_in current_user
        end

        it 'should be hidden' do
          get :show, user_id: user.id
          expect(assigns(:profile_visible)).to be_falsey
        end
      end

      context 'as a group member' do
        include_context 'signed in as a group member'

        let!(:group_membership) { FactoryGirl.create(:group_membership, user: user, group: current_group) }

        before do
          sign_in current_user
        end

        it 'should be visible' do
          #binding.pry
          get :show, user_id: user.id
          expect(assigns(:profile_visible)).to be_truthy
        end
      end

      context 'as an admin' do
        include_context 'signed in as admin'

        before do
          sign_in current_user
        end

        it 'should be visible regardless of groups' do
          get :show, user_id: user.id
          expect(assigns(:profile_visible)).to be_truthy
        end
      end
    end
  end
end
