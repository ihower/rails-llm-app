class Message < ApplicationRecord

  PROCESSING_JOBS = {
    "simple_conversation" => "Conversation",
    "simple_completion" => "Simple Completion",
    "simple_rag" => "Simple RAG Completion"
  }

  belongs_to :conversation

end
