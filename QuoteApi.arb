class QuoteApi
  QUOTE_API_URL =  ENV['QUOTE_API_URL']
  RANDOM_QUOTE = "#{QUOTE_API_URL}/api/v1/quotes/random".freeze

  def random_quote_with_fake_authors
    @response = Faraday.get(RANDOM_QUOTE)
    @quote_data = JSON.parse(@response.body)['random_quote'][0]
    authors_url = "#{QUOTE_API_URL}/api/v1/authors/random?reject_id=#{@quote_data['id']}&nb=4".freeze
    @response = Faraday.get(authors_url)
    @authors ||= JSON.parse(@response.body)['random_authors'].map { |author| author['name'] }
    {
      fake_authors: @authors.sample(2),
      quotes: @quote_data
    }
  end
end
