class Api::UsersController < ApplicationController

	before_action :check_login
	
	def index
		@user_id = session["user_id"]["$oid"]
		@user = User.find(@user_id)
		if @user
			render :json => @user, serializer: UserSerializer
		else
			render :json => {result: "user not found"}
		end
	end

	def update
		up = updateparams(params)
		@user_id = session["user_id"]["$oid"]
		@user = User.find(@user_id)
		if @user
			if up.include?(:oldpassword)
				if @user.authenticate(up[:oldpassword])
					@user.password = up[:newpassword]
					if @user.save
						render :json => {result: "success"}
					else
						render :json => {result: @user.errors.full_messages.join(" ")}
					end
				else
					render :json => {result: "wrong old password"}
				end
			else
				@user.name = up[:name]
				@user.bio = up[:bio]
				@user.skills = up[:skills]
				@user.number = up[:number]
				@user.sex = up[:sex]
				if @user.save
					render :json => {result: "success"}
				else
					render :json => {result: @user.errors.full_messages.join(" ")}
				end
			end
			Analytics.track(
			  user_id: @user_id,
			  event: 'Profile Update',
			  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent}
			)
		else
			render :json => {result: "user not found"}
		end
	end

	def savedjobs
		@user_id = session[:user_id]["$oid"]
		@user = User.find(@user_id)
		if @user
			render :json => @user.jobs, each_serializer: JobSerializer
		else
			render :json => {result: "user not found"}
		end
	end

	def uploadpropic
		@user_id = session[:user_id]["$oid"]
		file = params[:file]
		@user = User.find(@user_id)
		@user.avatar = file
		@user.save!
		render :json => {:result => "success"}
	end

	def propicuploadstat
		@user_id = session[:user_id]["$oid"]
		@user = User.find(@user_id)
		@stat = @user.avatar_processing
		unless @stat
			render :json => {result: @stat, url: @user.avatar.url, thumburl: @user.avatar.thumb.url}
		else
			render :json => {result: @stat} 
		end
	end

	private
	def check_login
		if params[:token].nil?
			if session[:user_id].nil?
				redirect_to '/'
			end
		else
			return true
		end
	end

	def updateparams(params)
		params.permit(:name, :newpassword, :oldpassword, :bio, :skills, :number, :sex)
	end
end
