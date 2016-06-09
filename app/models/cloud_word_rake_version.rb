
#create word_local with Rake.
 #   rake = RakeText.new
 #   #query public archives within time_range, return descriptions.
 #   text = Record.where(date: time_range, make_private: false).pluck(:description)
 #   text = text.join(".~~~")

 #   #apply RAKE with SMART stoplist. (other option is FOX)
 #   output = rake.analyse text, RakeText.SMART

 #   #keep only keyphrases with single word and RAKE value > 0
 #   output.delete_if {|k, v| k.split.length > 1}
 #   output.delete_if {|k, v| v == 0}

 #   #sort by score. Keep top word_total keywords
 #   output = output.sort_by {|k,v| -v}[0..word_total]
 #   output = Hash[output]
 #   words_local = output.keys

 #		#choose at most 5% of all words or word_total words
 #		word_total = [word_total, words_local.length * 0.05]
