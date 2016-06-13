class StaticPagesController < ApplicationController
  def home
    @words_for_word_overlay = CloudWord.pluck(:words)[0]
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

end
