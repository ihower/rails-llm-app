class ApplicationJob < ActiveJob::Base

  queue_as :llmapp_queue

end
