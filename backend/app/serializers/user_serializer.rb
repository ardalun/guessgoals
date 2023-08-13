# == Schema Information
#
# Table name: users
#
#  id                   :bigint(8)        not null, primary key
#  activation_token     :string
#  active               :boolean          default(FALSE)
#  admin                :boolean          default(FALSE)
#  email                :string
#  pass_reset_last_sent :datetime
#  pass_reset_token     :string
#  password_digest      :string
#  unseen_notifs        :integer          default(0)
#  username             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_username  (username) UNIQUE
#

class UserSerializer < ApplicationSerializer
  ATTRS = [
    :id,
    :username,
    :email,
    :unseen_notifs
  ]
end
