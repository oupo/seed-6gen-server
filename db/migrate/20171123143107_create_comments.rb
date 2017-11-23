class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t| 
      t.string :iv0
      t.string :iv1
      t.string :game_time
      t.string :answer
      t.string :ip_addr
      t.timestamps
    end
  end
end
