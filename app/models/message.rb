class Message < ApplicationRecord

  PROCESSING_JOBS = {
    "simple_completion" => "Simple Completion",
    "simple_rag" => "Simple RAG"
  }

  belongs_to :conversation

end
