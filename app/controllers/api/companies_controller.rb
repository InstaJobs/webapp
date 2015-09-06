class Api::CompaniesController < ApplicationController
	
	before_action :check_login

	def index
		@companies = Company.all
		if params.include?(:user_id)
			@user_id = session[:user_id]["$oid"]
			@user = User.find(@user_id)
			@companies = @user.companies
		end
		render :json => @companies, each_serializer: CompanySerializer
	end

	def create
		cp = createparams
		@user_id = session[:user_id]["$oid"]
		@user = User.find(@user_id)
		@c = Company.new
		@c.name = cp[:name]
		@c.url = cp[:url]
		@user.companies << @c
		if @user.save
			Analytics.track(
			  user_id: @user.id.to_s,
			  event: 'Company Create',
			  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent, company_name: @c.name}
			)
			render :json => {result: "success", id: @c.id}
		else
			render :json => {result: "error"}
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

	def createparams
		params.permit(:name, :url)
	end
end
