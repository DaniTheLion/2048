require 'io/console'

# Reads keypresses from the user including 2 and 3 escape character sequences.
def read_key
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return single_command(input)
end

# oringal case statement from:
# http://www.alecjacobson.com/weblog/?p=75
def single_command(c)
  case c
  when " "
   "SPACE"
  when "\t"
   "TAB"
  when "\r"
   "RETURN"
  when "\n"
   "LINE FEED"
  when "\e"
   "ESCAPE"
  when "\e[A"
   :up
  when "\e[B"
   :down
  when "\e[C"
   :right
  when "\e[D"
   :left
  when "\177"
   "BACKSPACE"
  when "\004"
   "DELETE"
  when "\e[3~"
   "ALTERNATE DELETE"
  when "\u0003"
   "CONTROL-C"
    exit 0
  else
    c
  end
end

# show_single_key while(true)