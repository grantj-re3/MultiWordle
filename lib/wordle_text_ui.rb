#
# Copyright (C) 2022 Grant Jackson
# Licensed under GPLv3. http://www.gnu.org/licenses/gpl-3.0.html
#
##############################################################################
require "wordle"

##############################################################################
### Wordle Text-User-Interface
##############################################################################
class WordleTextUI
  # https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
  # https://man7.org/linux/man-pages/man4/console_codes.4.html
  # See "ECMA-48 Select Graphic Rendition" section
  ATTR_FG_BLACK_BG_BRIGHT_RED         = "\033[30;101m"
  ATTR_FG_BLACK_BG_BRIGHT_GREEN       = "\033[30;102m"  # Ok
  ATTR_FG_BLACK_BG_BRIGHT_YELLOW      = "\033[30;103m"  # Ok
  ATTR_FG_BLACK_BG_BRIGHT_BLUE        = "\033[30;104m"  # Ok
  ATTR_FG_BLACK_BG_BRIGHT_MAGENTA     = "\033[30;105m"
  ATTR_FG_BLACK_BG_BRIGHT_CYAN        = "\033[30;106m"  # Ok

  ATTR_FG_BLACK_BG_RED                = "\033[30;41m"
  ATTR_FG_BLACK_BG_GREEN              = "\033[30;42m"   # Ok
  ATTR_FG_BLACK_BG_YELLOW             = "\033[30;43m"   # Ok; BROWN?
  ATTR_FG_BLACK_BG_BLUE               = "\033[30;44m"
  ATTR_FG_BLACK_BG_MAGENTA            = "\033[30;45m"
  ATTR_FG_BLACK_BG_CYAN               = "\033[30;46m"   # Ok
  ATTR_RESET                          = "\033[0m"

  @@clue_ok_location = ATTR_FG_BLACK_BG_BRIGHT_GREEN
  @@clue_ok_letter   = ATTR_FG_BLACK_BG_YELLOW
  @@clue_no_info     = ATTR_RESET       # Default setting

  RANGE_AZ = Wordle::RANGE_AZ

  attr_reader :wordle

  ############################################################################
  def initialize(wordle_obj)
    @cfg = Config.new
    @wordle = wordle_obj

    setup_layout
  end

  ############################################################################
  def delim
    @cfg.arg[:delim]
  end

  ############################################################################
  def section_delim
    @cfg.arg[:section_delim]
  end

  ############################################################################
  def pad_delim
    " " * @cfg.arg[:delim].length
  end

  ############################################################################
  def pad_section_delim
    " " * @cfg.arg[:section_delim].length
  end

  ############################################################################
  def context_delim
    @wordle.guesses_done || @wordle.correct ? pad_delim : delim
  end

  ############################################################################
  def setup_layout
    @pad_s_clue      = @cfg.arg[:clue_length] == :long ? " " : ""
    @pad_factor_clue = @cfg.arg[:clue_length] == :long ? 2 : 1

    @pad_s_status      = @cfg.arg[:status_length] == :long ? " " : ""
    @pad_factor_status = @cfg.arg[:status_length] == :long ? 2 : 1
  end

  ############################################################################
  def prompt
    "%2d%s%s" % [@wordle.num_guesses + 1, @cfg.arg[:section_delim], @cfg.arg[:word_prompt]]
  end

  ############################################################################
  def clues_string_heading(s_blank, pos=nil)
    s_prefix = "Clue"
    field_length = s_blank.length

    if pos.nil? || @cfg.arg[:num_games] < 5
      # Squash the s_prefix text into the available space
      hdr = s_prefix[0...field_length]

    else
      # Don't bother to use s_prefix; only show (1 or 2 digit) field position
      leading_spaces = " " * ((1 + field_length - pos.to_s.length) / 2)
      hdr = "#{leading_spaces}#{pos}"
      hdr = hdr[-1] if field_length == 1 && hdr.length > 1
    end
    s_blank.gsub(/^ {#{hdr.length}}/,  hdr)
  end

  ############################################################################
  def clues_string(type=nil, pos=nil)
    # Valid types = :normal, :heading or :padding. Nil implies :normal.

    if type == :padding || type == :heading || @wordle.guesses_done
      s = " " * @pad_factor_clue * @wordle.num_chars
      if @wordle.guesses_done || type == :padding
        return s

      else    # type == :heading
        return clues_string_heading(s, pos)
      end
    end

    a = []
    guess_chars = @wordle.guess.split("")
    @wordle.clues.each_with_index{|c,i|
      case c
      when :ok_location
        a << "#{@@clue_ok_location}#{guess_chars[i]}#{@pad_s_clue}"
      when :ok_letter
        a << "#{@@clue_ok_letter}#{guess_chars[i]}#{@pad_s_clue}"
      else
        a << "#{@@clue_no_info}#{guess_chars[i]}#{@pad_s_clue}"
      end
    }
    a << "#{@@clue_no_info}"
    a.join("")
  end

  ############################################################################
  def status_string(type=nil)
    # Valid types = :normal, :heading, :padding or :context. Nil implies :normal.
    # The :context type will choose :normal or :padding depending on the state of @wordle.

    is_clue_status_pairs = @cfg.arg[:clue_status_format] == :clue_status_pairs
    if type == :context
      type = ((@wordle.guesses_done || @wordle.correct) && is_clue_status_pairs) ? :padding : nil
    end

    if type == :padding || type == :heading || @wordle.guesses_done && is_clue_status_pairs
      s = " " * @pad_factor_status * RANGE_AZ.to_a.length
      if @wordle.guesses_done
        return s
      elsif type == :heading
        return @cfg.arg[:status_type] == :guess_info ?
          s.gsub(/^ {15}/, "Untried letters") :
          s.gsub(/^ {6}/,  "Status")
      else
        return s
      end
    end

    a = []
    if @cfg.arg[:status_type] == :guess_info
      RANGE_AZ.each{|ch| a << (@wordle.chars_tried[ch] ? "." : ch) + @pad_s_status}

    else    # @cfg.arg[:status_type] is :clue_info
      RANGE_AZ.each{|ch|
        case @wordle.status[ch]
        when :ok_location
          a << "#{@@clue_ok_location}#{ch}#{@pad_s_status}"
        when :ok_letter
          a << "#{@@clue_ok_letter}#{ch}#{@pad_s_status}"
        when :not_letter
          a << "#{@@clue_no_info}.#{@pad_s_status}"
        else
          a << "#{@@clue_no_info}#{ch}#{@pad_s_status}"
        end
      }
      a << "#{@@clue_no_info}"
    end
    a.join("")
  end

  ############################################################################
  def debug_show_column_position
    return if @cfg.arg[:column_position_count] <= 0
    a_line1 = (1..@cfg.arg[:column_position_count]).inject([]){|a,i| i%10 == 0 ? a << ((i/10)%10).to_s : a << " "}
    a_line2 = (1..@cfg.arg[:column_position_count]).inject([]){|a,i| i%10 == 0 ? a << " " : a << (i%10).to_s}
    printf "%s\n%s\n", a_line1.join(''), a_line2.join('')
  end

end

