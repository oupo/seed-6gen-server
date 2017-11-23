require 'sinatra'
require 'active_record'
require 'json'

if ENV['DATABASE_URL']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3",
    "database" => "app.db"
  )
end

class Comment < ActiveRecord::Base
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  @comments = Comment.order('id desc')
  erb :index
end

def check_iv(str)
  m = /\A\d+-\d+-\d+-\d+-\d+-\d+/.match(str)
  m && str.scan(/\d+/).map{|x| x.to_i }.all?{|x| 0 <= x && x < 32 }
end

post '/post' do
  if /\A20\d{2}\/\d{2}\/\d{2} \d{2}:  \d{2}:\d{2}\z/ !~ params[:game_time]
    "invalid game_time"
  elsif not check_iv(params[:iv0])
    "invalid iv0"
  elsif not check_iv(params[:iv1])
    "invalid iv1"
  elsif params[:iv0] == "0-0-0-0-0-0" && params[:iv0] == "0-0-0-0-0-0"
    "iv must not be default value"
  else
    Comment.create({
      iv0: params[:iv0],
      iv1: params[:iv1],
      game_time: params[:game_time]
    })
    "ok"
  end
end
