class SignupMailerPreview < ActionMailer::Preview
	def signup_link
		SignupMailer.signup_link(User.last)
	end
end