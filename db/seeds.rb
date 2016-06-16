# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# seed each admin's database if admins are defined, else seed
# random usernames and warn at the console
stored_admin_usernames = ENV["VOICES_ADMINS"]

if stored_admin_usernames.nil?
    user_name_array = ["sample_user_1", "sample_user_2", "sample_user_3"]
else
    user_name_array = stored_admin_usernames.split("#")
end

user_name_array.each do |username|

    7.times do |r|

        new_record = Record.new({
            :title => Faker::Book.title,
            :cas_user_name => username,
            :make_private => false,
            :description => Faker::Lorem.paragraph,
            :location => Faker::Address.street_name + ", " + Faker::Address.city,
            :source_url => Faker::Internet.url,
            :release_checked => true,
            :date => Faker::Time.between(DateTime.now - 1, DateTime.now).to_s.split()[0].gsub(/-/, '/'),
            :hashtag => "#" + Faker::Hipster.words(4).join(" #")
        })

        i = new_record.save!

        # create eather 1, 8, or 24 attachments for this record
        [1, 8, 24][rand(0..2)].times do
            new_record_attachment = RecordAttachment.new({
                :record_id => new_record.id,
                :annotation => Faker::Lorem.sentence,
                :file_upload => File.new( Dir.glob("#{Rails.root}/app/assets/images/seed-images/*.jpg")[rand(0..249)] ),
                :cas_user_name => username,
                :is_seed => true
            })

            new_record_attachment.save!
        end 
    end
end

# create new cloudword model
CloudWord.delete_all

cloud = CloudWord.new()
cloud.words = CloudWord.generate
cloud.save