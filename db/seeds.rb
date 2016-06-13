#This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

tmp = File.read(Rails.root.join('lib/assets/DOWN.txt')).scan(/.{2500}/)


#img = File.new( Dir.glob("#{Rails.root}/app/assets/images/seed-images/*.jpg")[rand(0..249)] )
txt = File.new( Dir.glob("#{Rails.root}/app/assets/texts/sample.txt")[0])



# seed each admin's database
ENV["VOICES_ADMINS"].split("#").each do |username|

    '''
    if username == "ded34"
        next
    end
    '''

    tmp.each do |desc|

        new_record = Record.new({
            :title => Faker::Book.title,
            :cas_user_name => username,
            :make_private => false,
            :description => desc,
	    :location => Faker::Address.street_name + ", " + Faker::Address.city,
            :source_url => Faker::Internet.url,
            :release_checked => true,
            :date => DateTime.now-rand(0.1..1),
            :hashtag => "#" + Faker::Hipster.words(4).join(" #")
        })

        i = new_record.save!

        # create eather 1, 8, or 24 attachments for this record
        #[1, 8, 24][rand(0..2)].times do
            new_record_attachment = RecordAttachment.new({
                :record_id => new_record.id,
                :annotation => Faker::Lorem.sentence,
                :file_upload => txt, 
                :cas_user_name => username,
                :is_seed => true
            })

            new_record_attachment.save!
        #end 
    end
end


#initiate database for Cloud on homepage.
CloudWord.delete_all

cloud = CloudWord.new()
cloud.words = CloudWord.generate
cloud.save
