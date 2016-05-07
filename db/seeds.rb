# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# seed each admin's database
ENV["VOICES_ADMINS"].split("#").each do |username|

    if username == "ded34"
        next
    end

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
                :cas_user_name => username
            })

            new_record_attachment.save!
        end 
    end
end
