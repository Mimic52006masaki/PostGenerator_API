class ScrapesController < ApplicationController
  def create
    urls = Array(params[:urls]).map(&:to_s).reject(&:blank?)
    return render json: { error: 'urls required' }, status: :bad_request if urls.empty?

    posts = []
    errors = []

    urls.each do |url|
      begin
        post = ScrapeService.new(url).call
        posts << { id: post.id, title: post.title }
      rescue => e
        errors << { url: url, error: e.message }
      end
    end

    status = errors.empty? ? :ok : :multi_status
    render json: { status: 'ok', posts: posts, errors: errors }, status: status
  end
end
