# app/controllers/api/details_controller.rb
module Api
  class DetailsController < ApplicationController
    def index
      post = Post.find(params[:post_id])
      render json: post.details.pluck(:content)
    end
  end
end
