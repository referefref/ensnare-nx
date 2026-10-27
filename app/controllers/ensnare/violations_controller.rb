


module Ensnare
  class ViolationsController < ApplicationController
    before_action :ensnare, :only=>:routing_error
    skip_before_action :check_privileges
    layout 'ensnare/application'

    def redirect
      redirect_to redir_url(:id=>Random.rand(1000000))
    end

    def captcha
      # The captcha response needs the recaptcha gem in the application
      raise ActionController::RoutingError.new('Not Found') unless respond_to?(:verify_recaptcha, true)
      respond_to do |format|
        if verify_recaptcha
          session["ensnare"] ||= {}
          session["ensnare"]["captcha_solved"] = true
          redirect_to main_app.root_url
          return
        else
          format.html { render :layout=> 'ensnare/captcha' }
        end
      end
    end


    def routing_error

      raise ActionController::RoutingError.new('Not Found')
    end



  end
end
