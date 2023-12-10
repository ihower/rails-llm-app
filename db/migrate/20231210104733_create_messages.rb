class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.integer "conversation_id"
      t.string "processing_job"
      t.string "role"
      t.text "content"
      t.timestamps
    end
  end
end
