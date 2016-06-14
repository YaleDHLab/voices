import base64, json, hmac, hashlib, os



with open("aws_bucket_policy.json") as f:
  # load the aws bucket policy
  policy_document = f.read()
  
  policy = base64.b64encode(policy_document)
  signature = base64.b64encode(hmac.new(os.environ["AWS_SECRET_ACCESS_KEY"], policy, hashlib.sha1).digest())

  print "policy = ", policy
  print "signature = ", signature