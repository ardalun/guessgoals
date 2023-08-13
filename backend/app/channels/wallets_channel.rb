class WalletsChannel < ApplicationCable::Channel  
  def subscribed
    if current_user.nil?
      reject
    else
      stream_from "users/#{current_user[:id]}/wallet"
    end
  end
end  