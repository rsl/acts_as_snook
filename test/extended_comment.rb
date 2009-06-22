class ExtendedComment < ActiveRecord::Base
  belongs_to :entry
  
  acts_as_snook do
    deduct_snook_credits(10) do
      body =~ /Simon/
    end
    
    add_snook_credits(10) do
      author == "Charles Ford"
    end
    
    force_snook_status(:spam) do
      author == "spambot"
    end
    
    force_snook_status(:ham) do
      author == "hambot"
    end
  end
end