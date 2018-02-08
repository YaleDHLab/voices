# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# seed each admin's database if admins are defined, else seed
# random usernames and warn at the console
if ENV['VOICES_ADMINS'].nil?
  user_name_array = ['sample_user_1', 'sample_user_2', 'sample_user_3']
else
  user_name_array = ENV['VOICES_ADMINS'].split('#')
end

# Ruby requires double quotes for interpolation

images = Dir.glob("#{Rails.root}/app/assets/images/seed-images/*.jpg")

user_name_array.each do |username|
  3.times do |r|
    puts 'saving record', r, 'for', username

    # generate a data
    date = Faker::Time.between(DateTime.now - 1, DateTime.now)

    new_record = Record.new({
      :title => Faker::Book.title,
      :cas_user_name => username,
      :make_private => false,
      :description => Faker::Lorem.paragraph,
      :location => Faker::Address.street_name + ', ' + Faker::Address.city,
      :release_checked => true,
      :date => date.to_s.split()[0].gsub(/-/, '/'),
      :hashtag => '#' + Faker::Hipster.words(4).join(' #')
    })

    i = new_record.save!

    # create eather 1, 8, or 24 attachments for this record
    [1, 8, 24][rand(0..2)].times do
      new_record_attachment = RecordAttachment.new({
        :record_id => new_record.id,
        :annotation => Faker::Lorem.sentence,
        :file_upload => File.open( images[rand(0..249)] ),
        :cas_user_name => username,
        :is_seed => true
      })

      new_record_attachment.save!
    end
  end
end
