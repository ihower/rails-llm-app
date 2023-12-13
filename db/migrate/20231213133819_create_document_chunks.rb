class CreateDocumentChunks < ActiveRecord::Migration[7.1]
  def change
    enable_extension "vector"

    create_table :document_chunks do |t|
      t.integer :document_id, :index => true
      t.vector :embedding, limit: 1536
      t.text :text
      t.timestamps
    end
  end
end
