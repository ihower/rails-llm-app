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

user_message = "
我去市場買了10個蘋果。我給了鄰居2個蘋果，又給修理工2個蘋果。
之後，我又去買了5個蘋果，然後吃了1個。我還剩下多少個蘋果？
"

messages = [
    {
        "role": "user",
        "content": user_message
    }
]

response = get_completion(messages, "gpt-3.5-turbo")
puts(response["content"])

# 若沒有 CoT:
#   你還剩下12個蘋果。
#
# 加上 CoT: Let's think step by step
#  1. 原本有10個蘋果。
#  2. 給了鄰居2個蘋果，剩下8個蘋果。
#  3. 又給修理工2個蘋果，剩下6個蘋果。
#  4. 再去買了5個蘋果，總共有6 + 5 = 11個蘋果。
#  5. 吃了1個蘋果，剩下11 - 1 = 10個蘋果。