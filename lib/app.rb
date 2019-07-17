# ligne très importante qui appelle la gem.
require 'pry'
require 'dotenv'
require 'twitter'

local_dir = File.expand_path('../', __FILE__)
$LOAD_PATH.unshift(local_dir)

require 'journalists.rb'
# n'oublie pas les lignes pour Dotenv ici…
Dotenv.load('.env') 

class Bot

  def initialize(journalists)
    @client = login_twitter
    @journalists = journalists
    @hashtbonjour = '#bonjour_monde'
    @thp = "@the_hacking_pro"
    choose_alea_jour
  end

  def login_twitter
    #binding.pry
    # quelques lignes qui appellent les clés d'API de ton fichier .env
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
    client
  end

  def login_streaming
    @client_stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
    @client_stream
  end

  def choose_alea_jour
    @five_journalists = []
    5.times do
      choice = rand(0..@journalists.length)
      @five_journalists << @journalists[choice]
    end
    @five_journalists
  end

  #Dis Bonjour
  def say_hello
    @five_journalists.each do |select|
      @client.update("#{select} Merci pour votre travail! #{@hashtbonjour} #{@thp}")
    end
  end

  # Like les 25 derniers tweets avec le hashtag bonjour_monde
  def like_hello
    @client.search("#{@hashtbonjour}", result_type: "recent").take(25).collect do |tweet|
      @client.favorite(tweet)
    end
  end

  # Follow les 20 dernières personnes ayant tweeté bonjour_monde
  def follow_hello
    @client.search("#{@hashtbonjour}", result_type: "recent").take(25).collect do |tweet|
      @client.follow(tweet.user)  
    end
  end

  # Like les tweets et follow les twittos utilisant le bonjour_monde en direct
  def like_follow_live
    login_streaming
    @client_stream.filter(:track => "#{@hashtbonjour}") do |tweet|
      @client.favorite!(tweet)
      @client.follow(tweet.user)
    end
  end

end

bot = Bot.new(JOURNALISTS)

binding.pry
