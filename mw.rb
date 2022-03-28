#!/usr/bin/ruby
#
# Copyright (C) 2022 Grant Jackson
# Licensed under GPLv3. http://www.gnu.org/licenses/gpl-3.0.html
#
##############################################################################
# The file to run for multi-game wordle
##############################################################################
#
# Environment: Ruby 2.3.3
#
# FIXME: Consider:
# - ':u' ask for untried/hint (same as :guess_status) when no status shown
# - Hard wordle option
# - Play game again
# - Find better word list; try finding list used by other wordle games
# - Use original word list for 5 letter words
#
##############################################################################
ParentDir = File.expand_path(".", File.dirname(__FILE__))
ConfigFilename = "#{File.basename(__FILE__, '.rb')}_cfg.rb"
ConfigFilepath = "#{ParentDir}/#{ConfigFilename}"

# Add dirs to the library path
$: << "#{ParentDir}/lib"

require ConfigFilepath if File.readable?(ConfigFilepath)
require "multi_wordle_text_ui"

##############################################################################
### Main
##############################################################################
MultiWordleTextUI.multi_game

