#
# Copyright (C) 2022 Grant Jackson
# Licensed under GPLv3. http://www.gnu.org/licenses/gpl-3.0.html
#
##############################################################################
### Multi-game Wordle Configuration
##############################################################################
# Extend the Config class (in a separate file, ConfigFilepath)
class Config

  ClueStatusLengths = [:long, :short]
  ClueStatusFormats = [:clue_status_pairs, :one_status, :no_status]
  StatusTypes       = [:clue_info, :guess_info]

  attr_reader :arg, :key_order

  def initialize
    user_config if Config.method_defined?(:user_config)
    clean_user_config
    validate_config
    @key_order = [
      :num_chars,
      :num_games,
      :max_guesses,

      :delim,
      :section_delim,
      :word_prompt,

      :clue_length,
      :status_length,
      :status_type,
      :clue_status_format,

      :is_allow_show_word,
      :is_show_config,
      :column_position_count,
    ]
  end

  def clean_user_config
    # Add defaults and override some invalid configs
    @arg ||= {}
    @arg[:num_chars] ||= 5

    @arg[:max_guesses] ||= 6
    @arg[:max_guesses] = 99 if @arg[:max_guesses] > 99  # Text UI assumes 1 or 2 digits
    @arg[:max_guesses] = 1  if @arg[:max_guesses] < 1   # Script assumes 1 or more

    # Number of simultaneous games to play. Must be 1, 2, 3 ...
    @arg[:num_games]              ||= 1
    @arg[:num_games] = 1 if @arg[:num_games] < 1        # Invalid to have less than 1 game

    # DEBUG: Allow user to cheat by showing the word! Useful during debugging.
    @arg[:is_allow_show_word]     ||= false

    # DEBUG: Show the configuration parameters
    @arg[:is_show_config]         ||= false

    # DEBUG: Print lines which show column positions.
    @arg[:column_position_count]  ||= 0

    # Delimiter strings: Typically 1-3 characters
    @arg[:delim]                  ||= ">"
    @arg[:section_delim]          ||= "|"

    # String to prompt the user to input the guessed word
    @arg[:word_prompt]            ||= "Word? "

    # :long or :short
    @arg[:clue_length]            ||= :long
    @arg[:status_length]          ||= :long

    # :clue_status_pairs or :one_status or :no_status
    @arg[:clue_status_format]     ||= :clue_status_pairs

    # :guess_info or :clue_info
    @arg[:status_type]            ||= :clue_info

    # IF you are playing more than 1 simultaneous game AND
    #   you are only going to display one status section for all N-games
    # THEN the status-type must NOT be :clue_info
    @arg[:status_type] = :guess_info if @arg[:num_games] > 1 && @arg[:clue_status_format] == :one_status

  end

  def validate_config
    error = false
    unless ClueStatusLengths.include?(@arg[:clue_length])
      error = true
      printf "CONFIGURATION ERROR:\n  %s is %s\n  Must be one of %s\n" %
        ["@arg[:clue_length]", @arg[:clue_length].inspect, ClueStatusLengths.inspect]
    end

    unless ClueStatusLengths.include?(@arg[:status_length])
      error = true
      printf "CONFIGURATION ERROR:\n  %s is %s\n  Must be one of %s\n" %
        ["@arg[:status_length]", @arg[:status_length].inspect, ClueStatusLengths.inspect]
    end

    unless ClueStatusFormats.include?(@arg[:clue_status_format])
      error = true
      printf "CONFIGURATION ERROR:\n  %s is %s\n  Must be one of %s\n" %
        ["@arg[:clue_status_format]", @arg[:clue_status_format].inspect, ClueStatusFormats.inspect]
    end

    unless StatusTypes.include?(@arg[:status_type])
      error = true
      printf "CONFIGURATION ERROR:\n  %s is %s\n  Must be one of %s\n" %
        ["@arg[:status_type]", @arg[:status_type].inspect, StatusTypes.inspect]
    end

    if error
      puts "QUITTING!"
      exit 1
    end
  end

end

