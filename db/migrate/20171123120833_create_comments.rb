class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t| 
      t.string :body
      t.string :user_id
      t.timestamps  
    end
  end
end
