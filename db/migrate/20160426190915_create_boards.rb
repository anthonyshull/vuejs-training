class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :description
    end
  end
end
