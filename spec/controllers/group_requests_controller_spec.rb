require 'spec_helper'

RSpec.describe GroupRequestsController, type: :controller do

  let(:valid_attributes) { FactoryGirl.attributes_for(:group_request) }
  let(:group_request)    { FactoryGirl.create(:group_request) }

  context 'as a site user' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      warden.set_user user
    end

    describe "POST #create" do
      it "creates a new GroupRequest" do
        expect {
          post :create, group_request: valid_attributes
        }.to change(GroupRequest, :count).by(1)
      end

      context "with valid params" do
        before do
          post :create, group_request: valid_attributes
        end

        it "redirects to the root" do
          expect(response).to redirect_to('/')
        end

        it 'sends an email to all admins' do
          post :create, group_request: valid_attributes
          mail = ActionMailer::Base.deliveries.last

          expect(mail.subject).to eq(I18n.t('mailers.notifications.new_group_request.subject',
                                            group_name: valid_attributes[:name],
                                            user_name: user.name))
          expect(mail.to).to include('root@cyclescape.org')
        end
      end
    end

    describe "GET #new" do
      it "assigns a new group_request as @request" do
        get :new
        expect(assigns(:request)).to be_a_new(GroupRequest)
      end
    end
  end

  context 'as a site admin with a group request' do
    let(:admin) { FactoryGirl.create(:user, :admin) }

    before do
      warden.set_user admin
      group_request
    end

    describe "GET #index" do
      it "assigns all group_requests as @requests" do
        get :index
        expect(assigns(:requests)).to eq([group_request])
      end
    end

    describe "GET #review" do
      it "assigns the requested group_request as @request" do
        get :review, id: group_request.to_param
        expect(assigns(:request)).to eq(group_request)
      end
    end

    describe "PUT #reject" do
      before do
        post :reject, {id: group_request.to_param, group_request: {rejection_message: 'Sorry!'}}
      end

      it 'sets the flash' do
        expect(flash[:notice]).to be_present
      end

      it 'emails the requester' do
        mail = ActionMailer::Base.deliveries.last

        expect(mail.subject).to eq(I18n.t('mailers.notifications.group_request_rejected.subject',
                                          group_request_name: group_request.name))

        expect(mail.to.first).to eq(group_request.user.email)
        expect(mail.body).to include('Sorry!')
      end

    end

    describe "PUT #confirm" do
      before do
        post :confirm, {:id => group_request.to_param}
      end

      it "sets the flash" do
        expect(flash[:notice]).to be_present
      end

      it 'emails the new groups owner' do
        mail = ActionMailer::Base.deliveries.last

        expect(mail.subject).to eq(I18n.t('mailers.notifications.group_request_confirmed.subject',
                                          group_name: group_request.name))

        expect(mail.to.first).to eq(group_request.user.email)
      end

    end

    describe "DELETE #destroy" do
      it "destroys the requested group_request" do
        expect {
          delete :destroy, {:id => group_request.to_param}
        }.to change(GroupRequest, :count).by(-1)
      end

      it "redirects to the group_requests list" do
        delete :destroy, {:id => group_request.to_param}
        expect(response).to redirect_to(group_requests_url)
      end
    end
  end
end
