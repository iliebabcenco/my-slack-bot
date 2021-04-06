require 'telegram/bot'
require './lib/ui_tictac'
require './lib/logic_bot'
require './lib/player'

TOKEN = '1723295532:AAG4CclSM9lsDBAZFTSKTzIKxdWFZUnl3RU'.freeze

ANSWERS = ['hey try /start', 'of course, now try /start', 'yeah, try /start', 'or you can try start',
           'print start hehe'].freeze

def send_message(bot, mes, text = nil)
  bot.api.send_message(
    chat_id: mes.chat.id,
    text: text
  )
end

def send_keyboard(bot, message, keyboard_type, text_message)
  answers =
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: keyboard_type,
      one_time_keyboard: true
    )
  bot.api.sendMessage(
    chat_id: message.chat.id,
    text: text_message,
    reply_markup: answers
  )
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  mscounter = 0
  interface = UI_game.new
  game_logic = interface.game_logic
  player = game_logic.player
  bot.listen do |message|
    player.name = message.from.first_name
    mscounter += 1
    if mscounter == 1
      key_type = %w[yes no]
      text_message = "Hey, #{player.name} \nI wanna play with you a tic tac toe game, do you? (y/n)"
      send_keyboard(bot, message, key_type, text_message)
    else
      response = game_logic.check_message(message.text)
      case response
      when 'start'
        send_message(bot, message, interface.start_game)
        send_keyboard(bot, message, interface.key_board, interface.draw_board)
      when 'numbers'
        send_keyboard(bot, message, interface.key_board,
                      "Is #{player.name}'s turn, choose an available number from the board:")
        send_message(bot, message, interface.draw_board)
      when 'game-over'
        
        answer = if game_logic.winner == 'DRAW'
                   "It's a DRAW\nIf you wanna restart the game type start"
                 else
                   "#{game_logic.winner} is winner!\nIf you wanna restart the game type start"
                 end
        interface = UI_game.new
        game_logic = interface.game_logic
        player = game_logic.player
        send_keyboard(bot, message, 'Start!', answer)
        send_message(bot, message, interface.draw_board)
      when 'end'
        interface = UI_game.new
        game_logic = interface.game_logic
        player = game_logic.player
        send_keyboard(bot, message, 'Start!', interface.finish_game)
      when 'numbers-error'
        
        send_keyboard(bot, message, interface.key_board,
                      "'#{message.text}' is not a good choice please select an available number from the board.")
        send_message(bot, message, interface.draw_board)
      when 'error'
        send_message(bot, message, ANSWERS.sample)
      end
    end
  end
end
