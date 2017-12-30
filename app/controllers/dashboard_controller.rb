class DashboardController < ApplicationController
  def index
  end

  def pricing 
		@stripe_list = Stripe::Plan.all
		@plans = @stripe_list[:data]
	end

end
