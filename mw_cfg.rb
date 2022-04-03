#
# Copyright (C) 2022 Grant Jackson
# Licensed under GPLv3. http://www.gnu.org/licenses/gpl-3.0.html
#
##############################################################################
### The user-config file for multi-game wordle
##############################################################################
class Config

  def user_config
    @arg = {
      # Number of letters in the target word
      :num_chars              => 5,

      # Maximum number of guesses permitted
      :max_guesses            => 25,

      # Number of simultaneous games to play. Must be 1, 2, 3 ...
      # The maximum number depends on:
      # - the width of your text console (xterm) & font size/type
      # - how you configure delimiters, clue/status format, clue/status
      #   length, etc. in this file
      :num_games              => 2,

      # DEBUG: Allow user to cheat by showing the word! Useful during debugging.
      :is_allow_show_word     => false,

      # DEBUG: Show the configuration parameters
      :is_show_config         => false,

      # DEBUG: Print lines which show column positions. This value specifies how
      # many column positions to show (usually 80 or more). Do not print debug
      # lines if value is 0. This debug feature is useful when configuring the
      # Text User Interface to see how many characters will fit on your xterm
      # (or console).
      ##:column_position_count  => 168,
      ##:column_position_count  => 79,
      :column_position_count  => 0,

      # Delimiter strings: Typically 1-3 characters
      :delim                  => ">",
      :section_delim          => "|",

      # String to prompt the user to input the guessed word
      :word_prompt            => " Word? ",

      # :short = show the clue/status character only
      # :long  = same as :short but add a space to the right of each clue/status character
      #
      # - Use :long for better formatting (more white space) when you have
      #   plenty of characters on your line available for clues/status.
      # - Use :short when you have less characters on your line (eg. when
      #   configuring the game for 4 target words).
      :clue_length            => :long,
      :status_length          => :short,

      # Status gives you aggregated information about the whole game.
      # - :clue_info gives colour coded information about all the clues so
      #   far during the game. Hence this type of status must be paired
      #   with the particular word being guessed (if you are playing a
      #   multi-word game).
      # - :guess_info gives (not colour coded) information about all the
      #   untried-letters (or untried-characters) so far during the game.
      #   This type of status does not need to be paired with each word
      #   (of a multi-word game) because the status only depends on
      #   user guesses (not clues). So if you only want one status-field
      #   for all the words being guessed in a multi-word game, you must
      #   use this option. :guess_info is better than having no helper
      #   information, but worse than :clue_info.
      # - If you do not want any status-field to be displayed, then
      #   assign :no_status to the :clue_status_format field.
      #
      # :guess_info or :clue_info
      :status_type            => :clue_info,

      # Examples of clue-status formats on the display:
      # - :clue_status_pairs = clue1|status1 | clue2|status2 | clue3|status3
      # - :one_status        = clue1|clue2|clue3 | status
      # - :no_status         = clue1|clue2|clue3
      :clue_status_format     => :one_status,

    }

    # @wordfiles allows you to specify:
    # - one *default* wordlist file to be used for words of any length
    #   (i.e. can be used when :num_chars above is set to 4, or 5, or 6,
    #   or 7, or 8, ...)
    #   * the key must be nil for the default wordlist
    #   * the wordlist file must contain words of all lengths
    # - you can optionally specify one wordlist file per word length
    #   (i.e. :num_chars above) which overrides the default wordlist
    #   for that particular word length
    #   * the key shall be the length of the words which we are overriding
    #     (e.g. 6)
    #   * the wordlist file must contain words of corresponding length
    #     (e.g. if the key is 6, the file must contain 6-letter words);
    #     the file can optionally contain words of other lengths (i.e.
    #     not 6-letters) but these words will be ignored
    #
    # Format:
    #   NumChars => WordlistFilenameForNumChars,
    #
    # Format example:
    #   6   => "wordlist_for_six_letters.txt",
    #   7   => "wordlist_for_seven_letters.txt",
    #   nil => "default_wordlist_for_all_other_word_lengths.txt",

    @wordfiles = {
      #5   => "wordsRealWordle_c5_w12972.txt",   # Too many infrequent words?
      5   => "wordsRealWordle_c5_w2315.txt",    # Good wordlist for 5-letter words

      # The default wordlist (mandatory)
      #
      # /usr/share/dict/words has too tech & non-English words. However, if you
      # want to use it, symlink to it from the WordFilesDir (usually wordfiles dir)
      # then uncomment the following line:
      # nil => "words",
      nil => "wlist_match10.txt",               # Too many names & non-English words
    }

  end

end

