class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :extend_token_expire
  after_filter :append_session_metadata

  private
  def validate_token
    token = params[:token]
    token_object = AccessToken.find_by_token(token)
    if !token_object || !token_object.user.validate_token(token)
      render json: {error: "Invalid token"}, status: 401
    end
  end

  def extend_token_expire
    token = params[:token]
    return if !token
    token_object = AccessToken.find_by_token(token)
    if token_object
      if !token_object.user.validate_token(token)
        @add_session_invalid = true
      end
    else
      @add_session_invalid = true
    end
  end

  def append_session_metadata
    if @add_session_invalid && response.content_type == "application/json"
      data = JSON.parse(response.body)
      data['meta'] ||= {}
      data['meta']['notifications'] ||= {}
      data['meta']['notifications']['session_invalid'] = true
      response.body = data.to_json
    end
  end
end
