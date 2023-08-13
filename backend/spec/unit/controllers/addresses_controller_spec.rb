require 'rails_helper'

RSpec.describe Api::AddressesController, type: :controller do

  describe ".show => GET /addresses/:code" do
    it "returns 403 if user is not authenticated" do
      get :show, params: { code: 'address_to_pull_updates_for' }
      expect(response).to have_http_status(403)
    end

    it "returns 404 if address is not found" do
      user = create(:user)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      get :show, params: { code: 'address_to_pull_updates_for' }
      expect(response).to have_http_status(404)
    end

    it "returns 403 if address is not owned by the authenticated user" do
      user_1 = create(:user)
      user_2 = create(:user)
      request.headers.merge!('Authorization' => Auth.get_id_token(user_1))
      get :show, params: { code: user_2.wallet.addresses.last.code }
      expect(response).to have_http_status(403)
    end

    it 'returns no updates if no new transaction is found' do
      user = create(:user)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      expect(Bitcoin).to receive(:pull_updates_for_address).with(user.wallet.addresses.last.code).and_return(0)
      get :show, params: { code: user.wallet.addresses.last.code }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).fetch('updated', nil)).to eq(false)
    end

    it 'returns not_updated if no update is found on wallet' do
      user = create(:user)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      expect(Bitcoin).to receive(:pull_updates_for_address).with(user.wallet.addresses.last.code).and_return(1)
      get :show, params: { code: user.wallet.addresses.last.code }

      expect(response).to have_http_status(200)
      response_body = JSON.parse(response.body)
      expect(response_body.fetch('updated', nil)).to eq(false)
    end

    it 'returns updated wallet if an update is found' do
      user = create(:user)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      expect(Bitcoin).to receive(:pull_updates_for_address).with(user.wallet.addresses.last.code) do
        user.wallet.update!(total: Calc.add(user.wallet.total, 0.001))
        next 1
      end
      get :show, params: { code: user.wallet.addresses.last.code }

      expect(response).to have_http_status(200)
      response_body = JSON.parse(response.body)
      expect(response_body.fetch('updated', nil)).to         eq(true)
      expect(response_body.fetch('wallet', nil).present?).to eq(true)
    end
  end

end
