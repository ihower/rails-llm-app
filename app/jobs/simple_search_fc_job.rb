class SimpleSearchFcJob < ApplicationJob

  def perform(message)
    conversion = message.conversation
    client = OpenAI::Client.new(access_token: Rails.application.secrets.openai_api_key)

    history = [{ role: "user", content: message.content }]

    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: "user", content: message.content }],
        temperature: 0.5,
        functions: [
            {
                "name": "google_search",
                "description": "搜尋最新的資訊",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "keyword": {
                            "type": "string",
                            "description": "搜尋關鍵字",
                        }
                    },
                    "required": ["keyword"],
                },
            }
        ],
        # function_call: { "name": "google_search" }
    })

    oai_message = response.dig("choices", 0, "message")
    history << oai_message

    if oai_message["function_call"]
      Rails.logger.debug("function called: #{oai_message}")

      args = JSON.parse( oai_message["function_call"]["arguments"] )

      searched_text = GoogleSearch.get_text( args["keyword"] )

      new_message = { "role": "function", "name": "google_search", "content": searched_text }
      history << new_message

      response = client.chat(
        parameters: {
          model: 'gpt-4-1106-preview',
          messages: history,
          temperature: 0.5,
      })
      result = response.dig("choices", 0, "message", "content")
    else
      result = oai_message["content"]
    end

    ai_message = conversion.messages.create!( :role => message.processing_job, :content => result)
    ActionCable.server.broadcast( "chat-#{conversion.uuid}", { :html => ApplicationController.render( :partial => "messages/message", :locals => { :message => ai_message }  ) })

  end

end
