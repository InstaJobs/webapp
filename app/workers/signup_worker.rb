class SignupWorker
	include Sidekiq::Worker
	sidekiq_options queue: 'mail'

	def perform(arg1)
		@user = User.find(arg1)
	  SignupMailer.signup_link(@user).deliver
	end
end