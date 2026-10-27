
module Ensnare
  class DashboardController < ApplicationController
    layout 'ensnare/dashboard'
    
    def mode
      #render mode erb, read config file and toggle switches
      @mode = Ensnare.mode
      @timer = Ensnare.global_timer
    end

    def metrics
      #@violations = Ensnare::Violation.where("created_at >= ?", Time.now-Ensnare.global_timer.seconds)
      @violations = Ensnare::Violation.all

      @violations_by_type= Ensnare::Violation.group(:violation_type).order(Arel.sql("count_all desc")).limit(params[:limit]||25).offset(params[:offset]||0).count
      @violations_by_ip = Ensnare::Violation.group(:ip_address).order(Arel.sql("count_all desc")).limit(params[:limit]||25).offset(params[:offset]||0).count
      @violations_by_session = Ensnare::Violation.group(:session_id).order(Arel.sql("count_all desc")).limit(params[:limit]||25).offset(params[:offset]||0).count
      @violations_by_user_id = Ensnare::Violation.group(:user_id).order(Arel.sql("count_all desc")).limit(params[:limit]||25).offset(params[:offset]||0).count

    end

    def configs
      @timer = Ensnare.global_timer
    end

    def violations
      @violations = Ensnare::Violation.order("created_at DESC").limit(100)
    end


  end
end
