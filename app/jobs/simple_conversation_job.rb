class SimpleConversationJob < ApplicationJob

  def perform(message)
    conversion = message.conversation

    client = OpenAI::Client.new(access_token: Rails.application.secrets.openai_api_key)
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: conversion.messages.map{ |x| { role: (x.role == 'user')? "user" : "assistant", content: x.content } },
        temperature: 0.3,
    })
    result = response.dig("choices", 0, "message", "content")

    ai_message = conversion.messages.create!( :role => message.processing_job, :content => result)
    ActionCable.server.broadcast( "chat-#{conversion.uuid}", { :html => ApplicationController.render( :partial => "messages/message", :locals => { :message => ai_message }  ) })

  end

end
