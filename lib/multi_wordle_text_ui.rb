#
# Copyright (C) 2022 Grant Jackson
# Licensed under GPLv3. http://www.gnu.org/licenses/gpl-3.0.html
#
##############################################################################
require "config"
require "wordle"
require "wordle_text_ui"
require "guess_input_text_ui"

##############################################################################
### Multi-game Wordle Text-User-Interface
##############################################################################
class MultiWordleTextUI

  attr_reader :uis, :target_words, :cfg
  attr_accessor :games

  ############################################################################
  def initialize
    @cfg = Config.new
    @games = []
    @uis = []
    exclude_words = []
    @cfg.arg[:num_games].times{|i|
      game = Wordle.new(:exclude_words => exclude_words)
      exclude_words << game.word

      @games << game
      check_word_list_size if i == 0
      @uis << WordleTextUI.new(game)
    }
    puts "Max attempts to load any unique word for this game: #{Wordle.get_unique_word_max_count}"
    @target_words = @games.map{|g| g.word}
    setup_prompts
  end

  ############################################################################
  def check_word_list_size
    # This method only works after word list has been loaded, that is,
    # any time after the first Wordle.new has been invoked.
    if Wordle.words.length < @cfg.arg[:num_games]
      STDERR.puts <<-EOF.gsub(/^[ \t]*/, '')

        ERROR: This game tries to generate #{@cfg.arg[:num_games]} unique target words
        however there are only #{Wordle.words.length} unique words in the word-list!
        Quitting.
      EOF
      exit 1
    end
  end

  ############################################################################
  def setup_prompts
    uif = @uis.first
    if @cfg.arg[:clue_status_format] == :clue_status_pairs
      @prompt_prepadding = uis.map{|ui|
        "%s%s%s" % [ui.clues_string(:padding), ui.pad_delim, ui.status_string(:padding)]
      }.join(uif.pad_section_delim) + uif.section_delim
      @prompt_preheading = uis.map{|ui|
        "%s%s%s%s" % [ui.clues_string(:heading), ui.delim, ui.status_string(:heading), ui.section_delim]
      }.join("")

    else  # @cfg.arg[:clue_status_format] is :one_status or :no_status
      @prompt_prepadding = uis.map{|ui| ui.clues_string(:padding)}.join(uif.pad_section_delim)
      @prompt_prepadding << (@cfg.arg[:clue_status_format] == :one_status ?
        "%s%s%s" % [uif.pad_delim, uif.status_string(:padding), uif.section_delim] : uif.section_delim)

      @prompt_preheading = uis.map{|ui| ui.clues_string(:heading)}.join(uif.section_delim)
      @prompt_preheading << (@cfg.arg[:clue_status_format] == :one_status ?
        "%s%s%s" % [uif.delim, uif.status_string(:heading), uif.section_delim] : uif.section_delim)
    end
  end

  ############################################################################
  def show_preprompt_clue_status
    if @cfg.arg[:clue_status_format] == :clue_status_pairs
      printf @uis.map{|ui|
        "%s%s%s%s" % [ui.clues_string, ui.context_delim, ui.status_string(:context), ui.section_delim]
      }.join("")

    else  # @cfg.arg[:clue_status_format] is :one_status or :no_status
      uif = @uis.first
      printf @uis.map{|ui| ui.clues_string}.join(uif.section_delim)

      if @cfg.arg[:clue_status_format] == :one_status
        printf "%s%s%s" % [uif.delim, uif.status_string(:context), uif.section_delim]
      else
        printf uif.section_delim
      end

    end
  end

  ############################################################################
  def calc_clues_status
    @games.each{|g| g.calc_clues_status}
  end

  ############################################################################
  def keep_guess_count_for_completed_games
    @games.each{|g| g.keep_guesses_done if g.correct}
  end

  ############################################################################
  def score_summary_s
    num_completed = 0
    sum_score = 0
    @games.each{|g|
      num_completed += 1 if g.guesses_done
      sum_score += g.guesses_done if g.guesses_done
    }
    "%d/%d completed | %d@%d turns | %d letters" %
      [num_completed, @cfg.arg[:num_games], sum_score, @games.first.num_guesses, @cfg.arg[:num_chars]]
  end

  ############################################################################
  def score_s
    "[" + @games.map{|g| g.guesses_done ? g.guesses_done.to_s : "?"}.join(":") + "]"
  end

  ############################################################################
  def show_score(pre_string="")
    puts "%sYou had %s guesses.\nScore summary: %s" % [pre_string, score_s, score_summary_s]
  end

  ############################################################################
  def show_words(opts={})
    opts = {
      :past_tense => true,
      :pre_string => ""
    }.merge(opts)
    verb = opts[:past_tense] ? "were" : "are"
    puts "%sThe words %s: %s." % [opts[:pre_string], verb, @target_words.join(', ')]

  end

  ############################################################################
  def process_game_end
    if @games.all?{|g| g.guesses_done}
      show_score("\n\nCongratulations!!!\n")
      return :break
    elsif @games.first.num_guesses >= @games.first.max_guesses
      show_words(:pre_string => "\n\nBad luck!  ")
      show_score
      return :break
    end
    nil
  end

  ############################################################################
  def show_preprompt_padding
    printf @prompt_prepadding
  end

  ############################################################################
  def show_preprompt_heading
    printf @prompt_preheading
  end

  ############################################################################
  def prompt
    @uis.first.prompt
  end

  ############################################################################
  def prompt_more
    @prompt_prepadding + @uis.first.prompt
  end

  ############################################################################
  def brief_help
    show_cmd = @cfg.arg[:is_allow_show_word] ? "- ':s' to show the target word (without the quotes)" : ""
    s = <<-EOF.gsub(/^ {6}/, '')

      =======================
      M U L T I - W O R D L E
      =======================
      Config file at #{ConfigFilepath}

      There are #{@cfg.arg[:num_games]} secret words! Try to guess them.
      - For each guess, enter a single #{@cfg.arg[:num_chars]}-letter word
      - You have #{@cfg.arg[:max_guesses]} guesses
      - Better results are indicated by less guesses/turns
      - The program only accepts English/foreign words
        (and names) listed in our database
      - Green implies the right letter in right position
      - Yellow implies the right letter in wrong position
      - ':q' to quit (without the quotes)
      #{show_cmd}

    EOF
  end

  ############################################################################
  def self.multi_game
    multi_ui = MultiWordleTextUI.new
    input = GuessInputTextUI.new(Wordle.words, multi_ui.cfg.arg[:is_allow_show_word])

    puts multi_ui.uis.first.debug_config_s if multi_ui.cfg.arg[:is_show_config]
    puts multi_ui.brief_help
    multi_ui.uis.first.debug_show_column_position
    multi_ui.show_preprompt_heading

    while true
      attrs = input.get_input_attrs(multi_ui.prompt, multi_ui.prompt_more)

      case attrs[:type]
      when :guess
        multi_ui.games.each{|g| g.new_guess(attrs[:data])}
      when :quit
        multi_ui.show_words(:pre_string => "\n")
        multi_ui.show_score
        break
      when :show_word
        multi_ui.show_words(:past_tense => false)
        multi_ui.show_preprompt_padding
        next
      end

      multi_ui.calc_clues_status
      multi_ui.show_preprompt_clue_status
      multi_ui.keep_guess_count_for_completed_games
      break if multi_ui.process_game_end == :break
    end

  end

end

