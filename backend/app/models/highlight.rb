# == Schema Information
#
# Table name: highlights
#
#  id              :bigint(8)        not null, primary key
#  original_link   :string
#  transfer_status :integer          default("pending")
#  uuid            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  file_id         :string
#  match_id        :integer
#
# Indexes
#
#  index_highlights_on_match_id  (match_id)
#

class Highlight < ApplicationRecord
  enum transfer_status: {
    pending: 0,
    failed:  1,
    done:    2
  }
  belongs_to :match

  before_create :assign_uuid
  # after_create_commit :transfer_to_guessgoalsbot

  validates_presence_of :match

  def assign_uuid
    self.uuid = SecureRandom.uuid
  end

  # def transfer_to_guessgoalsbot
  #   TransferHighlightToGuessgoalsbotWorker.perform_async(self.id)
  # end

  # def set_transfer_failed!
  #   self.update!(transfer_status: :failed)
  #   self.try_pushing_match_to_social_media
  # end

  # def set_transfer_done!(file_id)
  #   self.update!(transfer_status: :done, file_id: file_id)
  #   self.try_pushing_match_to_social_media
  # end

  # def try_pushing_match_to_social_media
  #   return if !Rails.env.production?
  #   return if Highlight.where(match_id: self.match_id, transfer_status: :pending).count > 0
  #   self.match.push_to_social_media!
  # end
end
