class CloudWord < ActiveRecord::Base

  # Helper for self.generate(): choose top percent words.
  def self.top_percent_keys (hash, percent)
    len = hash.length
    hash.keys[(1-percent)*len..len]
  end

  # Helper to remove rot13 soft encryption from bad words
  def rot_13(s)
    return s.tr 'A-Za-z','N-ZA-Mn-za-m'
  end

  def self.generate()
    word_pool = "outusing represent colleges exams todays ashamed remarkable whoever child dollar resistance month laura springfling2016 thoughtful mile classic asian grateful gladly messy follow remarkably conversation integrity issues disingenous protest praises wish uphold berkeleys honoring pretense acting opportunities former wilsons 1930s excluded stable teaching sorry agaisnt worth resources investments paying juliana louder worse equivocal zhang very could slaveholder none didn’t choice georgia balancing decide confederate telling calhounhonorscollege jettison everandalways chapel severely school weareloved scholar purely supports joel murrays attempts leader peoe coming progress yale hereyou 강남야구장01021543560 yall someday says instagram lecturing tired queer inconsequential mural soul past talks second street video perspective earth writing james wilson universities what yonas centering power violentyale giving deeply tirelessly celebrated sikessitin debate current grown waiting absolute goes infamous avenues celebrates public everybody movement body lessons justification hero chose degree never judges here whiteness hours guise beacon voyeurism calhounpissing address active sing november sine hallsofwhitesupremacyyale change every sending studentsll kids turner forum hearts study changed whine despicable experience proud whiny credit placate descended arent abolition pick weird studies honor thats named appended love family extra duct presidents explained sign logical semester names fake apply blktwitterstorians takele namesimages goetz shareholders defies flaws figure would prove positive placenaming display tears hashtag insult campuswide live doubt wondering tokenize timing black themselves nobrainer monae tell today secured knows started becomes inclined under about takedowntheflagmsu symbolizing flag beholden yale20xxspeaks announce known foundations hold women high keeping word wouldnt rights this 강남풀싸롱01021543560 work refusing advocacy memorialization offended remain trauma values 강남야구장 learn following meet didnt example complain history beautiful fists dedicated blight embarrassing want hears give preserving accept terrible supremacy heard woman something slip sense david veritas native educational stayrevolutionary awkward unpaid savor discussion acts dismantledukeplantation leaguers fortunate write dismantledukeplantation amazing writers answer instead listens houstontexas ordered opeds criminal buildings shouldnt tried mouths txst watch after itomg needs demanding entrepreneurship wrong boards painanger yale2019speaks bloodsoaked faculty president wave guys response solidarity smartwrongmoveyale calhounmustfall refuse owns remember light education qwoc rather maintain waited allow tenure putting order talk pretending institutional defenders over move soon murray years equality held historys including cherish committee innovative staunch still symbol blocked perfect historyas memorials thank whitenesshistory beliefs energies interesting ridiculouslywrongmoveyale send actually better wasting formerlyknownascalhoun wrongmoveyale marchofresilience nocalhoun choose reactionary weeks 2016 might 2013 happened donors them someone grievous fling conversations safe introduce break educating repulsive campushistories they wealthy schools discuss maintaining bread wont desperately ypipo leavingyou alex name rant bent always university slavery token 강남풀사롱01021543560 truth jersey impersonation went difficult side week everyone financial salovey pursue nochyale generation house unsurprising hard idea displaying unsurprised challenges carry taught expect year classmates naming beyond adequately really living trending inclusivity attend space announces activism revisionists pocs tomorrow looking countryman condemns health reminder racismthat technically cause correct announced shows benjamin shut hemorrhaging nextyale million pauline pumping free extraordinary completely calhouncollege imagine icymi reparations teach wanted care revolutionary definition owners voyeuristically allies hostile fantastical discussing hinting running keep creates thing american nhta place philanthropically hence retain symbolize loud think cc17 1000 already dont feel ethnic powerful owned yourself yalespringfling sympathy shoah listentoyourstudents done spots another owner corporations clarity open george leaders given sadly cassandra wopila darrow formerlyknownascalhoun historian 강남풀살롱01021543560 needed swear master expand compromise white hundred wlegacy friend listen eyes selling changemasterkeepcalhoun that snapping direct ownerracist part jordan demonstrations fall believe elite institution symptom center begins loved kind john namesake roles princeton gotta help youve shower matter future speaking historical were tension clemson feeling bidder damned upspeaking communityaffirming supremacist erika turned argument slap voices prestigious rained need seen controversial tells accounted some sandwiched strength painful built able person climate self responsible latinx ideas jacobson note also mansplaining academia matthew take which renaming wonder greatest even healing towards pain departmental though thrilled keeps educate woodrow sing” 강남풀싸롱 donation yale2016speaks experiences letter representation remarks knee class stands alumna saddest diversity clear campuses cover face 선릉야구장01021543560 cultivating slaves slaver slaveholderchicyale occasion justify institutions came twitterstorians saying particularly calhouns show charles anyway defended bring colors proslavery suffer mypwi defender doesn’t find itits ground aint inspiring resisting posting title front writes less enough start haven failed bush going tape pretty folks aretha stain cadava sure weve listened means committed sheisperfect stop truly cannot haunted words despite report streets preemptively hall earn glorified girl hiring ever undergrad remove email garcia monumental stupid exercise myopic release abolitonists fixed where yalies wrote secretary requirement heirs throwing intelligence national activists ballot culture legacy college parking fail portrait perverted retweet best points project said stance steadfast ways away please calhoun continually underestimate state prowhite injustice simms probably reading youll across bought preserve agasint lazy recently creating right adding importance confusion sold regret weak merciful blame respectful harvard historians hurts motto come pity league essentially afam last yaleforall admin country taking quell minds minorities sensitive connection brag planned context faces inspired expense whole asked comes otherwise tone distress expendable point color seems championed others rofl dorm respect perpetuating labor along expensive brats passive whitesplaining cream symbols asks cares discrimination create distributional creativity quotas teacher cared much treat nazism whoa exhaustion freshman wants placenames life contribute general spit tillmanhall eduardo great else echoes understand specifically 53a130 demand obscuring fellow champions present chill case pwis welcoming look grister these mpls cash near rutgers ongoing nate many promoted situation voice franklincalhoun mistake rename moldy ellxpress templeton almost 1847 injury probs tubman cant evening weaintleavin politics somebody controversy everyday 1814 funny different goebbels residence forresthall perhaps things make belong administration cross same campus read arguments pauli auto inch games struggling constructed confronting breaks failure franklin status outside used slave slaverys wpersonal disadvantages refusal upon yesterday slavesso safer cheers moment moving student sisters alums supremacists opportunity thoughts incredulously mention makes 1975 youre well fighting thought more without gutted deserve claims alabama underestimated blackatapwi plaque left sims opinions calhoungottogo burden just sentence being money hands sculpture devastatingly communities mistakes thanks human world baldwin admins letting alum christakis thinking residential danger character except bullshit signals reasons lets spooky reason save smart joke real outweigh lake around represents rules tuition"
    
    # Declare number of terms wanted in cloud 
    cloud_total = 600
    tag_total = 20 #hashtags
    word_total = cloud_total - tag_total #description words
    time_range_length = 180 #in days, time_range of queried records
    time_range = (DateTime.now - time_range_length)..DateTime.now

    # Choose tags
    # Within time_range days, extract hashtagtags.
    tags = Record.where(date: time_range).pluck(:hashtag)

    # If too few tags, double time_range
    if (tags.length < tag_total / 2)
      time_range = (DateTime.now - 2*time_range_length)..DateTime.now
      tags = Record.where(date: time_range).pluck(:hashtag)
      tags.from(tags.size-tag_total)
    end

    # Parse into individual tags from records
    tags = tags.join(" ").scan(/\B#\w+/)
      
    # Count and store tag_total most frequent tags in array.
    frequency = Hash.new(0)
    tags.each {|tag| frequency[tag.downcase] += 1}
    frequency = frequency.sort_by {|k,v| v}[0..tag_total]

    # Keep tags with 2 or more mentions
    frequency = frequency.delete_if {|k, v| v < 2}
    tags_local = Hash[frequency].keys #array of keys

    # CHOOSE WORDS by ruby gem EngTagger, a POS tagger.
    # query public archives about events in the time_range, return descriptions.
    text = Record.where(date: time_range, make_private: false).pluck(:description)

    # Remove special characters
    text = text.join(" ").parameterize(sep=" ").split

    # Count words
    frequency = Hash.new(0)
    text.each {|w| frequency[w] += 1}

    # Remove words with only 2 or fewer mentions. Sort.
    frequency = frequency.delete_if {|k, v| v <= 2}
    frequency = frequency.sort_by {|k, v| v}
    frequency = Hash[frequency]

    # Join sorted words into string
    words_by_freq = frequency.keys.join(" ")

    # Tag words
    tgr = EngTagger.new
    tagged = tgr.add_tags(words_by_freq)
    percent = 0.1

    # Take top percent (0.1 or 0.2?) of nouns, adj, and verbs. Take twice as many nouns as verbs/adj.
    nouns = self.top_percent_keys(tgr.get_nouns(tagged), percent * 2)
    adj = self.top_percent_keys(tgr.get_adjectives(tagged), percent)

    # Take all kinds of verbs
    vbs = self.top_percent_keys(tgr.get_infinitive_verbs(tagged), percent) \
          + self.top_percent_keys(tgr.get_past_tense_verbs(tagged), percent) \
          + self.top_percent_keys(tgr.get_gerund_verbs(tagged), percent) \
          + self.top_percent_keys(tgr.get_passive_verbs(tagged), percent) \
          + self.top_percent_keys(tgr.get_base_present_verbs(tagged), percent) \
          + self.top_percent_keys(tgr.get_present_verbs(tagged), percent)

    # Possible words to remove, chosen by eyeballing the test corpus from DOWN magazine
    rmv = ["do", "are", "looks", "needs", "seems", "makes", "goes", "comes", "means", "does", "says", "has", "is", "did", "said", "had", "were", "was", "get", "make", "don", "be", "become", "made", "been", "did", "said", "had", "were", "was", "have", "ll", "re", "cc"]
    rmv += ["such", "same", "similar"]
    rmv += ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

    # Combine above POS, remove words in rmv, and randomize order. 
    words_local = nouns + adj + vbs - rmv
    words_local = words_local.shuffle

    # Cloud words:
    cloud_local = words_local + tags_local
    cloud_local = cloud_local.uniq

    # Check profanity
    f = File.read(Rails.root.join('lib/assets/bad_words_rot.txt'))
    bad_words_rot = f.split("\n")

    # return words to cleartext
    bad_words_cleartext = bad_words_rot.map { |w| rot_13(w) }
    cloud_local -= bad_words_cleartext
      
    # If only few records, append with static word_pool
    if (cloud_local.length < cloud_total)
      cloud_local += word_pool.split()
      cloud_local = cloud_local.uniq
      cloud_local = cloud_local[0..cloud_total]
    end

    cloud_local.shuffle
    
    return cloud_local
  end 
end
