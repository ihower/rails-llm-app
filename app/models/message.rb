class Message < ApplicationRecord

  PROCESSING_JOBS = {
    "simple_completion" => "Simple Completion",
  }

  belongs_to :conversation

end
