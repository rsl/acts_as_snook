class Comment < ActiveRecord::Base
  belongs_to :entry
  
  acts_as_snook # Defaults
end