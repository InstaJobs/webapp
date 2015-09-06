class DashboardController < ApplicationController
	#check login 
	before_action :check_login

	def index
		@user_id = session[:user_id]["$oid"]
		@user = User.find(@user_id)
		@user_name = @user.name
		@user_jobcount = @user.jobs.count
		@matches = @user.jobmatches.count(1)
		@propic = @user.avatar.url || "/assets/images/propic.jpg"
		@thumb = @user.avatar.thumb.url || "/assets/images/propic_thumb.jpg"
		@email = @user.email;
		@number = @user.number;
	end

	private 
	def check_login
		if session[:user_id].nil?
			redirect_to '/'
		end
	end

end
