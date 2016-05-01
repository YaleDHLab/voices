### Dependencies

This application depends on PostgreSQL for its db, ImageMagick for image processing, FFMPEG for video processing, and Ghostscript for PDF processing. On OSX, you can install these dependencies with homebrew:
<pre><code>brew install postgresql  
brew install imagemagick  
brew install ffmpeg
brew install ghostscript</code></pre>

### Local development  
  
<pre><code># start postgres db  
postgres -D /usr/local/var/postgres  
  
# run the rails server   
rails s {-e production} # to serve in production environment  
  
# run the rails console  
rails c {production} # to run console in production context

# drop the database and repopulate afresh
rake db:drop db:create db:migrate db:seed {RAILS_ENV="production"}  

# the application will now be available at localhost:3000</code></pre>

### Deploy to Heroku

<pre><code># create heroku instance  
heroku create voices-dev  
  
# add support for multiple buildpacks  
heroku buildpacks:set https://github.com/ddollar/heroku-buildpack-multi.git --app {your_app_name} 
  
# compile and minify assets if necessary
bundle exec rake assets:precompile RAILS_ENV=production

# update master branch if necessary
git add .
git commit -m "updated master branch before heroku deploy"

# push local master branch to remote heroku host  
git push heroku master  

# set environment variables  
heroku config:set VOICES_ADMINS={a_hasbang_separated_list_of_admin_cas_ids}
heroku config:set GMAIL_USERNAME={a_gmail_email_address}  
heroku config:set GMAIL_PASSWORD={gmail_password_for_account_above}
heroku config:set AWS_S3_BUCKET_NAME={your_aws_s3_bucket_name}  
heroku config:set AWS_ACCESS_KEY_ID={your_aws_access_key_id}  
heroku config:set AWS_SECRET_ACCESS_KEY={your_aws_access_key}  
  
# drop the heroku db  
heroku pg:reset DATABASE  
  
# run migrations  
heroku run rake db:migrate  

# seed database
heroku run rake db:seed
  
# restart the dyno  
heroku restart  
  
# open the application in a browser  
heroku open</code></pre>  

### Debugging on Heroku   
<pre><code># to debug on heroku, you can open a terminal with the following command:  
heroku run bash  
  
# to run the rails console on heroku  
heroku run rails c  
  
# to populate a list of all heroku instances:  
heroku apps  

# to show all remote branches for a heroku instance:  
git config --list | grep heroku  

# to destroy a heroku app:  
heroku apps:destroy --app {{ app_name }}</code></pre>  
  
### Package management
This site uses Gemfile to manage rails packages, and Bower to manage javascript packages. To see a list of available bower commands, run:  
<pre><code># To initialize bower afresh (which will create a new Bowerfile)  
rails g bower_rails:initialize  
  
# To install bower packages  
bundle exec rake bower:install</code></pre>  
  
Bower assets will be installed to `vendor/assets/bower_components/`. To see a list of bower commands provided by bower-rails: `bundle exec rake -T bower`  
  
### Changing placeholder images  
`/lib/tasks/retrieve_thumbs.py` is a helper script meant to quickly fetch all placeholder images in all formats used by the app (square thumb, annotation thumb, and medium). It expects to read in a `placeholder_images.json` file that contains a json array of the following format:  
<pre><code>[
  {
    "annotation": null,  
    "annotation_thumb_url": "http://voices-uploads.s3.amazonaws.com/record_attachments/file_uploads/000/000/024/annotation_thumb/psd.png?1462116938",  
    "created_at": "2016-05-01T15:35:38.995Z",  
    "file_upload_content_type": "image/png",  
    "file_upload_file_name": "psd.png",  
    "file_upload_file_size": 11105,  
    "file_upload_updated_at": "2016-05-01T15:35:38.744Z",  
    "file_upload_url": null,  
    "id": 24,  
    "media_type": "image",  
    "medium_image_url": "http://voices-uploads.s3.amazonaws.com/record_attachments/file_uploads/000/000/024/medium/psd.png?1462116938",  
    "record_id": 3,  
    "square_thumb_url": "http://voices-uploads.s3.amazonaws.com/record_attachments/file_uploads/000/000/024/square_thumb/psd.  png?1462116938",  
    "updated_at": "2016-05-01T15:35:38.995Z"  
    },  
]</code></pre>

Each member of the array represents a single RecordAttachment object. The easiest way to replace the placeholder images is to simply create a new Record, attach all of the placeholder images you wish you use as attachments for that Record, and then use the Record.id from the newly created object to grab the relevant json in the format described above. You can do so as follows:  
<pre><code>rails c  
f = File.new("placeholder_images.json", "w")   
f &lt;&lt; RecordAttachment.where(record_id: {{your_record_id}})  
f.close()</code></pre>

You can then run the script to fetch the placeholder images by running (from the root of the application):  
<pre><code>cd lib/tasks  
python retrieve_thumbs.py</code></pre>
