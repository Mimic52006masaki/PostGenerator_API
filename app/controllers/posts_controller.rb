class PostsController < ApplicationController
  def index
    posts = Post.order(created_at: :desc).select(:id, :title, :created_at)
    render json: posts
  end

  def show
    post = Post.includes(:details).find(params[:id])
    render json: {
      id: post.id,
      title: post.title,
      details: post.details.order(:id).map { |d| { id: d.id, date: d.date, content: d.content } }
    }
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy!
    render json: { status: 'deleted' }
  end
end
