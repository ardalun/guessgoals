# == Schema Information
#
# Table name: prize_rules
#
#  id         :bigint(8)        not null, primary key
#  active     :boolean          default(TRUE)
#  name       :string
#  rules      :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe PrizeRule, type: :model do

  describe '.calculate_prize' do
    before(:all) do
      @prize_rule = PrizeRule.create!(
        name: 'one',
        rules: {0..2 => 1.0, 3..3 => 0.83, 4..1000000000 => 0.7}
      )
    end
    it 'works fine with pool_size = 0' do
      expect(@prize_rule.calculate_prize(0, 0.001)).to eq(0.0)
    end
    it 'works fine with pool_size = 1' do
      expect(@prize_rule.calculate_prize(1, 0.001)).to eq(0.001)
    end
    it 'works fine with pool_size = 2' do
      expect(@prize_rule.calculate_prize(2, 0.001)).to eq(0.002)
    end
    it 'works fine with pool_size = 3' do
      expect(@prize_rule.calculate_prize(3, 0.001)).to eq(0.0025)
    end
    it 'works fine with pool_size = 4' do
      expect(@prize_rule.calculate_prize(4, 0.001)).to eq(0.0028)
    end
    it 'works fine with pool_size = 15' do
      expect(@prize_rule.calculate_prize(15, 0.001)).to eq(0.0105)
    end
  end
end
