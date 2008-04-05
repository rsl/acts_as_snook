module LuckySneaks
  module ActsAsSnook
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    module ClassMethods
      # Sets up spam detection (via before_validation callback). Avaiable options are:
      #
      #   +:author_field+:: Symbol or string specifying a new database field to use for the author attribute
      #   +:email_field+:: Symbol or string specifying a new database field to use for the email attribute
      #   +:url_field+:: Symbol or string specifying a new database field to use for the url attribute
      #   +:body_field+:: Symbol or string specifying a new database field to use for the body attribute
      #   +:author_field+:: Symbol or string specifying a new database field to use for the spam_status attribute
      #   +:spam_words+:: Array of strings which will be added to the list of words which are considered spam markers
      def acts_as_snook(options = {})
        cattr_accessor :spam_words
        self.spam_words = %w{
          -online 4u 4-u acne adipex advicer baccarrat blackjack bllogspot booker buy byob carisoprodol
          casino chatroom cialis coolhu credit-card-debt cwas cyclen cyclobenzaprine
          day-trading debt-consolidation discreetordering duty-free dutyfree equityloans fioricet
          freenet gambling- hair-loss homefinance holdem incest jrcreations leethal levitra macinstruct
          mortgagequotes online-gambling ottawavalleyag ownsthis paxil penis pharmacy phentermine
          poker poze pussy ringtones roulette shemale shoes -site slot-machine thorcarlson
          tramadol trim-spa ultram valeofglamorganconservatives viagra vioxx xanax zolus
        }
        if additional = options.delete(:spam_words)
          self.spam_words << additional
          self.spam_words.flatten.uniq.compact!
        end
        
        cattr_accessor :fields_for_snooking
        self.fields_for_snooking = {
          # Defaults
          :author_field       => :author,
          :email_field        => :email,
          :url_field          => :url,
          :body_field         => :body,
          :spam_status_field  => :spam_status
        }.merge(options)
        
        before_validation :calculate_snook_score
        
        attr_reader :snook_credits
      end
      
      # Returns all instances which have been marked as safe for display
      def ham(options = {})
        find :all, options.merge(:conditions => {fields_for_snooking[:spam_status_field] => "ham"})
      end
      
      # Returns all instances which have been marked as being spam
      def spam(options = {})
        find :all, options.merge(:conditions => {fields_for_snooking[:spam_status_field] => "spam"})
      end
      
      # Returns all instances which have been marked as neither obvious spam nor obviously safe
      # for displaying. This should be a really small number of your comments as it is _very_
      # hard to hit this spot.
      def moderate(options = {})
        find :all, options.merge(:conditions => {fields_for_snooking[:spam_status_field] => "moderate"})
      end
    end
    
    # Returns true if marked as spam, false otherwise
    def spam?
      calculate_snook_score unless snook_credits
      snook_spam_status == "spam"
    end
    
    # Returns true if marked as ham (safe to display), false if spam
    def ham?
      calculate_snook_score unless snook_credits
      snook_spam_status == "ham"
    end
    
    # Returns true if marked as spam, false otherwise
    def moderate?
      calculate_snook_score unless snook_credits
      snook_spam_status == "moderate"
    end
    
  private
    def calculate_snook_for_body_links
      link_count = snook_body.scan(/http:/).size
      if link_count > 2
        deduct_snook_credits link_count
      else
        add_snook_credits 2
      end
    end
    
    def calculate_snook_for_body_length
      if snook_body.length > 20
        add_snook_credits(2) if snook_body.scan(/http:/).size.zero?
      else
        deduct_snook_credits 1
      end
    end
    
    def calculate_snook_for_previous_comments
      add_snook_credits previous_comment_count_for_snook_author("ham")
      deduct_snook_credits previous_comment_count_for_snook_author("spam")
    end
    
    def calculate_snook_for_spam_words
      spam_words.each do |word|
        deduct_snook_credits(1) if snook_body =~ /#{word}/i
        deduct_snook_credits(1) if snook_url =~ /#{word}/i
      end
    end
    
    def calculate_snook_for_suspect_url
      regex = /http:\/\/\S*(\.html|\.info|\?|&|free)/i
      deduct_snook_credits(1 * snook_body.scan(regex).size)
      deduct_snook_credits(1) if snook_url =~ regex
    end
    
    def calculate_snook_for_suspect_tld
      regex = /http:\/\/\S*\.(de|pl|cn)/i
      deduct_snook_credits(1 * snook_body.scan(regex).size)
      deduct_snook_credits(1) if snook_url =~ regex
    end
    
    def calculate_snook_for_url_length
      deduct_snook_credits(1) if snook_url.length > 30
    end
    
    def calculate_snook_for_lame_body_start
      deduct_snook_credits(10) if snook_body =~ /^(interesting|sorry|nice|cool)\s/i
    end
    
    def calculate_snook_for_author_link
      deduct_snook_credits(2 * snook_author.scan(/http:/).size)
    end
    
    def calculate_snook_for_matching_previous_body
      deduct_snook_credits(1 * previous_comments_with_same_snook_body)
    end
    
    def calculate_snook_for_consonant_runs
      [snook_author, snook_email, snook_url, snook_body].each do |snookable|
        snookable.scan(/[bcdfghjklmnpqrstvwxz]{5,}/).each do |run|
          deduct_snook_credits run.size - 4
        end
      end
    end
    
    def calculate_snook_for_bbcode
      deduct_snook_credits(1 * snook_body.scan(/\[(url|img)/i).size)
    end
    
    def calculate_snook_score
      @snook_credits = 0
      calculate_snook_for_body_links
      calculate_snook_for_body_length
      calculate_snook_for_previous_comments
      calculate_snook_for_spam_words
      calculate_snook_for_suspect_url
      calculate_snook_for_suspect_tld
      calculate_snook_for_url_length
      calculate_snook_for_lame_body_start
      calculate_snook_for_author_link
      calculate_snook_for_matching_previous_body
      calculate_snook_for_consonant_runs
      status = if @snook_credits > 0
        "ham"
      elsif @snook_credits == 0
        "moderate"
      else
        "spam"
      end
      self.send("#{self.class.fields_for_snooking[:spam_status_field]}=", status)
    end
    
    def snook_author
      @snook_author ||= self.send(self.class.fields_for_snooking[:author_field]) || ""
    end
    
    def snook_email
      @snook_email ||= self.send(self.class.fields_for_snooking[:email_field]) || ""
    end
    
    def snook_url
      @snook_url ||= self.send(self.class.fields_for_snooking[:url_field]) || ""
    end
    
    def snook_body
      @snook_body ||= self.send(self.class.fields_for_snooking[:body_field]) || ""
    end
    
    def snook_spam_status
      self.send(self.class.fields_for_snooking[:spam_status_field])
    end
    
    def add_snook_credits(addition)
      @snook_credits = @snook_credits + addition
    end
    
    def deduct_snook_credits(deduction)
      @snook_credits = @snook_credits - deduction
    end
    
    def previous_comment_count_for_snook_author(spam_value)
      spam_field = self.class.fields_for_snooking[:spam_status_field]
      email_field = self.class.fields_for_snooking[:email_field]
      email_value = snook_email
      
      conditions = ["#{spam_field} = ? AND #{email_field} = ?", spam_value, email_value]
      
      self.class.count :all, :conditions => conditions
    end
    
    def previous_comments_with_same_snook_body
      body_field = self.class.fields_for_snooking[:body_field]
      body_value = snook_body
      
      conditions = ["#{body_field} = ?", body_value]
      
      self.class.count :all, :conditions => conditions
    end
  end
end