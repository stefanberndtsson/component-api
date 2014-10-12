class AmountsController < ApplicationController
  def index
    @amounts = Amount.all
    render json: { amounts: @amounts }
  end
end
