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

class NotifSerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :kind,
    :data,
    :seen,
    :created_at
  ]
end
