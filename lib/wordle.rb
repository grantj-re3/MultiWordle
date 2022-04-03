#
# Copyright (C) 2022 Grant Jackson
# Licensed under GPLv3. http://www.gnu.org/licenses/gpl-3.0.html
#
##############################################################################
require "config"

##############################################################################
### Wordle game
##############################################################################
class Wordle
  GetWordMaxCount = 10
  RANGE_AZ = 'A'..'Z'

  @@words = nil                                   # Large array of words
  @@get_unique_word_max_count = 0

  attr_reader :num_chars, :max_guesses, :num_guesses, :guesses_done,
    :status, :chars_tried, :word, :guess, :clues

  ############################################################################
  def initialize(opts={})
    @cfg = Config.new

    @num_chars     = opts.fetch(:num_chars,   @cfg.arg[:num_chars])
    @max_guesses   = opts.fetch(:max_guesses, @cfg.arg[:max_guesses])
    @exclude_words = opts.fetch(:exclude_words, [])

    @num_guesses = 0
    @guesses_done = nil               # After correct guess for multi-wordle, assign @num_guesses

    @status = {}                      # No status feedback initially
    @chars_tried = {}                 # No chars tried initially

    get_target_word                   # Assign @word
    @are_all_letters_known = false

    @guess = nil                      # The user's current guess of @word
    @clues = nil
  end

  ############################################################################
  def self.words
    @@words
  end

  ############################################################################
  def get_wordlist_path
    fname = @cfg.wordfiles[ @cfg.arg[:num_chars] ] # Get filename for N-letter words
    if fname
      puts "Using override wordlist file '#{fname}' for #{@cfg.arg[:num_chars]}-letter words"

    else
      fname = @cfg.wordfiles[nil]                  # Else get default filename
      puts "Using default wordlist file '#{fname}' for #{@cfg.arg[:num_chars]}-letter words"
    end
    "#{WordFilesDir}/#{fname}"
  end

  ############################################################################
  def load_all_words
    return if @@words    
    word_regex = /^\w{#{@num_chars}}$/
    @@words = []
    line_count = 0

    wordlist_path = get_wordlist_path
    begin
      File.foreach(wordlist_path){|line|
        line_count += 1
        word = line.strip.upcase
        @@words << word if word_regex.match(word)
      }

    rescue => ex
      puts "ERROR: #{ex}"
      exit 11
    end

    @@words.uniq!                     # Exclude repeated words
    puts "Loaded #{@@words.length} x #{@num_chars}-letter words (from word list of #{line_count})"
    puts "The word list is located at #{wordlist_path}"
    if @@words.length < 1
      puts "ERROR: Insufficient words to play the game"
      exit 12
    end
  end

  ############################################################################
  def get_target_word
    load_all_words
    GetWordMaxCount.times{|i|
      @@get_unique_word_max_count = i+1 if i >= @@get_unique_word_max_count
      index = rand(0...@@words.length)
      @word = @@words[index]
      return unless @exclude_words.include?(@word)
    }
    STDERR.puts <<-EOF.gsub(/^[ \t]*/, "")

      ERROR: After #{GetWordMaxCount} attempts, we could not find a random word from
      our word list which is not in the excluded-word-list! Quitting.
    EOF
    exit 13
  end

  ############################################################################
  def self.get_unique_word_max_count
    @@get_unique_word_max_count
  end

  ############################################################################
  def new_guess(guess)
    @guess = guess              # Assume guess string is already sanitized
    @num_guesses += 1
  end

  ############################################################################
  def keep_guesses_done
    @guesses_done = @num_guesses
  end

  ############################################################################
  def calc_clues_status
    # @clues[]:       feedback for the current guess
    # @status[]:      feedback for all guesses in this game
    # @chars_tried[]: feedback re all chars we've tried in all guesses in this game
    @clues = []                  # Element values: :ok_location, :ok_letter, :not_letter, nil
    is_matched_ch_in_word = []  # Element values: true, nil
    @num_chars.times{
      @clues << nil
      is_matched_ch_in_word << nil
    }

    # Check for guessed char not in the target word
    @guess.split("").each{|ch|
      @status[ch] = :not_letter unless @word.split("").any?{|ch_word| ch == ch_word}
      @chars_tried[ch] = true
    }

    # Check for guessed char in the right location of target word
    @guess.split("").each_with_index{|ch, i|
      if ch == @word[i]
        @status[ch] = :ok_location
        @clues[i] = :ok_location
        is_matched_ch_in_word[i] = true
      end
    }

    # Check for guessed char in the wrong location of target word
    @guess.split("").each_with_index{|ch_guess, i_guess|
      @word.split("").each_with_index{|ch_word, i_word|
        next if i_guess == i_word
        next if @clues[i_guess] || is_matched_ch_in_word[i_word]

        if ch_guess == ch_word
          @status[ch_guess] = :ok_letter unless @status[ch_guess] == :ok_location
          @clues[i_guess] = :ok_letter
          is_matched_ch_in_word[i_word] = true
        end
      }
    }

    # Don't show remaining letters if we already know all (@num_chars) letters
    unless @are_all_letters_known
      ok_count = @status.inject(0){|sum,(key,val)| val==:ok_location || val==:ok_letter ? sum+1 : sum}
      if ok_count == @num_chars
        RANGE_AZ.each{|ch| @status[ch] = :not_letter unless @status[ch]}
        @are_all_letters_known = true
      end
    end
  end

  ############################################################################
  def correct
    @guess == @word
  end

end

