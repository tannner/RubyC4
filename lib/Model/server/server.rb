require 'test/unit'
require "yaml"
require_relative '../database.rb'
require_relative '../game.rb'
require_relative '../player.rb'
require_relative '../board.rb'

module Model
  class Server    
    include Test::Unit::Assertions
    
    def initialize
      @db = Database.new
    end
    
    def login(name,password)
      #preconditions
      assert(name.is_a?String)
      assert(password.is_a?String)
      
      return YAML::dump(@db.login(name,password))
    end
    # returns an array of new String(usernames)
    def get_users()
      YAML::dump(@db.get_users)
    end

    # returns the board 
    def getBoard(gameId,name,password)
      assert(gameId.is_a?Integer)
      
      return YAML::dump(false) if !@db.login(name,password) || @db.get_game(gameId).nil?
      return YAML::dump(@db.get_game(gameId).board)
    end

    # makes move on server, returns nothing
    def makeMove(gameId, name, password, move)
      assert(gameId.is_a?Integer)
      assert(move.is_a?Integer)
      
      return YAML::dump(false) if !@db.login(name,password)
      
      game_model = @db.get_game(gameId)
      game_model.makeMove(@db.get_player(name),move)
      @db.save_game(gameId,game_model) 
      
      return YAML::dump(true)
    end

    #
    def whosTurn(gameId,name,password)
      assert(gameId.is_a?Integer)
      
      return YAML::dump(false) if !@db.login(name,password)
      
      game_model = @db.get_game(gameId)
      return YAML::dump(game_model.currentPlayersTurn)
    end

    def getGameType(gameId,name,password)
      assert(gameId.is_a?Integer)
      
      return YAML::dump(false) if !@db.login(name,password)
      
      game_model = @db.get_game(gameId)
      
      return YAML::dump(game_model.gameType)
    end
    
    def getPlayer(name, password)
      return YAML::dump(false) if !@db.login(name, password)
      return YAML::dump(@db.get_player(name))
    end
    
    def getPlayers(gameId, name, password)
      return YAML::dump(false) if !@db.login(name, password)
      return YAML::dump(@db.get_players(gameId))
    end
    
    def getWinner(gameId, name, password)
      return YAML::dump(false) if !@db.login(name, password)
      return YAML::dump(@db.get_winner(gameId))
    end

    def newGame(name, password, opponent, gameType)
      gameType=:connect4 if gameType=="connect4"      
      gameType=:otto if gameType=="otto"
      return YAML::dump(false) if !@db.login(name,password)
      
      player1 = @db.get_player(name)
      player2 = @db.get_player(opponent)
      game = Model::Game.new(player1,player2, gameType)
      
      game.players.each do |player|
	player.winCondition = [:player, :player, :player, :player] if gameType == :connect4
      	player.winCondition = [:player, :other, :other, :player] if gameType == :otto
      end
            
      gameId = @db.new_game(game)
      
      return YAML::dump(gameId)
    end

    def getGameList(name,password)      
      return YAML::dump(false) if !@db.login(name,password)
      return YAML::dump(@db.getGameList(@db.get_id(name)))
    end

    def getLeaderboard
	return YAML::dump(@db.get_leaderboard)
    end

  end
end
