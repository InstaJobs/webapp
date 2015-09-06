class JobMailWorker
	include Sidekiq::Worker
	sidekiq_options queue: 'mail'

	def perform(method, arg1, arg2)
		if method == 'saved'
			@job = Job.find(arg1)
			@user = User.find(arg2)
			JobMailer.saved(@job.email, @job, @user).deliver
		else
			@candidate = User.find(arg1)
			@job = Job.find(arg2)
			JobMailer.match(@candidate, @job).deliver
		end
	end
end