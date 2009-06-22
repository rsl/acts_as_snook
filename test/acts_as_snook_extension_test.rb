require "test/test_helper"

class ActsAsSnookExtensionTest < Test::Unit::TestCase
  # This test suite is for nothing more than testing the extension
  # of acts_as_snook with customized rules.
  
  def test_extended_rules_override_ham_status
    attributes = HAM_COMMENTS.first
    @extended = ExtendedComment.new(attributes)
    @extended.valid?
    assert @extended.spam?
  end
  
  def test_extended_rules_override_spam_status
    attributes = SPAM_COMMENTS[3]
    @extended = ExtendedComment.new(attributes)
    @extended.valid?
    assert @extended.ham?
  end
  
  def test_forced_spam_status
    attributes = HAM_COMMENTS[1].merge(:author => "spambot")
    @extended = ExtendedComment.new(attributes)
    @extended.valid?
    assert @extended.spam?
  end
  
  def test_forced_ham_status
    attributes = SPAM_COMMENTS[1].merge(:author => "hambot")
    @extended = ExtendedComment.new(attributes)
    @extended.valid?
    assert @extended.ham?
  end
end