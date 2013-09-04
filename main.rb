require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK = 21
DEALER_MIN = 17
START_BANKROLL = 500

helpers do
  def calc_total(hand)
    array = hand.map{|element| element[0]}

    total = 0
    array.each do |a|
      if a == "A"
        total += 11
      else
        total += a.to_i  == 0 ? 10 : a.to_i
      end
    end
  

  array.select {|element| element == "A"}.count.times do
    break if total <= BLACKJACK
    total -= 10
  end

    total
  end

 def card_img(card)
  suit = case card[1]
    when "H" then 'hearts'
    when "C" then 'clubs'
    when "D" then 'diamonds'
    when "S" then 'spades'
  end

  val = card[0]
    if ['J','K','Q','A'].include?(val)
      val = case card[0]
      when "J" then 'jack'
      when "Q" then 'queen'
      when "K" then 'king'
      when "A" then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{val}.jpg' class= 'card_img'>"
  end

  def winner!(msg)
    @play_again = true
    @show_buttons = false
    session[:bankroll] = session[:bankroll] + session[:player_bet].to_i 
    @winner = "<strong> #{session[:player_name]} wins!</strong> #{msg}"
  end

  def loser!(msg)
    @play_again = true
    @show_buttons = false
    session[:bankroll] = session[:bankroll] - session[:player_bet].to_i
    @loser = "<strong> #{session[:player_name]} loses!</strong> #{msg}"
  end

  def tie(msg)
    @play_again = true
    @show_buttons = false
    @winner = "<strong> It's a draw!</strong>"
  end

end

before do
  @show_buttons = true
end


get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/player_form'
  end
end

get '/player_form' do
  session[:bankroll] = START_BANKROLL
  erb :player_form
end


post '/name' do
  if params[:player_name].empty?
    @error= "Please enter your name."
    halt erb(:player_form)
  end

  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do 
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error= "Please make a bet." 
    halt erb(:bet)
  elsif 
    params[:bet_amount].to_i > session[:bankroll]
    @error= "Cant bet more than you have." 
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount]
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:player_name]

  suit = ['H','C','D','S']
  val = ['A','2','3','4','5','6','7','8','9','10','J','Q','K']
  session[:deck] = val.product(suit).shuffle!

  session[:dealer_hand] = []
  session[:player_hand] = []
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop
  session[:dealer_hand] << session[:deck].pop
  session[:player_hand] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do
  session[:player_hand] << session[:deck].pop
  
  player_total = calc_total(session[:player_hand])
  if player_total == BLACKJACK 
    winner!("  With a Blackjack")
  elsif player_total > BLACKJACK
    loser!("  You have busted!")
  end
  
  erb :game , layout:false
end

post '/game/player/stand' do
  @success = session[:player_name] + " chose to stand on total of " + calc_total(session[:player_hand]).to_s
  @show_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"

  @show_buttons = false

  dealer_total = calc_total(session[:dealer_hand])

    if dealer_total == BLACKJACK
      loser!(" dealer has blackjack.")
    elsif dealer_total > BLACKJACK
      winner! (" The dealer bust with #{dealer_total}.")
    elsif dealer_total >= DEALER_MIN
      redirect '/game/compare'
    else
      @show_dealer_hitbtn = true
    end

    erb :game, layout:false
end

post '/game/dealer/hit' do
  session[:dealer_hand] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_buttons = false

  player_total = calc_total(session[:player_hand])
  dealer_total = calc_total(session[:dealer_hand])

  if player_total > dealer_total
    winner!(" Your total of #{player_total} beats the dealers total of #{dealer_total}.")
  elsif dealer_total > player_total
    loser!(" Your total of #{player_total} loses to dealers total of #{dealer_total}.")
  else 
    tie (" both players have a total of #{player_total}")
  end
  erb :game, layout:false
end

get '/game_over' do
  erb :game_over
end

