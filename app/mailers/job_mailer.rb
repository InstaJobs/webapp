class JobMailer < ApplicationMailer
	default :from => "support@instajobs.io"
	def saved(email, job, user)
		@job = job
		@user = user
		@propic = @user.avatar.url || "http://instajobs.io/assets/images/propic.jpg"
		@thumb = @user.avatar.thumb.url || "http://instajobs.io/assets/images/propic_thumb.jpg"
		domain = ENV["DOMAIN"] || "instajobs.io"; 
		@link = domain+"/dashboard/candidates/" + @job.id.to_s; 
		mail(to: email, subject: "A candidate is interested in your job posting")
	end
	def match(candidate, job)
		@candidate = candidate
		@job = job
		@thumb = @candidate.avatar.thumb.url || "http://instajobs.io/assets/images/propic_thumb.jpg"
		domain = ENV["DOMAIN"] || "instajobs.io"; 
		@link = domain+"/dashboard/matches/"; 
		mail(to: @candidate.email, subject: "Congrats, you have been matched with a job!");
	end
end
