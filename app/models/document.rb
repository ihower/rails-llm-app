class Document < ApplicationRecord

  has_many :chunks, :class_name => "DocumentChunk"

  mount_uploader :doc, DocUploader

  validates_presence_of :doc

  before_create :update_doc_metadata

  # 參考自 https://platform.openai.com/docs/tutorials/web-qa-embeddings
  def self.split_into_many(text, max_tokens = 1500)
    sentences = text.split(/[。.]/).reject(&:empty?)

    chunks = []
    tokens_so_far = 0
    chunk = []

    sentences.each do |sentence|
      token_count =(" " + sentence).length # FIXME

      if tokens_so_far + token_count > max_tokens
        chunks.push(chunk.join('. ') + '.')
        chunk = []
        tokens_so_far = 0
      end

      next if token_count > max_tokens

      chunk.push(sentence)
      tokens_so_far += token_count + 1
    end

    chunks.push(chunk.join('. ') + '.') unless chunk.empty?

    chunks
  end


  def update_doc_metadata
    self.content_type = doc.file.content_type
    self.file_name = doc.file.original_filename
    self.file_size = doc.file.size
  end

  def parse_and_index!
    self.chunks.delete_all

    client = OpenAI::Client.new(access_token: Rails.application.secrets.openai_api_key)

    self.update_column(:status, "splitting text")
    text = File.read(self.doc.path)
    chunk_texts = Document.split_into_many(text)

    self.update_column(:status, "embedding")

    chunk_texts.each do |chunk_text|
      response = client.embeddings(
          parameters: {
              model: "text-embedding-ada-002",
              input: chunk_text
          }
      )

      self.chunks.create!( :embedding => response.dig("data", 0, "embedding"), :text => chunk_text )
    end

    self.update_column(:status, "finished indexing")
  end


end
