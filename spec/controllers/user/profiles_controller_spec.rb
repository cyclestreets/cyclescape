require 'spec_helper'

describe User::ProfilesController, type: :controller do
  describe 'routing' do
    it { is_expected.to route(:get, '/settings').to(action: :show) }
    it { is_expected.to route(:get, '/users/1/profile').to(action: :show, user_id: 1) }
    it { is_expected.to route(:get, '/users/1/profile/edit').to(action: :edit, user_id: '1') }
    it { is_expected.to route(:put, '/users/1/profile').to(action: :update, user_id: '1') }
  end

  context 'profile visibility' do
    let(:user_profile) { create(:user_profile) }
    let(:user) { user_profile.user }

    context 'with public profile' do
      context 'as a guest' do
        it 'should be visible' do
          get :show, params: { user_id: user.id }
          expect(response).to be_success
        end
      end
    end

    context 'with group-only profile' do
      before do
        user.profile.update_column(:visibility, 'group')
      end

      context 'as a guest' do
        it "should ask user to sign in" do
          expect(get :show, params: { user_id: user.id }).to redirect_to(new_user_session_url)
        end

        context 'where the user does not exist' do
          it "should ask user to sign in" do
            expect(get(:show, params: { user_id: -1 })).to redirect_to(new_user_session_url)
          end
        end
      end

      context 'as yourself' do
        include_context 'signed in as a site user'

        before do
          create :user_profile, user: current_user, visibility: 'group'
          warden.set_user current_user.reload
        end

        it 'should be visible and not show PM option' do
          get :show, params: { user_id: current_user.id } # NB current_user
          expect(response).to be_success
          expect(response.body).to_not include(I18n.t('user.profiles.show.send_private_message'))
        end
      end

      context 'as a site member' do
        include_context 'signed in as a site user'

        before do
          sign_in current_user
        end

        it 'should be hidden' do
          get :show, params: { user_id: user.id }
          expect(response.body).to include(I18n.t('application.permission_denied'))
        end

        context 'where the user does not exist' do
          it 'should be hidden' do
            get :show, params: { user_id: -1 }
            expect(response.body).to include(I18n.t('application.permission_denied'))
          end
        end
      end

      context 'as a group member' do
        include_context 'signed in as a group member'

        let!(:group_membership) { create(:group_membership, user: user, group: current_group) }

        before do
          sign_in current_user
          get :show, params: { user_id: user.id }
        end

        it 'should be visible and show PM option' do
          expect(response).to be_success
          expect(response.body).to include(I18n.t('user.profiles.show.send_private_message'))
        end
      end

      context 'with a membership request' do
        context 'as a committee member' do
          include_context 'signed in as a committee member'

          before do
            create(:group_membership_request, user: user, group: current_group)
            sign_in current_user
          end

          it 'should be visible' do
            get :show, params: { user_id: user.id }
            expect(response).to be_success
          end
        end

        context 'as a normal member' do
          include_context 'signed in as a group member'

          before do
            create(:group_membership_request, user: user, group: current_group)
            sign_in current_user
            get :show, params: { user_id: user.id }
          end

          it 'should be hidden' do
            expect(response.body).to include(I18n.t('application.permission_denied'))
          end
        end
      end

      context 'as an admin' do
        include_context 'signed in as admin'

        before do
          sign_in current_user
        end

        it 'should be visible regardless of groups' do
          get :show, params: { user_id: user.id }
          expect(response).to be_success
        end
      end
    end
  end
end
