require 'rails_helper'

RSpec.describe 'Auth Service', type: :service do
  describe '.decode_token' do
    it 'decodes a properly signed id token' do
      user = create(:user)
      id_token = Auth.get_id_token(user)
      expect(Auth.decode_token(id_token)).not_to eq(nil)
    end

    it 'returns nil for a manipulated id token' do
      user = create(:user)
      id_token = "#{Auth.get_id_token(user)}Something"
      expect(Auth.decode_token(id_token)).to eq(nil)
    end
  end
end