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

class User < ApplicationRecord
  has_one  :wallet, as: :owner
  has_many :plays
  has_many :notifs

  has_secure_password validations: false

  validates           :username, presence: true, length: 3..16, uniqueness: true
  validates_format_of :username, with: /\A[a-zA-Z0-9_]+\Z/
  validates           :email,    presence: true, length: 9..128, uniqueness: true
  validates_format_of :email,    with: /\A([a-zA-Z0-9_.-])+@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,6})+\Z/, on: :create
  validates           :password, presence: true, length: 8..256, on: :create
  
  validates_format_of :password, on: :create,
                      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#@$!%*?&])[A-Za-z\d#@$!%*?&]{8,}\Z/, 
                      message: 'must contain at least one uppercase letter, one lowercase letter, one number and one special character.'

  before_create :assign_activation_token
  before_create :downcase_email
  after_create  :create_wallet

  def assign_activation_token
    token = self.random_token
    while User.where(activation_token: token).pluck(:id).present?
      token = self.random_token
    end
    self.activation_token = token
  end

  def downcase_email
    self.email.downcase!
  end

  def create_wallet
    Wallet.create!(owner: self)
  end

  def push
    ActionCable.server.broadcast "users/#{self.id}", self.serialize
  end

  def set_new_pass_reset_token!
    token = self.random_token
    while User.find_by(pass_reset_token: token)
      token = self.random_token
    end
    self.update! pass_reset_token: token
  end

  def activation_link
    "#{BASE_URL}/activate/#{self.activation_token}"
  end
  
  def pass_reset_link
    "#{BASE_URL}/reset-password/#{self.pass_reset_token}"
  end

  def random_token
    o = [('a'..'z'), (0..9)].map(&:to_a).flatten
    token = (0...19).map { o[rand(o.length)] }.join
  end

  def self.ai
    ai = User.find_or_initialize_by username: 'guessgoals'
    if ai.new_record?
      ai.assign_attributes(
        email:           'guessgoals@gmail.com',
        password_digest: 'ThisIsAnIncorrectHash',
        admin:           false,
        active:          true
      )
      ai.save!(validate: false)
    end
    return ai
  end
end
