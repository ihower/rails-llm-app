class Message < ApplicationRecord

  PROCESSING_JOBS = {
    "simple_conversation" => "Conversation",
    "simple_completion" => "Completion",
    "simple_search" => "Google Search",
    "simple_rag" => "Simple RAG",

  }

  belongs_to :conversation

end
