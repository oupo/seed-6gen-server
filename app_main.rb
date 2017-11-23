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


post '/comment' do  
  Comment.create({
    body: params[:body],
    user_name: params[:user_id]
  })
end

get '/comments/last' do
  content_type :json
  comment = Comment.last
  {comment_body: comment.body, user_id: comment.user_name}.to_json
end