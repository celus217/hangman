require 'yaml'

class GameController
  def initialize(incorrect_guesses = 10, secret_word = word, incorrect_letters = [], guess_array = [])
    @incorrect_guesses = incorrect_guesses
    @secret_word = secret_word
    @secret_word_array = @secret_word.split('')
    if guess_array.empty?
      guess_array = Array.new(@secret_word.length, '_')
    end
    @guess_array = guess_array
    @incorrect_letters = incorrect_letters
  end

  def random_word
    File.open('words.txt', 'r').readlines[rand(1001)].rstrip
  end

  def word
    word = random_word
    word = random_word until word.length <= 12 && word.length >= 5
    word
  end

  def play
    puts "Input characters to play. See if you can guess the word!"
    print_guess
    print_incorrect_guesses
    print_incorrect_letters
    loop do
      quit = make_guess
      break if quit

      print_guess
      print_incorrect_guesses
      print_incorrect_letters
    end
  end

  def make_guess
    guess = gets.chomp.downcase
    quit = false
    if guess == 'save'
      save
      return
    end
    if guess == 'exit'
      quit = true
      puts 'You quit the game'
      return quit
    end
    incorrect_guess = true
    @secret_word_array.each_with_index do |letter, i|
      if guess == letter
        @guess_array[i] = letter
        incorrect_guess = false
      end
    end
    if @guess_array == @secret_word_array
      puts win_message
      quit = true
    end
    if incorrect_guess
      @incorrect_guesses -= 1
      @incorrect_letters.push(guess)
    end
    if @incorrect_guesses <= 0
      puts lose_message
      quit = true
    end
    quit
  end

  def print_guess
    print "Your current guess: #{@guess_array.join(' ')} "
  end

  def print_incorrect_guesses
    puts "Guesses left: #{@incorrect_guesses}"
  end

  def print_incorrect_letters
    puts "Letters incorrectly guessed: #{@incorrect_letters.join(', ')}"
  end

  def to_yaml
    YAML.dump({
      incorrect_guesses: @incorrect_guesses,
      secret_word: @secret_word,
      incorrect_letters: @incorrect_letters,
      guess_array: @guess_array
    })
  end

  def save
    puts 'You saved your game'
    File.open('gamesave.txt', 'w').puts to_yaml
  end

  def self.load
    data = YAML.load File.open('gamesave.txt', 'r').read
    new(data[:incorrect_guesses], data[:secret_word], data[:incorrect_letters], data[:guess_array])
  end

  def win_message
    "You won! Congratulations, the word was #{@secret_word}"
  end

  def lose_message
    "You lost. The word was #{@secret_word}"
  end
end

class InitialMenu
  def initialize
    @game = ''
  end

  def start_game
    puts 'Welcome to Hangman. If you want to play a new game, type "new". If you want to play the saved game, type "saved".'
    loop do
      decision = gets.chomp.downcase
      if decision == 'new'
        @game = GameController.new
        break
      elsif decision == 'saved'
        @game = GameController.load
        break
      else
        puts 'Please input a valid choice'
      end
    end
    @game.play
  end
end

menu = InitialMenu.new
menu.start_game
