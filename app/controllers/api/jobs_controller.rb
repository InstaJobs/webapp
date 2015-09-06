class Api::JobsController < ApplicationController

	before_action :check_login

	def index
		@jobsall = Job.order("created_at DESC").where(:visible => true)
		@sjobsall = ActiveModel::ArraySerializer.new(@jobsall, each_serializer: JobSerializer)
		if params.include?(:user_id)
			@user_id = session[:user_id]["$oid"]
			@user = User.find(@user_id)
			@companies = @user.companies
			@jobsall = []
			@companies.each do |c|
				c.jobs.each{|j| @jobsall << j}
			end
			@sjobsall = ActiveModel::ArraySerializer.new(@jobsall, each_serializer: MatchSerializer)
		end
		if params.include?(:lat)
			lat = params[:lat]
			lng = params[:lng]
			radius = params[:radius].to_f / 111.12 
			address = Geocoder.address([lat.to_f, lng.to_f])
			@jobs = Job.geo_near([lat.to_f, lng.to_f]).max_distance(radius.to_f)
			@sjobs = []
			@jobs.each{|j| @sjobs << j if j.visible}
			@sjobs = ActiveModel::ArraySerializer.new(@sjobs, each_serializer: JobSerializer)
			count = 0
			@jobs.each{|j| count+=1}
			if count == 0
				render :json => {jobs: @sjobsall, address: address, all: true}
				return
			end
			render :json => {jobs: @sjobs, address: address}
			return
		elsif params.include?(:address)
			address = params[:address]
			lat, lng = Geocoder.coordinates(address);
			radius = params[:radius].to_f / 111.12
			@jobs = Job.geo_near([lat.to_f, lng.to_f]).max_distance(radius.to_f)
			@sjobs = []
			@jobs.each{|j| @sjobs << j if j.visible}
			@sjobs = ActiveModel::ArraySerializer.new(@sjobs, each_serializer: JobSerializer)
			count = 0
			@jobs.each{|j| count+=1}
			if count == 0
				render :json => {jobs: @sjobsall, lat: lat, lng: lng, all: true}
				return
			end
			render :json => {jobs: @sjobs, lat: lat, lng: lng}
			return
		end
		render :json => {jobs: @sjobsall, all: true}
		return
	end

	def show
		@jobid = params[:id]
		@job = Job.find(@jobid)
		unless @job
			render :json => {"result" => "job not found"}
		end
			render :json => @job, serializer: JobSerializer
	end

	def create
		cp = createparams(params)
		@company = Company.find(cp[:companyid])
		@user_company = @company.user_id.to_s
		@user_id = session[:user_id]["$oid"]
		@user = User.find(@user_id)
		unless @user_id == @user_company
			render :json => {"result" => "error from here"}
			return
		end
		@job = Job.new
		@job.title = cp[:title]
		@job.description = cp[:description]
		@job.salary = cp[:salary]
		@job.hours = cp[:hours]
		@job.responsibility = cp[:responsibility]
		@job.location = [cp[:lat], cp[:lng]]
		@job.address = cp[:address]
		@job.created_at = Time.now
		@job.jobmatches = []
		@job.email = cp[:email]
		@job.visible = true;
		@job.number = cp[:number]
		@job.save
		@company.jobs << @job
		if @company.save
			Analytics.track(
			  user_id: @user_id,
			  event: 'Job Post',
			  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent, job_title: @job.title}
			)
			render :json => {"result" => "success", "id" => @job.id, "address" => @job.address}
		else
			render :json => {"result" => "error"}
		end
	end

	def update
		up = updateparams(params)
		@job = Job.find(up[:id].to_s)
		@companyid = up[:companyid]
		@user_id = session[:user_id]["$oid"]
		@company = Company.find(@companyid)
		@user = User.find(@user_id)
		unless @company.user_id.to_s == @user_id
			render :json => {"result" => "not authorized"}
			return
		end
		unless @job
			render :json => {"result" => "job not found"}
			return
		end
		@job.title = up[:title]
		@job.description = up[:description]
		@job.salary = up[:salary]
		@job.hours = up[:hours]
		@job.responsibility = up[:responsibility]
		@job.location = [up[:lat], up[:lng]]
		@job.address = up[:address]
		@job.email = up[:email]
		@job.number = up[:number]
		if @job.save
			Analytics.track(
			  user_id: @user_id,
			  event: 'Job Update',
			  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent, job_title: @job.title}
			)
			render :json => {"result" => "success"}
		else
			render :json => {"result" => "error"}
		end
	end

	def destroy
		dp = deleteparams(params)
		@job = Job.find(dp[:id].to_s)
		@companyid = dp[:companyid]
		@user_id = session[:user_id]["$oid"]
		@user = User.find(@user_id)
		@company = Company.find(@companyid)
		unless @company.user_id.to_s == @user_id
			render :json => {"result" => "not authorized"} 
		end
		unless @job
			render :json => {"result" => "job not found"}
			return
		end
		if @job.destroy
			Analytics.track(
			  user_id: @user_id,
			  event: 'Job Delete',
			  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent, job_title: @job.title}
			)
			render :json => {"result" => "success"}
		else
			render :json => {"result" => "error"}
		end
	end

	def addJob
		@user_id = session[:user_id]["$oid"]
		@user = User.find(@user_id)
		@job = Job.find(params[:job_id])
		if @user.jobs.include?(@job)
			render :json => {"result" => "Job already added to your Saved Jobs."}
		elsif @job.company.user.id.to_s == @user_id
			render :json => {"result" => "Job is posted by you, you cannot apply for your own job"}
		else
			Analytics.track(
			  user_id: @user_id,
			  event: 'Job Liked',
			  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent, job_title: @job.title}
			)
			@user.jobs << @job;
			@user.jobmatches << 0;
			@job.jobmatches << 0;
			@job.save
			@user.save;
			#send mail to employer
			JobMailWorker.perform_async("saved", @job.id.to_s, @user.id.to_s)
			render :json => {"result" => "success"}
		end
	end

	def removeJob
		@user_id = session[:user_id]["$oid"]
		@user = User.find(@user_id)
		@job = Job.find(params[:job_id])
		if @user.jobs.include?(@job)
			Analytics.track(
			  user_id: @user_id,
			  event: 'Job Disliked',
			  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent, job_title: @job.title}
			)
			@ind = @user.jobs.index(@job);
			@user.jobs.delete(@job)
			@user.jobmatches.delete_at(@ind)
			@ind = @job.users.index(@user)
			@job.users.delete_at(@ind)
			@job.jobmatches.delete_at(@ind)
			@job.save
			@user.save
			render :json => {"result" => "success"}
		else
			render :json => {"result" => "job not saved"}
		end
	end

	def candidates
		@jobid = params[:jobid]
		@job = Job.find(@jobid)
		@users = @job.users
		unless @job
			render :json => {"result" => "job not found"}
		end
		render :json => @users, each_serializer: UserSerializer
	end

	def match
		@candidate_id = params[:cid]
		@candidate = User.find(@candidate_id)
		@job_id = params[:jid]
		@job = Job.find(@job_id)
		@user_id = session["user_id"]["$oid"]
		@user = User.find(@user_id)
		@company = @job.company
		unless @company.user_id.to_s == @user_id
			render :json => {"result" => "not authorized"}
			return
		end
		@ind = @job.users.index(@candidate)
		@job.jobmatches[@ind] = 1
		Analytics.track(
		  user_id: @user_id,
		  event: 'Job Match',
		  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent, job_title: @job.title, candidate_id: @candidate_id}
		)
		#send a mail to candidate
		JobMailWorker.perform_async("match", @candidate.id.to_s, @job.id.to_s)
		@job.save
		@ind = @candidate.jobs.index(@job)
		@candidate.jobmatches[@ind] = 1
		@candidate.save
		render :json => {"result" => "success"}
	end

	def removematch
		@candidate_id = params[:cid]
		@candidate = User.find(@candidate_id)
		@job_id = params[:jid]
		@job = Job.find(@job_id)
		@user_id = session["user_id"]["$oid"]
		@user = User.find(@user_id)
		@company = @job.company
		unless @company.user_id.to_s == @user_id
			render :json => {"result" => "not authorized"}
			return
		end
		Analytics.track(
		  user_id: @user_id,
		  event: 'Job Mismatch',
		  properties: {email: "#{@user.email}", name: "#{@user.name}", ip: request.remote_ip, agent: request.user_agent, job_title: @job.title, candidate_id: @candidate_id}
		)
		@ind = @job.users.index(@candidate)
		@job.jobmatches[@ind] = 0
		@job.save
		@ind = @candidate.jobs.index(@job)
		@candidate.jobmatches[@ind] = 0
		@candidate.save
		render :json => {"result" => "success"}
	end

	def mymatches
		@user_id = session["user_id"]["$oid"]
		@user = User.find(@user_id)
		@jobs = []
		for i in (0...(@user.jobs.size))
			if @user.jobmatches[i] == 1
				@jobs << @user.jobs[i]
			end
		end
		render :json => @jobs, each_serializer: MatchSerializer
	end

	def matchedusers
		@jobid = params[:jobid]
		@job = Job.find(@jobid)
		@users = @job.users
		@matches = @job.jobmatches
		@matchedusers = []
		for i in 0...(@users.size)
			@user = @users[i]
			if @matches[i] == 1
				@matchedusers << @user
			end
		end
		@smatchedusers = ActiveModel::ArraySerializer.new(@matchedusers, each_serializer: UserSerializer)
		render :json => @smatchedusers
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
		params.permit(:id, :title, :description, :salary, :email, :number, :hours, :lat, :lng, :companyid, :responsibility, :address)
	end

	def createparams(params)
		params.permit(:title, :description, :email, :number, :salary, :hours, :lat, :lng, :companyid, :responsibility, :address)
	end

	def deleteparams(params)
		params.permit(:id, :companyid)
	end

end
