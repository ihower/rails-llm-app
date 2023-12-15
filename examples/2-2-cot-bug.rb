require 'openai'

def get_completion(messages, model="gpt-3.5-turbo", temperature=0)
  client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  response = client.chat(
    parameters: {
      model: model,
      messages: messages,
      temperature: temperature,
  })

  response.dig("choices", 0, "message")
end

# Assuming x = 100, let's calculate:
# Step 1: x + 1
# Step 2: x + 10
# Step 3: x - 1
# Step 4: x * 2
# Step 5: x - 20
# The final value of x is ?

user_message = "
請用以下計算數學計算，假設 x = 100

Step 1: x 加 1
Step 2: x 加 10
Step 3: x 減 1
Step 4: x 乘 2
Step 5: x 減 20

不要輸出過程，只要回答最後 x 是多少?
"

messages = [
    {
        "role": "user",
        "content": user_message
    }
]

response = get_completion(messages, "gpt-3.5-turbo")
puts(response["content"])

# 最後 x 是 189。