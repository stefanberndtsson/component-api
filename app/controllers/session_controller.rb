class SessionController < ApplicationController
  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      render json: {access_token: user.token, token_type: "bearer"}
    else
      render json: {error: "Invalid credentials"}, status: 401
    end
  end
end
