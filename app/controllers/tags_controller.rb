class TagsController < ApplicationController
  def index
    @tags = Tag.all
    render json: { tags: @tags }
  end
end
