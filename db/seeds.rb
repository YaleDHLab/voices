# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

20.times do |r|

  new_record = Record.new({
    :title => Faker::Book.title,
    :metadata => Faker::Lorem.sentence,
    :file_upload => File.new( Dir.glob("#{Rails.root}/app/assets/images/seed-images/*.jpg")[rand(0..249)] ),
    :cas_user_name => "ded34",
    :include_name => true,
    :content_type => "Image",
    :description => Faker::Lorem.paragraph,
    :location => Faker::Address.street_name + ", " + Faker::Address.city,
    :source_url => Faker::Internet.url,
    :release_checked => true,
    :date => Faker::Time.between(DateTime.now - 1, DateTime.now).to_s.split()[0].gsub(/-/, '/'),
    :hashtag => "#" + Faker::Hipster.words(4).join(" #")
  })

  new_record.save!
end
