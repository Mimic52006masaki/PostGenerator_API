require 'open-uri'
require 'nokogiri'

class ScrapeService
  TIMES = (7..21).map { |h| "#{h}:00" }

  def initialize(url, date = nil)
    @url = url
    @date = date
  end

  def call(index = 0)
    html = URI.open(@url, read_timeout: 20, open_timeout: 10, 'User-Agent' => 'Mozilla/5.0').read
    doc  = Nokogiri::HTML.parse(html)

    body = doc.at('article.post') || doc
    title_text = body.at('h1.post__title')&.text&.strip.presence || URI.parse(@url).host

    contents = body.css('div.post__content')
    container = contents.first || body

    date_nodes   = container.css('div.t_h')
    detail_nodes = container.css('div.t_b')

    count = [date_nodes.size, detail_nodes.size].min
    time = TIMES[index % TIMES.size]
    published_at = @date.present? ? "#{@date} #{time}" : nil

    post = Post.create!(title: title_text, published_at: published_at)

    count.times do |i|
      raw_text = date_nodes[i]&.text&.strip.to_s
      parts = raw_text.split
      new_date_text = parts.any? ? "#{parts[0]} アニメまとめCH #{parts[-1]}" : ''

      detail_html = detail_nodes[i]&.inner_html.to_s

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
