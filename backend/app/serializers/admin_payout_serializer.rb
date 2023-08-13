class AdminPayoutSerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :total,
    :created_at,
    :wallet_id
  ]
end
