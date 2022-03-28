#
# Copyright (C) 2022 Grant Jackson
# Licensed under GPLv3. http://www.gnu.org/licenses/gpl-3.0.html
#
##############################################################################
### Guess-Input Text-User-Interface
##############################################################################
class GuessInputTextUI

  ############################################################################
  def initialize(word_list, is_allow_show_word=false)
    @words = word_list
    @is_allow_show_word = is_allow_show_word
  end

  ############################################################################
  def get_input_attrs(prompt_first, prompt_more=nil)
    prompt_more ||= prompt_first
    is_first = true

    while true
      if is_first
        printf prompt_first
        is_first = false
      else
        printf prompt_more
      end

      str = STDIN.readline.strip.upcase
      case str
      when ':Q'
        return {:type => :quit}
      when ':S'
        return {:type => :show_word} if @is_allow_show_word
      else
        # Only permit guesses of words in our word list
        return {:type => :guess, :data => str} if @words.any?{|w| w == str}
      end
    end
  end

end

