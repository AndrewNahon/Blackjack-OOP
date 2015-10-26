class PlayingDeck
  attr_accessor :cards
  
  def initialize(num_of_decks)
    @cards = (Deck.new.one_deck * num_of_decks).shuffle #@cards is an array of card objects
  end
end

class Deck
  CARD_NAMES = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
  SUITS = %w(Hearts Diamonds Clubs Spades)
  CARDS_IN_A_DECK = CARD_NAMES.product(SUITS)
  
  attr_accessor :one_deck

  def initialize
    @one_deck = []
    CARDS_IN_A_DECK.each {|card| @one_deck << Card.new(card[0], card[1]) }
  end
end

class Card
  attr_accessor :name, :suit
  
  def initialize(name, suit)
    @name = name
    @suit = suit
  end
end

class Player
  attr_accessor :name, :hand, :card_total, :deck

  def initialize(name)
    @name = name
    @hand = [] 
    @card_total = 0
  end

  def try_to_cheat(deck)
    last_card = deck.cards.last  
    get_away_with_it = [true, true, false].sample
    puts "Do you try to sneak a peak at the next card?"
    choice = gets.chomp.downcase
    if get_away_with_it && choice == 'yes'
        puts "The next card is a #{last_card.name}."
    elsif choice == 'yes'
        puts "Dealer: 'Excuse me sir. We don't take kindly ta cheaters in these parts. Now get the hell out!"
        exit
    end 
  end
end

class Game
  attr_accessor :game_deck, :player, :dealer

  def initialize
    @game_deck = PlayingDeck.new(3)
    @player = Player.new('Andrew')
    @dealer = Player.new('Dealer')
    system 'clear'
    puts "Let's play some Blackjack pardner.\n\n"
    sleep(1)
  end

  def hit(player)
    player.hand << game_deck.cards.pop
  end

  def show_hand(player)
    puts "#{player.name}'s' hand: "
    player.hand.each {|card| puts "#{card.name} of #{card.suit}"}
    puts "Total: #{sum(player)}"
    puts ''
  end

  def show_one_card(player)
    puts "#{player.name} showing: "
    puts "#{player.hand[0].name} of #{player.hand[0].suit}"
  end

  def sum(player)
    player.card_total = 0
    player.hand.each do |card| #card object has @name, @suit instance variables. 
      if card.name.to_i != 0
        player.card_total += card.name.to_i
      elsif card.name == "Ace"
        player.card_total += 11
      else
        player.card_total += 10
      end
    end
    ace_count = player.hand.select {|card| card.name == 'Ace'}.count
      if ace_count > 0
        ace_count.times do |num_of_aces| 
          player.card_total -= 10 if player.card_total > 21
        end
      end
    player.card_total
  end

  def decide_hit_or_stay
    puts "Do you want to hit or stay?"
    hit_stay = gets.chomp.downcase
    until %w(hit stay).include?(hit_stay)
      puts "You must enter either 'hit' or 'stay'"
      hit_stay = gets.chomp.downcase
    end
    hit_stay
  end

  def blackjack?(player)
    if sum(player) == 21 
      show_hand(player)
      return true
    end
    false
  end

  def bust?(player)
    sum(player) > 21 ? true : false
  end

  def player_turn(player, deck)
    puts "\n--------player's turn------------"
    player.try_to_cheat(deck)
    until decide_hit_or_stay == 'stay' || blackjack?(player)
      hit(player)
      puts "You got a #{player.hand.last.name} of #{player.hand.last.suit}"
      show_hand(player)
      puts "You're bust" if bust?(player)
      play_again if bust?(player)
    end 
  end
  
  def dealer_turn(dealer)
    puts "\n----------Dealer's turn------------"
    show_hand(dealer)
    puts "Dealer got blackjack. You lose." if blackjack?(dealer)
    exit if blackjack?(dealer)
    while sum(dealer) < 17
      hit(dealer)
      puts "Dealer got a #{dealer.hand.last.name} of #{dealer.hand.last.suit}"
      show_hand(dealer)
      puts "Dealer went bust. You win" if bust?(dealer)
      play_again if bust?(dealer)
    end 
  end

  def determine_winner(player, dealer)
    if sum(player) == sum(dealer)
      puts "It's a tie"
      play_again
    elsif sum(player) > sum(dealer)
      puts "You won!"
      play_again
    else
      puts "Dealer won."
      play_again
    end
  end

  def play_again
    puts "Would you like to play again? Enter 'yes or 'no'"
    answer = gets.chomp.downcase
    if answer != 'no'
      Game.new.play
    end   
    "Take it easy, friendo."
    exit
  end

  def play
    hit(player)
    hit(dealer)
    hit(player)
    hit(dealer)
    show_hand(player)
    if blackjack?(player)
      puts "Nice you got blackjack."
      play_again
    end
    show_one_card(dealer) 
    player_turn(player, game_deck)
    dealer_turn(dealer)
    determine_winner(player, dealer)
  end
end

Game.new.play