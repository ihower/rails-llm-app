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
  })

  response.dig("choices", 0, "message")
end

query = "請問112年的11月1號的台積電，股價表現如何?"

# Step 1: 從用戶問題中，用 prompt1 來提取出 外部工具的參數
puts("----- Step 1:")

messages = [
    {"role": "user", "content": "
用戶問題: #{query}

1. 無需回答問題，請從用戶問題中，擷取出日期和台灣股票代號
2. 如果日期是民國年份，請加上 1911 轉成西元年份
3. 如果用戶沒有提供日期和公司名稱或股票代號，請回傳 {{ \"error\": \"string\" // 錯誤訊息 }}
4. 請回覆 JSON 格式，例如
{
  \"date\": \"20231115\", // yyyymmdd
  \"stock_code\": \"0050\" // 台灣的股票代號
}"
}]

result = get_completion(messages, "gpt-3.5-turbo")
puts(result["content"])
data = JSON.parse(result["content"])

# Step 2: 執行工具，拿到結果
puts("----- Step 2:")

date = data["date"]
stock_code = data["stock_code"]

# 台灣證券交易所
# https://medium.com/%E5%B7%A5%E7%A8%8B%E9%9A%A8%E5%AF%AB%E7%AD%86%E8%A8%98/5%E7%A8%AE%E6%8A%93%E5%8F%96%E5%8F%B0%E8%82%A1%E6%AD%B7%E5%8F%B2%E8%82%A1%E5%83%B9%E7%9A%84%E6%96%B9%E6%B3%95-766bf2ed9d6
response = RestClient.get("https://www.twse.com.tw/exchangeReport/STOCK_DAY?response=json&date=#{date}&stockNo=#{stock_code}")
context = JSON.parse(response.body)
puts(context)

# Step 3: 用 (prompt2 + 結果) 轉成自然語言回給用戶
puts("----- Step 3:")

messages = [
    {"role": "user", "content": "
用戶問題: #{query}

context: #{context}
"}
]

result = get_completion(messages)
puts(result["content"])
