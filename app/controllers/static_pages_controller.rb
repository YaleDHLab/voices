class StaticPagesController < ApplicationController
  def home
    @words_for_word_overlay = CloudWord.pluck(:words)[0]
    if @words_for_word_overlay.blank?
			@words_for_word_overlay=initial_words().split()
		end
		@divs_for_word_overlay = generate_divs_for_word_overlay(@words_for_word_overlay)
	end

  def about
  end

  def generate_divs_for_word_overlay(word_array)
    """Read in a word array and return a carefully html_escaped string that
    escapes html elements but doesn't escape words, as they're user provided"""
    
    # colors are arrayed light to dark shades of gray
    available_colors = ["#c3c3c3","#8d8d8d","#848484",
      "#6f6f6f","#646464","#545454"]

    word_overlay_divs = ''.html_safe
    word_array.each_with_index do |word, word_index|
      word_overlay_divs << '<div id="word-number-'.html_safe
      word_overlay_divs << word_index.to_s.html_safe
      word_overlay_divs << '" style="color:'.html_safe

      # make the lightest color rare
      if word_index % 30 == 0
        word_overlay_divs << available_colors[0].html_safe
      else
        word_overlay_divs << available_colors[ 1 + Random.rand(5) ].html_safe
      end

      # give each word a 'speed' class that specifies how fast it moves
      word_overlay_divs << '" class=speed-'.html_safe
      word_overlay_divs << "#{Random.rand(5)}".html_safe      

      word_overlay_divs << '>'.html_safe
      word_overlay_divs << word 
      word_overlay_divs << '</div>'.html_safe
    end
    return word_overlay_divs
  end 

	def initial_words()
		return "outusing represent colleges exams todays ashamed remarkable whoever child dollar resistance month laura springfling2016 thoughtful mile classic asian grateful gladly messy follow remarkably conversation integrity issues disingenous protest praises wish uphold berkeleys honoring pretense acting opportunities former wilsons 1930s excluded stable teaching sorry agaisnt worth resources investments paying juliana louder worse equivocal zhang very could slaveholder none didn’t choice georgia balancing decide confederate telling calhounhonorscollege jettison everandalways chapel severely school weareloved scholar purely supports joel murrays attempts leader peoe coming progress yale hereyou 강남야구장01021543560 yall someday says instagram lecturing tired queer inconsequential mural soul past talks second street video perspective earth writing james wilson universities what yonas centering power violentyale giving deeply tirelessly celebrated sikessitin debate current grown waiting absolute goes infamous avenues celebrates public everybody movement body lessons justification hero chose degree never judges here whiteness hours guise beacon voyeurism calhounpissing address active sing november sine hallsofwhitesupremacyyale change every sending studentsll kids turner forum hearts study changed whine despicable experience proud whiny credit placate descended arent abolition pick weird studies honor thats named appended love family extra duct presidents explained sign logical semester names fake apply blktwitterstorians takele namesimages goetz shareholders defies flaws figure would prove positive placenaming display tears hashtag insult campuswide live doubt wondering tokenize timing black themselves nobrainer monae tell today secured knows started becomes inclined under about takedowntheflagmsu symbolizing flag beholden yale20xxspeaks announce known foundations hold women high keeping word wouldnt rights this 강남풀싸롱01021543560 work refusing advocacy memorialization offended remain trauma values 강남야구장 learn following meet didnt example complain history beautiful fists dedicated blight embarrassing want hears give preserving accept terrible supremacy heard woman something slip sense david veritas native educational stayrevolutionary awkward unpaid savor discussion acts dismantledukeplantation leaguers fortunate write dismantledukeplantation amazing writers answer instead listens houstontexas ordered opeds criminal buildings shouldnt tried mouths txst watch after itomg needs demanding entrepreneurship wrong boards painanger yale2019speaks bloodsoaked faculty president wave guys response solidarity smartwrongmoveyale calhounmustfall refuse owns remember light education qwoc rather maintain waited allow tenure putting order talk pretending institutional defenders over move soon murray years equality held historys including cherish committee innovative staunch still symbol blocked perfect historyas memorials thank whitenesshistory beliefs energies interesting ridiculouslywrongmoveyale send actually better wasting formerlyknownascalhoun wrongmoveyale marchofresilience nocalhoun choose reactionary weeks 2016 might 2013 happened donors them someone grievous fling conversations safe introduce break educating repulsive campushistories they wealthy schools discuss maintaining bread wont desperately ypipo leavingyou alex name rant bent always university slavery token 강남풀사롱01021543560 truth jersey impersonation went difficult side week everyone financial salovey pursue nochyale generation house unsurprising hard idea displaying unsurprised challenges carry taught expect year classmates naming beyond adequately really living trending inclusivity attend space announces activism revisionists pocs tomorrow looking countryman condemns health reminder racismthat technically cause correct announced shows benjamin shut hemorrhaging nextyale million pauline pumping free extraordinary completely calhouncollege imagine icymi reparations teach wanted care revolutionary definition owners voyeuristically allies hostile fantastical discussing hinting running keep creates thing american nhta place philanthropically hence retain symbolize loud think cc17 1000 already dont feel ethnic powerful owned yourself yalespringfling sympathy shoah listentoyourstudents done spots another owner corporations clarity open george leaders given sadly cassandra wopila darrow formerlyknownascalhoun historian 강남풀살롱01021543560 needed swear master expand compromise white hundred wlegacy friend listen eyes selling changemasterkeepcalhoun that snapping direct ownerracist part jordan demonstrations fall believe elite institution symptom center begins loved kind john namesake roles princeton gotta help youve shower matter future speaking historical were tension clemson feeling bidder damned upspeaking communityaffirming supremacist erika turned argument slap voices prestigious rained need seen controversial tells accounted some sandwiched strength painful built able person climate self responsible latinx ideas jacobson note also mansplaining academia matthew take which renaming wonder greatest even healing towards pain departmental though thrilled keeps educate woodrow sing” 강남풀싸롱 donation yale2016speaks experiences letter representation remarks knee class stands alumna saddest diversity clear campuses cover face 선릉야구장01021543560 cultivating slaves slaver slaveholderchicyale occasion justify institutions came twitterstorians saying particularly calhouns show charles anyway defended bring colors proslavery suffer mypwi defender doesn’t find itits ground aint inspiring resisting posting title front writes less enough start haven failed bush going tape pretty folks aretha stain cadava sure weve listened means committed sheisperfect stop truly cannot haunted words despite report streets preemptively hall earn glorified girl hiring ever undergrad remove email garcia monumental stupid exercise myopic release abolitonists fixed where yalies wrote secretary requirement heirs throwing intelligence national activists ballot culture legacy college parking fail portrait perverted retweet best points project said stance steadfast ways away please calhoun continually underestimate state prowhite injustice simms probably reading youll across bought preserve agasint lazy recently creating right adding importance confusion sold regret weak merciful blame respectful harvard historians hurts motto come pity league essentially afam last yaleforall admin country taking quell minds minorities sensitive connection brag planned context faces inspired expense whole asked comes otherwise tone distress expendable point color seems championed others rofl dorm respect perpetuating labor along expensive brats passive whitesplaining cream symbols asks cares discrimination create distributional creativity quotas teacher cared much treat nazism whoa exhaustion freshman wants placenames life contribute general spit tillmanhall eduardo great else echoes understand specifically 53a130 demand obscuring fellow champions present chill case pwis welcoming look grister these mpls cash near rutgers ongoing nate many promoted situation voice franklincalhoun mistake rename moldy ellxpress templeton almost 1847 injury probs tubman cant evening weaintleavin politics somebody controversy everyday 1814 funny different goebbels residence forresthall perhaps things make belong administration cross same campus read arguments pauli auto inch games struggling constructed confronting breaks failure franklin status outside used slave slaverys wpersonal disadvantages refusal upon yesterday slavesso safer cheers moment moving student sisters alums supremacists opportunity thoughts incredulously mention makes 1975 youre well fighting thought more without gutted deserve claims alabama underestimated blackatapwi plaque left sims opinions calhoungottogo burden just sentence being money hands sculpture devastatingly communities mistakes thanks human world baldwin admins letting alum christakis thinking residential danger character except bullshit signals reasons lets spooky reason save smart joke real outweigh lake around represents rules tuition"
		end


end
