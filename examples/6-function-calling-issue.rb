require 'openai'
require 'json'
require 'rest-client'

def get_completion(messages, model="gpt-3.5-turbo", temperature=0)
  client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  response = client.chat(
    parameters: {
      model: model,
      messages: messages,
      temperature: temperature,
      functions: [
          {
              "name": "get_stock_information",
              "description": "查詢台灣公司的股價",
              "parameters": {
                  "type": "object",
                  "properties": {
                      "date": {
                          "type": "string",
                          "description": "yyyymmdd 日期, 如果日期是民國年份，請加上 1911 轉成西元年份",
                      },
                      "stock_code": {
                          "type": "string",
                          "description": "台灣的股票代號，例如 0050",
                      }
                  },
                  "required": ["date", "stock_code"],
              },
          }
      ]
  })

  response.dig("choices", 0, "message")
end

def get_stock_information(date, stock_code)
  response = RestClient.get("https://www.twse.com.tw/exchangeReport/STOCK_DAY?response=json&date=#{date}&stockNo=#{stock_code}")
  response.body
end

query = "請問112年的11月1號的台積電和鴻海，股價表現如何?"

# Step 1: 將用戶查詢轉成對 function 的呼叫
puts("----- Step 1:")

messages = [{"role": "user", "content": query }]

result = get_completion(messages, "gpt-3.5-turbo")
puts(result)

# Step 2: 本地執行 function
puts("----- Step 2:")
messages << result

args = JSON.parse( result["function_call"]["arguments"] )
context = get_stock_information(args["date"], args["stock_code"])

puts(context)

# Step 3: 將 function 結果回傳給 GPT
puts("----- Step 3:")

messages << { "role": "function", "name": "get_stock_information",
              "content": context }

result = get_completion(messages, "gpt-3.5-turbo")
puts(result)

# 這個 result 繼續要我執行 function....
