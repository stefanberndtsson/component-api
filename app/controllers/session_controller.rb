# -*- coding: utf-8 -*-
require 'open-uri'
require 'pp'

class SessionController < ApplicationController
  def create
    user_force_authenticated = false
    if params[:cas_ticket] && params[:cas_service]
      username = cas_validate(params[:cas_ticket], params[:cas_service])
      user_force_authenticated = true
    else
      username = params[:username]
      password = params[:password]
    end
    user = User.find_by_username(username)
    if user
      token = user.authenticate(password, user_force_authenticated)
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

  def cas_validate(ticket, service)
    casBaseUrl = ENV['CAS_URL']
    casParams = {
      service: service,
      ticket: ticket
    }.to_param
    casValidateUrl = "#{casBaseUrl}/serviceValidate?#{casParams}"
    pp ["casValidateUrl", casValidateUrl]
    open(casValidateUrl) do |u| 
      doc = Nokogiri::XML(u.read)
      doc.remove_namespaces!
      pp ["reply", doc.to_xml]
      username = doc.search('//serviceResponse/authenticationSuccess/user').text
      return username if username
    end
  end
end
