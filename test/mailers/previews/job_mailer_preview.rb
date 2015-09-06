class JobMailerPreview < ActionMailer::Preview
	def saved
		JobMailer.saved(User.first, Job.first, User.first)
	end
	def match
		JobMailer.match(User.first, Job.first)
	end
end