class PostsController < ApplicationController
  rescue_from StandardError, with: :render_error

  # 投稿一覧
  def index
    posts = Post.select(:id, :title, :published_at, :created_at).order(created_at: :asc)
    render json: posts
  end

  # スクレイピング登録
  def scrape
    urls = params[:urls] || []
    date = params[:date] # YYYY-MM-DD

    post_ids = []

    urls.each_with_index do |url, index|
      begin
        post = ScrapeService.new(url, date).call(index)
        post_ids << post.id
      rescue => e
        Rails.logger.error "Scrape failed for #{url}: #{e.message}"
      end
    end

    render json: { status: 'ok', post_ids: post_ids }
  end

  # 投稿詳細
def show
  post = Post.includes(:details).find_by(id: params[:id])
  if post
    render json: {
      id: post.id,
      title: post.title,
      published_at: post.published_at,
      created_at: post.created_at,
      details: post.details.order(:id).map { |d|
        { id: d.id, date: d.date, content: d.content }
      }
    }
  else
    render json: { status: 'error', message: '投稿が見つかりません' }, status: 404
  end
rescue => e
  render json: { status: 'error', message: e.message }, status: 500
end


  # 投稿削除
  def destroy
    post = Post.find(params[:id])
    post.destroy
    render json: { status: 'deleted' }
  end

  private

  def render_error(e)
    render json: { status: 'error', message: e.message }, status: 500
  end
end
