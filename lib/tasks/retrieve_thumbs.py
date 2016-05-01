import urllib2, json, codecs, os, shutil

# make the dirs where we'll store the retrieved files
thumb_groups = ["medium_image_url", "annotation_thumb_url", "square_thumb_url"]

if not os.path.exists("placeholder_images"):
  os.makedirs("placeholder_images")

with open("placeholder_images.json", "r") as f:
  j = json.load(f)
  for k in j:
    for t in thumb_groups:
      filename = k[t].split("/")[-1]
      
      response = urllib2.urlopen( k[t] )
      out_destination = "placeholder_images/" + t + "_" + filename.split("?")[0] 
      
      print "fetching", out_destination      

      with open(out_destination, "wb") as out:
        out.write(response.read()) 
