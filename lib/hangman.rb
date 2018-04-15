require 'yaml'

class Hangman
  attr_reader :word
  attr_accessor :letters, :misses

  def initialize(word)
    @word = word
    @letters = ''
    @misses = 0
  end

  def serialize
    YAML::dump(self)
  end

  def self.deserialize(yaml_string)
    YAML::load(yaml_string)
  end

  def hidden_word
    return '_' * @word.length if @letters == ''
    @word.gsub(/[^#{letters}]/, '_')
  end

  def won?
    !hidden_word.include?('_')
  end

  def lost?
    @misses >= 6
  end

  def guess(letter)
    if @word.include?(letter)
      @letters += letter
      true
    else
      @misses += 1
      @letters += letter
      false
    end
  end
end

def save_game(yaml_string)
  File.open('save_file.txt', 'w') do |file|
    file.puts yaml_string
  end
end

puts "Loading dictionary..."
DICTIONARY = File.open('5desk.txt', 'r').each_line.map do |line|
  line.strip.downcase
end.select { |word| (5..12).include?(word.length) }

# Main menu
loop do
  puts "1 - New game"
  puts "2 - Load game"

  input = gets.chomp

  case input
  when '1'
    game = Hangman.new(DICTIONARY.sample)
  when '2'
    if File.exist?('save_file.txt')
      save_file = File.open('save_file.txt', 'r')
      game = Hangman.deserialize(save_file)
    else
      puts 'Save file not found.'
      next
    end
  else
    puts 'Invalid input.'
    next
  end

  loop do
    puts ''
    puts game.hidden_word
    input = gets.chomp.downcase
    if input == 'quit' || input == 'exit'
      puts 'See ya!'
      exit

    elsif input == 'save_'
      save_game(game.serialize)
      puts "Game saved."

    elsif input.length == 1 && /[a-z]/ =~ input
      # puts 'Valid input.'
      if game.letters.include?(input)
        puts "'#{input}' has been guessed already."
        next
      elsif game.guess(input)
        puts "It does have a '#{input}'."
      else
        puts "It doesn't have a '#{input}'."
      end

    elsif input == game.word
      puts "That's it! You won!"
      break

    else
      puts 'Invalid input.'
    end

    if game.won?
      puts game.word
      puts "That's it! You won!"
      break
    elsif game.lost?
      puts "You're out of guesses. You lost!"
      puts "The word was: #{game.word}"
      break
    end

    puts "Letters guessed so far: #{game.letters}"
    puts "You've missed #{game.misses} times."

  end
end
