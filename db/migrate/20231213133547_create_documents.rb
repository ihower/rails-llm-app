class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string "doc"
      t.string "file_name"
      t.integer "file_size"
      t.string "description"
      t.string "status", default: "pending"
      t.string "content_type"
      t.timestamps
    end
  end
end
