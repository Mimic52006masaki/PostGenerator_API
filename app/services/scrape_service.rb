# app/services/scrape_service.rb
require 'open-uri'
require 'nokogiri'

class ScrapeService
    DEFAULT_HEADERS = {
        'User-Agent' => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"
    }.freeze

    def initialize(url)
        @url = url
    end

    def call
        html = URI.open(@url, read_timeout: 20, open_timeout: 10, 'User-Agent' => DEFAULT_HEADERS['User-Agent']).read
        doc  = Nokogiri::HTML.parse(html)

        body = doc.at('article.post') || doc

        title_text = body.at('h1.post__title')&.text&.strip
        title_text = title_text.presence || URI.parse(@url).host

        contents = body.css('div.post__content')
        container = contents.first || body

        date_nodes   = container.css('div.t_h')
        detail_nodes = container.css('div.t_b')

        count = [date_nodes.size, detail_nodes.size].min

        post = Post.create!(title: title_text)

        count.times do |i|
            raw_text = date_nodes[i]&.text&.strip.to_s
            parts = raw_text.split
            new_date_text = parts.any? ? "#{parts[0]} アニメまとめCH #{parts[-1]}" : ''

            detail_html = (detail_nodes[i]&.inner_html || '').to_s

            wrapped_html = <<~HTML
                <div class="message-container">
                <div class="message">
                    <div class="message-content">
                    <p>#{detail_html}</p>
                    </div>
                    <div class="message-timestamp">
                    <p>#{new_date_text}</p>
                    </div>
                </div>
                </div>
            HTML

        post.details.create!(date: new_date_text, content: wrapped_html)
    end

    post
    rescue OpenURI::HTTPError, SocketError, Timeout::Error => e
        raise StandardError, "fetch failed: #{e.class}: #{e.message}"
    end
end
