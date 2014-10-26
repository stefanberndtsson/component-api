class SessionController < ApplicationController
  def create
    user = User.find_by_username(params[:username])
    if user
      token = user.authenticate(params[:password])
      if token
        render json: {user: user, access_token: token, token_type: "bearer"}
        return
      end
    end
    render json: {error: "Invalid credentials"}, status: 401
  end
  
  def show
    token = params[:id]
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.user.validate_token(token)
      render json: {user: token_object.user, access_token: token, token_type: "bearer"}
    else
      render json: {error: "Invalid session"}, status: 401
    end
  end
end
