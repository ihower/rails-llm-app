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

# I went to the market and bought 10 apples.
# I gave 2 apples to my neighbor and another 2 to the repairman.
# Later, I bought 5 more apples and ate 1.
# How many apples do I have left?

user_message = "
我去市場買了10個蘋果。我給了鄰居2個蘋果，又給修理工2個蘋果。
之後，我又去買了5個蘋果，然後吃了1個。我還剩下多少個蘋果？
Let's think step by step
"

messages = [
    {
        "role": "user",
        "content": user_message
    }
]

puts messages
puts "-----"

response = get_completion(messages, "gpt-3.5-turbo")
puts(response["content"])

# 加上 CoT: 
#  1. 原本有10個蘋果。
#  2. 給了鄰居2個蘋果，剩下8個蘋果。
#  3. 又給修理工2個蘋果，剩下6個蘋果。
#  4. 再去買了5個蘋果，總共有6 + 5 = 11個蘋果。
#  5. 吃了1個蘋果，剩下11 - 1 = 10個蘋果。