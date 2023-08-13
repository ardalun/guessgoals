class AddColumnMatchesHighlightsSynced < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :highlights_synced, :boolean, default: false
  end
end
