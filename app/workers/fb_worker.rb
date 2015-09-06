class FbWorker
	include Sidekiq::Worker
	sidekiq_options queue: 'mail'

	def perform(arg1, arg2)
		@user = User.find(arg1)
		FbSignupMailer.password(@user, arg2).deliver
	end
end