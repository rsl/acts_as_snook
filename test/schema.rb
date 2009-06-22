ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
  create_table :comments, :force => true do |t|
    t.integer :entry_id
    t.string :author, :email, :url, :spam_status
    t.text :body
  end
  
  create_table :entries, :force => true do |t|
    t.string :title
    t.integer :ham_comments_count, :default => 0
  end
  
  create_table :extended_comments, :force => true do |t|
    t.integer :entry_id
    t.string :author, :email, :url, :spam_status
    t.text :body
  end
  
  create_table :extended_entries, :force => true do |t|
    t.string :title
    t.integer :ham_comments_count, :default => 0
  end
end