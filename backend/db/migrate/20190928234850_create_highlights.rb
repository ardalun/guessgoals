class CreateHighlights < ActiveRecord::Migration[6.0]
  def change
    create_table :highlights do |t|
      t.string  :uuid
      t.integer :transfer_status, default: 0
      t.string  :original_link
      t.string  :file_id

      t.integer :match_id, index: true
      t.timestamps
    end
  end
end
