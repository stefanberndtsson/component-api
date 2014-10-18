class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  
  private
  def validate_token
    token = params[:token]
    user = User.find_by_token(token)
    if !user || !user.validate_token(token)
      render json: {error: "Invalid token"}, status: 401
    end
  end
end
