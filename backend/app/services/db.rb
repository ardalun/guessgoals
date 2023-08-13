class Db
  def self.atomically(&block)
    return if block.blank?

    if self.already_within_a_transaction?
      block.call
    else
      ActiveRecord::Base.transaction do
        block.call
      end
    end
  end

  def self.ensure_transaction!
    if self.not_within_a_transaction?
      raise ExpectedTransactionError
    end
  end

  def self.already_within_a_transaction?
    limit = Rails.env.test? ? 1 : 0
    return ActiveRecord::Base.connection.open_transactions > limit
  end

  def self.not_within_a_transaction?
    return !self.already_within_a_transaction?
  end
end

class ExpectedTransactionError < StandardError
  def message
    'Expected to be wrapped within a transaction.'
  end
end
