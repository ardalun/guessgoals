require 'rails_helper'

RSpec.describe Api::NotifsController, type: :controller do

  describe ".mark_as_seen => PUT /notifs/mark_as_seen" do
    it "returns 403 if user is not authenticated" do
      put :mark_as_seen, params: { ids: [1, 2] }
      expect(response).to have_http_status(403)
    end

    it "returns 403 if some notifs are not owned by the authenticated user" do
      user_1 = create(:user)
      user_2 = create(:user)
      notif = create(
        :notif, 
        kind: :funds_received,
        user_id: user_2.id,
        data: {
          txid:            'Filled',
          address_code:    'Filled',
          ledger_entry_id: 'Filled',
          amount:          'Filled'
        }
      )
      request.headers.merge!('Authorization' => Auth.get_id_token(user_1))
      put :mark_as_seen, params: { ids: [notif.id] }
      expect(response).to have_http_status(403)
    end

    it "returns 404 if some notifs do not exist" do
      user = create(:user)
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      put :mark_as_seen, params: { ids: [1] }
      expect(response).to have_http_status(404)
    end

    it 'marks target notifs as seen' do
      user = create(:user)
      notif = create(
        :notif, 
        kind: :funds_received,
        user_id: user.id,
        data: {
          txid:            'Filled',
          address_code:    'Filled',
          ledger_entry_id: 'Filled',
          amount:          'Filled'
        }
      )
      request.headers.merge!('Authorization' => Auth.get_id_token(user))
      put :mark_as_seen, params: { ids: [notif.id] }
      expect(response).to have_http_status(200)
      notif.reload
      user.reload
      expect(notif.seen?).to be(true)
      expect(user.unseen_notifs).to eq(0)
    end
  end

end
