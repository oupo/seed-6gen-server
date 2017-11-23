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
  if /\A20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\z/ !~ params[:game_time]
    "invalid game_time"
  elsif not check_iv(params[:iv0])
    "invalid iv0"
  elsif not check_iv(params[:iv1])
    "invalid iv1"
  elsif params[:iv0] == "0-0-0-0-0-0" && params[:iv0] == "0-0-0-0-0-0"
    "iv must not be default value"
  elsif not (comments = Comment.where(iv0: params[:iv0], iv1: params[:iv1])).empty?
    "iv is equal to No.#{comments[0].id}"
  else
    Comment.create({
      iv0: params[:iv0],
      iv1: params[:iv1],
      game_time: params[:game_time],
      ip_addr: request.ip
    })
    "ok"
  end
end

def judge_answer(iv0, iv1, seed)
  mt = Random.new(seed)
  rand = []
  m = 1000
  n = 10000
  n.times do |i|
    rand[i] = (mt.rand(2**32) * 32) >> 32
  end
  (m - 6).times do |i|
    if rand[i, 6] == iv0
      ((i + 6)...(n - 6)).each do |j|
        if rand[j, 6] == iv1
          return true
        end
      end
    end
  end
  false
end

post '/answer' do
  if /\A\d+\z/ !~ params[:id] || /\A[0-9a-f]{8}\z/ !~ params[:seed]
    "ng"
  else
    id = params[:id].to_i
    seed = params[:seed].to_i(16)
    comments = Comment.where(id: id)
    if comments.size != 1
      "ng"
    else
      comment = comments[0]
      iv0 = comment.iv0.scan(/\d+/).map(&:to_i)
      iv1 = comment.iv1.scan(/\d+/).map(&:to_i)
      if judge_answer(iv0, iv1, seed)
        comment.answer = "%08x" % seed
        comment.save
        "ok"
      else
        "incorrect"
      end
    end
  end
end