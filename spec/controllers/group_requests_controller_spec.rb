require 'rails_helper'

RSpec.describe GroupRequestsController, :type => :controller do

  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all group_requests as @group_requests" do
      group_request = GroupRequest.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:group_requests)).to eq([group_request])
    end
  end

  describe "GET #show" do
    it "assigns the requested group_request as @group_request" do
      group_request = GroupRequest.create! valid_attributes
      get :show, {:id => group_request.to_param}, valid_session
      expect(assigns(:group_request)).to eq(group_request)
    end
  end

  describe "GET #new" do
    it "assigns a new group_request as @group_request" do
      get :new, {}, valid_session
      expect(assigns(:group_request)).to be_a_new(GroupRequest)
    end
  end

  describe "GET #edit" do
    it "assigns the requested group_request as @group_request" do
      group_request = GroupRequest.create! valid_attributes
      get :edit, {:id => group_request.to_param}, valid_session
      expect(assigns(:group_request)).to eq(group_request)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new GroupRequest" do
        expect {
          post :create, {:group_request => valid_attributes}, valid_session
        }.to change(GroupRequest, :count).by(1)
      end

      it "assigns a newly created group_request as @group_request" do
        post :create, {:group_request => valid_attributes}, valid_session
        expect(assigns(:group_request)).to be_a(GroupRequest)
        expect(assigns(:group_request)).to be_persisted
      end

      it "redirects to the created group_request" do
        post :create, {:group_request => valid_attributes}, valid_session
        expect(response).to redirect_to(GroupRequest.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved group_request as @group_request" do
        post :create, {:group_request => invalid_attributes}, valid_session
        expect(assigns(:group_request)).to be_a_new(GroupRequest)
      end

      it "re-renders the 'new' template" do
        post :create, {:group_request => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested group_request" do
        group_request = GroupRequest.create! valid_attributes
        put :update, {:id => group_request.to_param, :group_request => new_attributes}, valid_session
        group_request.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested group_request as @group_request" do
        group_request = GroupRequest.create! valid_attributes
        put :update, {:id => group_request.to_param, :group_request => valid_attributes}, valid_session
        expect(assigns(:group_request)).to eq(group_request)
      end

      it "redirects to the group_request" do
        group_request = GroupRequest.create! valid_attributes
        put :update, {:id => group_request.to_param, :group_request => valid_attributes}, valid_session
        expect(response).to redirect_to(group_request)
      end
    end

    context "with invalid params" do
      it "assigns the group_request as @group_request" do
        group_request = GroupRequest.create! valid_attributes
        put :update, {:id => group_request.to_param, :group_request => invalid_attributes}, valid_session
        expect(assigns(:group_request)).to eq(group_request)
      end

      it "re-renders the 'edit' template" do
        group_request = GroupRequest.create! valid_attributes
        put :update, {:id => group_request.to_param, :group_request => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested group_request" do
      group_request = GroupRequest.create! valid_attributes
      expect {
        delete :destroy, {:id => group_request.to_param}, valid_session
      }.to change(GroupRequest, :count).by(-1)
    end

    it "redirects to the group_requests list" do
      group_request = GroupRequest.create! valid_attributes
      delete :destroy, {:id => group_request.to_param}, valid_session
      expect(response).to redirect_to(group_requests_url)
    end
  end
end
