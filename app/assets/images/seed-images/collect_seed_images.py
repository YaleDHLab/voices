from random import randint
import subprocess, os, glob

# collect 100 seed images
for i in xrange(100):
  url = "https://unsplash.it/" + str(randint(300,600)) + "/" + str(randint(300,600)) + "?random"
  subprocess.call("wget " + url, shell=True)

# rename the files
for i in glob.glob("*"):
  if ".py" in i:
    continue
  else:
    os.rename(i, i.replace(".jpg","") + ".jpg")
