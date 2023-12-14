# https://developers.google.com/custom-search/v1/overview?hl=zh-tw
class GoogleSearch

  KEY = Rails.application.secrets.google_search_key
  CX = Rails.application.secrets.google_search_cx

  def self.get_text(keyword)

    url = "https://www.googleapis.com/customsearch/v1?key=#{KEY}&cx=#{CX}&q=#{keyword}"

    p = URI::Parser.new
    url = p.escape(url)

    response = RestClient.get(url)

    data = JSON.parse(response.body)

    result = data["items"].map{ |x|
      "* " + x["title"] + ' ' + x["snippet"]
    }

    result.join("\n")
  end

end