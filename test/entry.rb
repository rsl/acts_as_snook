class Entry < ActiveRecord::Base
  has_many :comments
end