# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  def current_user
    u = nil
    if !!session[:user_id]
      begin
        u = User.find(session[:user_id])
      rescue ActiveRecord::RecordNotFound => e
        session[:user_id] = nil
      end
    end
    u
  end

  def logged_in?
    !!current_user
  end
end
