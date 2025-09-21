class ScrapesController < ApplicationController
  def create
    urls = Array(params[:urls]).map(&:to_s).reject(&:blank?)
    date = params[:date]
    return render json: { error: 'urls required' }, status: :bad_request if urls.empty?

    posts = []
    errors = []

    urls.each_with_index do |url, index|
      begin
        post = ScrapeService.new(url, date).call(index)
        posts << { id: post.id, title: post.title, published_at: post.published_at }
      rescue => e
        errors << { url: url, error: e.message }
      end
    end

    status = errors.empty? ? :ok : :multi_status
    render json: { status: 'ok', posts: posts, errors: errors }, status: status
  end
end
