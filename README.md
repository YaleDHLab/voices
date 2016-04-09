### Local development  
  
<pre><code># start postgres db  
postgres -D /usr/local/var/postgres  
  
# run the rails server   
rails s {-e production} # to serve in production environment  
  
# run the rails console  
rails c {production} # to run console in production context

# drop the database and repopulate afresh
rake db:drop db:create db:migrate</code></pre>

### Deploy to Heroku

<pre><code># create heroku instance  
heroku create voices-dev  
  
# add support for multiple build packs  
heroku buildpacks:set https://github.com/ddollar/heroku-buildpack-multi.git  
  
# push local master branch to remote / heroku host  
git push heroku master  

# set environment variables  
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
