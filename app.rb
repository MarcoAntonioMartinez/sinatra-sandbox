require "sinatra"
require "sinatra/reloader"
 require "http"
 require "json"
  
 require "sinatra/contrib"

def api_response(url, key)
  resp = HTTP.get(url)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  #so i dont have to basically make a variable the same as parsed response on line 33 (2 lines above here)
  return fetched_key = parsed_response.fetch(key)
end


 


get("/") do
   new_deck = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"

  resp = HTTP.get(new_deck)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  deck = parsed_response.fetch("deck_id")

  draw_52 = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=52"
  ft_cards = api_response(draw_52, "cards")
  deck_extra = []

  ft_cards.each do |c|
    deck_extra.push(c.fetch("code"))
  end

  cards_deck_pile = deck_extra.join(",")

   cookies[:deck_id] = deck

  #add the 52 cards from the deck
pile_name = "deck"

  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cards_deck_pile
  deck_pile = api_response(pile, "piles")


  pile_name = "deck"
  start_game = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name +  "/draw/?count=7"
  re = api_response(start_game, "cards")

   
# resp = HTTP.get(start_game)

  # raw_response = resp.to_s

  # parsed_response = JSON.parse(raw_response)

  cards = re

  @card_arr = []

  @code_arr = []

  cards.each do |c|
    @card_arr.push(c.fetch("image"))

    @code_arr.push(c.fetch("code"))

    cookies[:hand] = (@code_arr.join(","))
  end

  pile_name = "hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cookies[:hand]

  rea = HTTP.get(@pile)









  pile_name = "deck"
  @game_start = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=1"

  #need to get first card
  game_card = api_response(@game_start, "success")
  
  @game_starting_draw = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

  #need to get first card
  @first_card = api_response(@game_starting_draw, "piles").fetch(pile_name).fetch("cards")[0]

  #@first_card.each do |c|
    # @card = c.fetch("image")

    @code = @first_card.fetch("code")

    # @value = c.fetch("value")

    # @suit = c.fetch("suit")
  # end

  erb(:home)
end
