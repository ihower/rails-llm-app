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

def get_completion_with_function_execution(messages, model="gpt-3.5-turbo", temperature=0)
  puts("called prompt: #{messages}")

  response = get_completion(messages, model, temperature)

  if response["function_call"]
    messages << {
        "role": "assistant",
        "content": nil,
        "function_call": response["function_call"]
    }

    # ------ 呼叫函數
    function_name = response["function_call"]["name"]
    function_args = JSON.parse(response["function_call"]["arguments"])

    puts("   called function: #{function_args}")
    function_response = get_stock_information(function_args["date"], function_args["stock_code"])

    # --------------

    messages << {
        "role": "function",
        "name": function_name,
        "content": function_response
    }

    # 進行遞迴呼叫
    return get_completion_with_function_execution(messages, model, temperature)

  else
    return response["content"]
  end
end

query = "請問112年的11月1號的台積電和鴻海的股價表現如何?"


messages = [{"role": "user", "content": query }]

result = get_completion_with_function_execution(messages, "gpt-3.5-turbo")
puts(result)
