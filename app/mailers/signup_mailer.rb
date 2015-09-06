class SignupMailer < ApplicationMailer
	default :from => "support@instajobs.io"
	def signup_link(user)
		@user = user
		domain = ENV["DOMAIN"] || "instajobs.io"; 
		@link = domain+"/verify?token=" + @user.email_verify_token; 
		mail(to: user.email, subject: "InstaJobs Email Verification")
	end
end
