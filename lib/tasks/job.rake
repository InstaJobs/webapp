namespace :job do
  desc "TODO"
  task visible: :environment do
  	Job.all.each do |job|
	  	if (Time.now - job.created_at) / 1.day <= 30
				job.visible = true
			else
				job.visible = false
			end
			job.save
		end
		puts "Updates Jobs visibility"
  end
end
