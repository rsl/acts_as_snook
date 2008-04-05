ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table :comments, :force => true do |t|
    t.string :author, :email, :url, :spam_status
    t.text :body
  end
end