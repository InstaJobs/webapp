class FbSignupMailerPreview < ActionMailer::Preview
	def password
		FbSignupMailer.password(User.last)
	end
end