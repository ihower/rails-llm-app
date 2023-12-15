class SimpleSearchJob < ApplicationJob

  def perform(message)
    conversion = message.conversation
    client = OpenAI::Client.new(access_token: Rails.application.secrets.openai_api_key)

    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: "user", content: "請從以下用戶查詢句子中，擷取關鍵字: #{message.content}"} ],
        temperature: 0.5,
    })
    keyword = response.dig("choices", 0, "message", "content")

    Rails.logger.debug("keyword: #{keyword}")

    searched_text = GoogleSearch.get_text(keyword)

    prompt = "這是用戶問題: ```#{message.content}```
  請根據參考資訊回答: ```#{searched_text}```
  請回答:
    "

    Rails.logger.debug("prompt: #{prompt}")

    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: "user", content: prompt }],
        temperature: 0.5,
    })
    result = response.dig("choices", 0, "message", "content")

    ai_message = conversion.messages.create!( :role => message.processing_job, :content => result)
    ActionCable.server.broadcast( "chat-#{conversion.uuid}", { :html => ApplicationController.render( :partial => "messages/message", :locals => { :message => ai_message }  ) })

  end

end
