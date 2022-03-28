# MultiWordle

A clone of Wordle which allows many of the game's features to be customised
via a configuration file.

This game uses a text user interface and assumes a colour xterm is being
used under Linux. I have not tested under Mac OS X or Windows running
Cygwin, MobaXterm or similar.


## Configuration

The file mw_cfg.rb allows you to configure:

- the number of letters in the target word
- the maximum number of guesses permitted
- the number of simultaneous games to play (or simultaneous words to guess), 
  for example:
  * 2 like [Dordle](https://zaratustra.itch.io/dordle)
  * 4 like [Quordle](https://www.quordle.com)
  * 8 like [Octordle](https://octordle.com/)
  * 16 like [Sedecordle](https://www.sedecordle.com/)
- various text formatting arrangements

You can also change the word list (i.e. dictionary of words) but currently
that is not done via the above config file. Instead, edit the file
lib/wordle.rb and change WordListPath.

You need to install ruby first (if not already installed). The program
has been tested under Ruby 2.3.3, but I imagine it will work under any
Ruby 2.x version.


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

