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

class PrizeRule < ApplicationRecord
  has_many :matches

  after_create do
    if self.active?
      PrizeRule.where.not(id: self.id).where(active: true).find_each do |prize_rule|
        prize_rule.update!(active: false)
      end
    end
  end

  def self.current
    PrizeRule.where(active: true).last
  end

  def calculate_prize(pool_size, ticket_fee)
    ranges = self.rules.keys.map { |key| eval(key) }
    ranges.each do |range|
      key = "#{range.min}..#{range.max}"
      if range.include?(pool_size)
        return Calc.mult(Calc.mult(self.rules[key], pool_size).round(1), ticket_fee)
      end
    end
    return Calc.mult(Calc.mult(0.7, pool_size).round(1), ticket_fee)
  end
end
