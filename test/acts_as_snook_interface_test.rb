require "test/test_helper"

class ActsAsSnookInterfaceTest < Test::Unit::TestCase
  def test_marks_spam_as_spam
    SPAM_COMMENTS.each do |comment_attributes|
      @comment = Comment.create(comment_attributes)
      assert_equal "spam", @comment.spam_status
    end
    Comment.destroy_all
  end
  
  def test_marks_ham_as_ham
    HAM_COMMENTS.each do |comment_attributes|
      @comment = Comment.new(comment_attributes)
      @comment.valid?
      assert_equal "ham", @comment.spam_status
    end
  end
  
  def test_indicates_spam_status_of_spam
    @comment = Comment.new(SPAM_COMMENTS.first)
    assert @comment.spam?
  end
  
  def test_indicates_spam_status_of_ham
    @comment = Comment.new(HAM_COMMENTS.first)
    assert @comment.ham?
  end
  
  def test_indicates_spam_status_of_comments_needing_moderation
    # This is a hard spot to hit!
    @comment = Comment.new(
      :author => "Mister Mxyzptlk",
      :url => "http://superman.de",
      :body => "I take viagra and cialis but I'm not selling it."
    )
    assert @comment.moderate?
  end
  
  def test_collates_spam
    SPAM_COMMENTS.each{|attributes| Comment.create attributes}
    HAM_COMMENTS.each{|attributes| Comment.create attributes}
    
    assert Comment.spam.all?{|comment| comment.spam_status == "spam"}
    
    Comment.delete_all
  end
  
  def test_collates_ham
    SPAM_COMMENTS.each{|attributes| Comment.create attributes}
    HAM_COMMENTS.each{|attributes| Comment.create attributes}
    
    assert Comment.ham.all?{|comment| comment.spam_status == "ham"}
    
    Comment.delete_all
  end
  
  def test_collates_comments_needing_moderation
    SPAM_COMMENTS.each{|attributes| Comment.create attributes}
    HAM_COMMENTS.each{|attributes| Comment.create attributes}
    
    assert Comment.moderate.empty?
    
    Comment.delete_all
  end
  
  def test_cannot_mass_assign_spam_status
    @comment = bad_comment(:spam_status => "ham")
    assert_not_equal "ham", @comment.spam_status
  end
end