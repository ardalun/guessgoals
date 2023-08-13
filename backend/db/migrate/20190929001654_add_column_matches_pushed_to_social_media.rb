class AddColumnMatchesPushedToSocialMedia < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :pushed_to_social_media, :boolean, default: false
  end
end
