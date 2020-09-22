module ArtificialIntelligence
  def make_code
    code = []
    4.times do |i|
      i = rand(6)
      case i
      when 0
        code << 'b'
      when 1
        code << 'r'
      when 2
        code << 'g'
      when 3
        code << 'w'
      when 4
        code << 'y'
      when 5
        code << 'p'
      end
    end
    code
  end

  def make_guess(rgbwyp, turn, result, guessed_code, control_start, try_place, controlled_place, final_guess)
    ai_guess = []
    if rgbwyp.sum < 4
      rgbwyp[turn - 2] += result.count('R')
    end

    if rgbwyp.sum == 4
      ai_guess = guess_phase_two(rgbwyp, guessed_code, result, control_start, try_place, controlled_place, final_guess)
    elsif turn == 6
      rgbwyp[4] = result.count('R')
      rgbwyp[5] = 4 - rgbwyp.sum
      ai_guess = guess_phase_two(rgbwyp, guessed_code, result, control_start, try_place, controlled_place, final_guess)
    else
      case turn
      when 1
        ai_guess = ['r', 'r', 'r', 'r']
      when 2
        ai_guess = ['g', 'g', 'g', 'g']
      when 3
        ai_guess = ['b', 'b', 'b', 'b']
      when 4
        ai_guess = ['w', 'w', 'w', 'w']
      when 5
        ai_guess = ['y', 'y', 'y', 'y']
      end
    end
    ai_guess
  end

  def guess_phase_two(rgbwyp, guessed_code, result, control_start, try_place, controlled_place, final_guess)
    colors = ['r', 'g', 'b', 'w', 'y', 'p']
    control_color = colors[rgbwyp.index(0)]
    control_guess = []
    4.times { |i| control_guess[i] = control_color }
    colors_in_code = choose_colors(rgbwyp,colors)
    if control_start[0] != 0
      if result.include?('R')
        final_guess[try_place[0]] = colors_in_code[controlled_place[0]]
        guessed_code[try_place[0]] = 2
        guessed_code.each_index do |i|
          if guessed_code[i] != 2
            guessed_code[i] = 0
          end
        end
        try_place[0] = guessed_code.index(0)
        controlled_place[0] += 1
      else
        guessed_code[try_place[0]] = 1
        try_place[0] = guessed_code.index(0)
      end
      if guessed_code.count(0) == 1
        final_guess[try_place[0]] = colors_in_code[controlled_place[0]]
        guessed_code[try_place[0]] = 2
        guessed_code.each_index do |i|
          if guessed_code[i] != 2
            guessed_code[i] = 0
          end
        end
        try_place[0] = guessed_code.index(0)
        controlled_place[0] += 1
      end
      if final_guess.count(0) == 1
        final_guess[final_guess.index(0)] = colors_in_code[3]
        return final_guess
      elsif final_guess.count(0) == 0
        return final_guess
      end
    end

    controlled_color = colors_in_code[controlled_place[0]]
    control_guess[try_place[0]] = controlled_color
    control_start[0] = 1
    control_guess
  end

  def choose_colors(rgbwyp, colors)
    needed_colors = []
    rgbwyp.each_index do |i|
      if rgbwyp[i] == 0
        next
      else
        rgbwyp[i].times { needed_colors << colors[i] }
      end
    end
    needed_colors
  end

  def check_guess(code, guesses)
    check_value = []
    correct = 0
    wrong_place = 0
    irrelevant = 0
    code_holder = code.clone
    guess_holder = guesses.clone
    ic = 0
    guesses.each do |guess|
      if guess == code[ic]
        correct += 1
        code_holder.delete_at(code_holder.index(guess))
        guess_holder.delete_at(guess_holder.index(guess))
      end
      ic += 1
    end
    guess_holder.each do |guess|
      if code_holder.include?(guess)
        wrong_place += 1
        code_holder.delete_at(code_holder.index(guess))
      end
    end
    irrelevant = 4 - correct - wrong_place
    correct.times { check_value << 'R' }
    wrong_place.times { check_value << 'W' }
    irrelevant.times { check_value << 'N' }
    return check_value
  end

  def make_board
    board = [[[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']],
             [[' ',' ',' ',' '],[' ',' ',' ',' ']]]
  end

  def check_entry(entry)
    colors = ['r', 'g', 'b', 'w', 'y', 'p']
    if entry.class != Array || entry.length != 4
      return false
    end
    entry.each do |element|
      if element.class != String
        return false
      elsif colors.include?(element) == false
        return false
      end
    end
  end
end

class Mastermind
  extend ArtificialIntelligence

  def self.play
    puts 'Welcome to the game of Mastermind'
    puts
    puts 'Please choose whether you or the computer will be codemaker'
    puts 'Enter "1" for computer or "2" for yourself'
    choice = gets.chomp
    choice == '1' ? self.game_vs_player : self.game_vs_ai

  end

  def self.game_vs_player
    puts 'Game has begun!'
    sleep(1)
    code = make_code
    board = make_board
    self.rules
    puts 'Press enter to start'
    gets
    puts 'Computer decided the code now your turn!'
    game_over = false
    guess_number = 0
    self.print_board(board)
    until game_over
      guess_number += 1
      puts 'Your guess?'
      guess = gets.chomp.downcase.split('')
      if check_entry(guess) == false
        puts 'Please follow the rules'
        redo
      end
      checked_results = check_guess(code, guess)
      game_over = self.main(code, board, guess, guess_number, checked_results)
    end
  end

  def self.game_vs_ai
    rgbwyp = [0, 0, 0, 0, 0, 0]
    guessed_code = [0, 0, 0, 0]
    control_start = [0]
    final_guess = [0, 0, 0, 0]
    board = make_board
    game_over = false
    guess_number = 0
    checked_results = []
    guess = []
    try_place = [0]
    controlled_place = [0]
    puts 'Game has begun!'
    sleep(1)
    puts 'Decide the code, Mighty Codemaker'
    code = gets.chomp.downcase.split('')
    if check_entry(code) == false
      puts 'Please follow the rules'
      self.game_vs_ai
    end
    sleep(1)
    self.print_board(board)
    until game_over
      guess_number += 1
      guess = make_guess(rgbwyp, guess_number, checked_results, guessed_code, control_start, try_place, controlled_place, final_guess)
      puts "Computer has guessed: #{guess}"
      checked_results = check_guess(code, guess)
      game_over = self.main(code, board, guess, guess_number, checked_results)
      sleep(2)
    end
  end

  def self.main(code, board, guess, guess_number, result)
    self.change_board(guess, result, board, guess_number)
    self.print_board(board)
    if result == ['R', 'R', 'R', 'R']
      puts "Code: #{code}"
      puts 'You break it! You won!'
      return true
    elsif guess_number == 12
      puts "Code: #{code}"
      puts 'You could\'t break the code! Shame!'
      return true
    end
    return false
  end

  def self.rules
    puts 'e.g: "rgby" for "red, green, blue, yellow" '
    puts 'Allowed colors and symbols:'
    puts ['Blue: b', 'Red: r', 'Green: g', 'White: w', 'Yellow: y', "Purple: p"]
    puts 'For the guess it returns;'
    puts '"R" means you guessed place and the color both right'
    puts '"W" means you just guessed right color but in the wrong place'
    puts '"N" means neighter color nor place is correct'
    puts 'These symbols WON\'T BE IN ANY PARTICULAR order!'
  end

  def self.change_board(guess, result, board, turn)
    board[turn-1][0] = guess
    board[turn-1][1] = result
  end

  def self.print_board(board)
    board.each do |line|
      puts "#{line[0]}|#{line[1]}"
    end
  end
end

Mastermind.play
