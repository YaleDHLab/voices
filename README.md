### Dependencies

This application depends on PostgreSQL, ImageMagick, and FFMPEG. On OSX, you can install these dependencies with homebrew:
<pre><code>brew install postgresql  
brew install imagemagick  
brew install ffmpeg</code></pre>

### Local development  
  
<pre><code># start postgres db  
postgres -D /usr/local/var/postgres  
  
# run the rails server   
rails s {-e production} # to serve in production environment  
  
# run the rails console  
rails c {production} # to run console in production context

# drop the database and repopulate afresh
rake db:drop db:create db:migrate  

# the application will now be available at localhost:3000</code></pre>

### Deploy to Heroku

<pre><code># create heroku instance  
heroku create voices-dev  
  
# add support for multiple buildpacks  
heroku buildpacks:set https://github.com/ddollar/heroku-buildpack-multi.git  
  
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
