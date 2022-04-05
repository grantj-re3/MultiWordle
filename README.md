# MultiWordle

A clone of [Wordle](https://www.powerlanguage.co.uk/wordle/) which allows
many of the game's features to be customised via a configuration file.

This game uses a text user interface and assumes a colour xterm is being
used under Linux. I have not tested under Mac OS X or Windows running
Cygwin, MobaXterm or similar.

You need to install ruby (if not already installed). I imagine
the program will work using any Ruby 2.x version. It has been tested
using the following Ruby versions: 2.3.3, 2.5.1, 2.6.3 & 2.7.0.


## Configuration

The file mw_cfg.rb allows you to configure:

- the number of letters in the target word
- the maximum number of guesses permitted
- the number of simultaneous games to play (or simultaneous words to
  guess), for example:
  * 1 like [Wordle](https://www.nytimes.com/games/wordle/index.html)
  * 2 like [Dordle](https://zaratustra.itch.io/dordle)
  * 4 like [Quordle](https://www.quordle.com)
  * 8 like [Octordle](https://octordle.com/)
  * 16 like [Sedecordle](https://www.sedecordle.com/)
- various text formatting arrangements
- the default word list file
- optional overriding word list files (one for each N, where N is
  an N-letter-word game)

Colours cannot be changed via the user config file. However, in
file lib/wordle_text_ui.rb, you can change colours by assigning
new values to:

- @@clue_ok_location
- @@clue_ok_letter


## To run

After downloading/unzipping (or git-clone)...

```
$ cd MultiWordle
$ chmod 755 mw.rb   # Once only; make the main file executable
$ ./mw.rb           # Run
```

or

```
$ cd MultiWordle
$ ruby mw.rb        # Run
```

Note that I have used '$' above to represent the Linux command
line prompt. You should not type the '$' sign above.


## Screenshot of the MultiWordle game

![Screenshot of MultiWordle game](/assets/images/multiwordle1a.png)

