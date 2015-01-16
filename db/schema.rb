ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :name
    t.datetime :date_of_birth
    t.string :gender
    t.belongs_to :team

    t.timestamps
  end

  create_table :teams, :force => true do |t|
    t.string :name
  end
end