# == Schema Information
#
# Table name: notifs
#
#  id         :bigint(8)        not null, primary key
#  data       :jsonb
#  kind       :integer          default("funds_received")
#  seen       :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_notifs_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Notif, type: :model do
  describe 'validation: data_has_correct_schema' do
    kind_to_required_keys = {
      funds_received:        ['ledger_entry_id', 'amount'],
      funds_confirmed:       ['ledger_entry_id', 'amount'],
      funds_declined:        ['ledger_entry_id', 'amount'],
      micro_funds_received:  ['ledger_entry_id', 'amount', 'minimum_acceptable_amount'],
      micro_funds_confirmed: ['ledger_entry_id', 'amount'],
      micro_funds_declined:  ['ledger_entry_id', 'amount'],
      play_accepted:         ['play_id', 'match_name'],
      play_declined:         ['play_id', 'match_name'],
      match_started:         ['play_id', 'match_name', 'real_prize', 'real_chance'],
      pool_won:              ['play_id', 'match_name', 'prize_share'],
      pool_lost:             ['play_id', 'match_name', 'play_rank'],
      payout_requested:      ['ledger_entry_id', 'amount'],
      payout_sent:           ['ledger_entry_id', 'amount'],
      payout_confirmed:      ['ledger_entry_id', 'amount']
    }

    kind_to_required_keys.keys.each do |kind|
      required_keys = kind_to_required_keys[kind]
      required_keys.each do |key|
        it "invalidates notif when #{key} is missing for a #{kind} kind" do
          notif = build(:notif, kind: kind)
          provided_keys = required_keys - [ key ]
          data = {}
          provided_keys.each do |provided_key|
            data[provided_key] = 'Filled'
          end
          notif.data = data
          notif.validate
          expect(notif.errors[:data]).to include("is missing key: #{key}")
        end
      end
    end
  end

  describe '.increment_user_unseen_notifs' do
    it 'updates user unseen_noitfs attribute' do
      notif = build(
        :notif, 
        kind: :funds_received,
        data: {
          txid:            'Filled',
          address_code:    'Filled',
          ledger_entry_id: 'Filled',
          amount:          'Filled'
        }
      )
      before_increment = notif.user.unseen_notifs
      notif.save!
      expect(notif.user.unseen_notifs).to eq(before_increment + 1)
    end
  end
end
