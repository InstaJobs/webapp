class FbSignupMailer < ApplicationMailer
	default :from => "support@instajobs.io"
	def password(user, pass)
		@user = user
		@password = pass
		mail(to: user.email, subject: "InstaJob password")
	end
end
