class Entry < ActiveRecord::Base
  has_many :comments
  has_many :extended_comments
end