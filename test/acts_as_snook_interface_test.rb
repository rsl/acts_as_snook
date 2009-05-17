require "test/test_helper"

class ActsAsSnookInterfaceTest < Test::Unit::TestCase
  def test_marks_spam_as_spam
    SPAM_COMMENTS.each do |comment_attributes|
      @comment = Comment.new(comment_attributes)
      @comment.valid?
      assert_equal "spam", @comment.spam_status
    end
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
    @comment = Comment.new(MODERATE_COMMENT)
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
  
  def test_does_not_save_if_snook_credits_lower_than_negative_ten
    @comment = Comment.new(SPAM_COMMENTS.first)
    @comment.valid?
    assert @comment.snook_credits < -10
    assert !@comment.save
  end
  
  def test_ham_exclamation_point_updates_spam_status_to_ham
    @comment = Comment.create!(SPAM_COMMENTS[2])
    assert @comment.spam?
    @comment.ham!
    assert @comment.ham?
    @comment.destroy
  end
  
  def test_resaving_comment_with_changed_status_does_not_mark_as_spam
    @comment = bad_comment
    @comment.save!
    @comment.update_attribute(:spam_status, "ham")
    assert @comment.ham?
    @comment.save
    @comment.destroy
  end
  
  def test_saving_ham_comment_increments_ham_comment_count
    assert_difference "Entry.find(:first).ham_comments_count", 1 do
      @comment = Entry.find(:first).comments.create!(HAM_COMMENTS[0])
    end
    @comment.destroy
  end
  
  def test_saving_spam_comment_does_not_increment_ham_comment_count
    assert_no_difference "Entry.find(:first).ham_comments_count" do
      @comment = Entry.find(:first).comments.create!(SPAM_COMMENTS[2])
    end
    @comment.destroy
  end
  
  def test_ham_bang_increments_ham_comment_count
    @comment = Entry.find(:first).comments.create!(SPAM_COMMENTS[2])
    assert_difference "Entry.find(:first).ham_comments_count", 1 do
      @comment.ham!
    end
    @comment.destroy
  end
  
  def test_spam_bang_decrements_ham_comment_count
    @comment = Entry.find(:first).comments.create!(HAM_COMMENTS[0])
    assert_difference "Entry.find(:first).ham_comments_count", -1 do
      @comment.spam!
    end
    @comment.destroy
  end
  
  def test_updating_spam_status_to_ham_increments_ham_comment_count
    @comment = Entry.find(:first).comments.create!(SPAM_COMMENTS[2])
    assert_difference "Entry.find(:first).ham_comments_count", 1 do
      @comment.spam_status = "ham"
      @comment.save!
    end
    @comment.destroy
  end
  
  def test_updating_spam_status_to_spam_decrements_ham_comment_count
    @comment = Entry.find(:first).comments.create!(HAM_COMMENTS[0])
    assert_difference "Entry.find(:first).ham_comments_count", -1 do
      @comment.spam_status = "spam"
      @comment.save!
    end
    @comment.destroy
  end
  
  def test_updating_moderate_spam_status_to_spam_does_not_decrement_ham_comments_count
    @comment = Entry.find(:first).comments.create!(MODERATE_COMMENT)
    @comment.save!
    assert_no_difference("Entry.find(:first).ham_comments_count") do
      @comment.spam_status = "spam"
      @comment.save!
    end
    @comment.destroy
  end
  
  def test_destroying_ham_comment_decrements_ham_comment_count
    @comment = Entry.find(:first).comments.create!(HAM_COMMENTS[0])
    assert_difference "Entry.find(:first).ham_comments_count", -1 do
      @comment.destroy
    end
  end
  
  def test_destroying_spam_comment_does_not_decrement_ham_comment_count
    @comment = Entry.find(:first).comments.create!(SPAM_COMMENTS[2])
    assert_no_difference "Entry.find(:first).ham_comments_count" do
      @comment.destroy
    end
  end
  
  def test_destroying_moderate_comment_does_not_decrement_ham_comment_count
    @comment = Entry.find(:first).comments.create!(MODERATE_COMMENT)
    assert_no_difference "Entry.find(:first).ham_comments_count" do
      @comment.destroy
    end
  end
end