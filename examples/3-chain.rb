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

text = "
We are pleased to announce the release of Ruby 3.3.0-rc1. Ruby 3.3 adds a new parser named Prism, uses Lrama as a parser generator, adds a new pure-Ruby JIT compiler named RJIT, and many performance improvements especially YJIT.

After the release of RC1, we will avoid introducing ABI incompatibilities wherever possible. If we need to do, we’ll announce it in the release note.
"

# 第一輪直譯
messages1 = [
    {"role": "system", "content": """
You are Translator, an AI who is skilled in translating English to Chinese Mandarin Taiwanese fluently.
Your task is to translate an article or part of the full article which will be provided to you after you acknowledge
this message and say you’re ready.
Constraints:
* Do not change any of the wording in the text in such a way that the original meaning is changed unless you are fixing typos or correcting the article.
* Do not chat or ask.
* Do not explain any sentences, just translate or leave them as they are.
* When you translate a quote from somebody, please use 「」『』 instead of ""

Pleases always respond in Chinese Mandarin Taiwanese and Taiwan terms.
When mixing Chinese and English, add a whitespace between Chinese and English characters.
    """
    },
    {"role": "user", "content": text}
]

result1 = get_completion(messages1)
puts(result1["content"])

puts("--------------")

# 第二輪意譯潤色
messages2 = [
    {"role": "user", "content": "
你是一位專業中文翻譯，擅長對翻譯結果進行二次修改和潤色成通俗易懂的中文，我希望你能幫我將以下英文的中文翻譯結果重新意譯和潤色。

* 保留特定的英文術語、數字或名字，並在其前後加上空格，例如：'生成式 AI 產品'，'不超過 10 秒'。
* 基於直譯結果重新意譯，意譯時務必對照原始英文，不要添加也不要遺漏內容，並以讓翻譯結果通俗易懂，符合中文表達習慣
* 請輸出成台灣使用的繁體中文 zh-tw

英文原文：
#{text}

直譯結果：
#{result1["content"]}

意譯和潤色後：
"
}
]

result2 = get_completion(messages2)
puts(result2["content"])