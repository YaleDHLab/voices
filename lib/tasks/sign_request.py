# requires python 2.7
import base64, json, hmac, hashlib, os

with open('aws_bucket_policy.json') as f:
  # load the aws bucket policy
  policy = base64.b64encode( f.read() )
  access_key = os.environ['AWS_SECRET_ACCESS_KEY']
  digest = hmac.new(access_key, policy, hashlib.sha1).digest()
  signature = base64.b64encode(digest)
  print('policy = ', policy)
  print('signature = ', signature)