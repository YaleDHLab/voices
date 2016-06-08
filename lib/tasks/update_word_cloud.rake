desc "this task is called by the Heroku scheduler add-on"

task :update_word_cloud=> :environment do
	if Time.now.saturday?
		CloudWord.delete_all

		cloud = CloudWord.new()
		cloud.words = CloudWord.generate
		cloud.save
	end
end
