require "test/test_helper"

class ActsAsSnookInternalsTest < Test::Unit::TestCase
  def setup
    @comment = Comment.new
    # This happens internally but needs to be manually done
    # because these tests are being run individually here
    @comment.instance_variable_set("@snook_credits", 0)
  end
  
  def test_comment_gains_credits_if_no_link_in_body
    @comment.body = "no link"
    @comment.send :calculate_snook_for_body_links
    assert_equal +2, @comment.snook_credits
  end
  
  def test_comment_gains_credits_if_one_link_in_body
    @comment.body = link
    @comment.send :calculate_snook_for_body_links
    assert_equal +2, @comment.snook_credits
  end
  
  def test_comment_gains_credits_if_two_links_in_body
    @comment.body = link + link
    @comment.send :calculate_snook_for_body_links
    assert_equal +2, @comment.snook_credits
  end
  
  def test_comment_loses_credit_per_link_if_more_than_two_links_in_body
    @comment.body = link + link + link
    @comment.send :calculate_snook_for_body_links
    assert_equal -3, @comment.snook_credits
  end
  
  def test_comment_gains_credits_if_body_length_over_20_characters_without_links
    @comment.body = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Morbi fringilla semper sem. Proin sed eros."
    @comment.send :calculate_snook_for_body_length
    assert_equal +2, @comment.snook_credits
  end
  
  def test_comment_credits_do_not_change_if_body_length_over_20_characters_with_links
    @comment.body = "<a href='http://lipsum.com'>Lorem ipsum</a> dolor sit amet, consectetuer adipiscing elit. Morbi fringilla semper sem."
    @comment.send :calculate_snook_for_body_length
    assert_equal 0, @comment.snook_credits
  end
  
  def test_comment_loses_credits_if_body_length_under_20_characters
    @comment.body = "Lorem ipsum."
    @comment.send :calculate_snook_for_body_length
    assert_equal -1, @comment.snook_credits
  end
  
  def test_comment_gains_credit_per_prior_approved_comment
    setup_prior_comments
    @comment = good_comment
    @comment.instance_variable_set("@snook_credits", 0)
    @comment.send :calculate_snook_for_previous_comments
    assert_equal +2, @comment.snook_credits
    Comment.delete_all
  end
  
  def test_comment_loses_credit_per_prior_spam_comment
    setup_prior_comments
    @comment = bad_comment
    @comment.instance_variable_set("@snook_credits", 0)
    @comment.send :calculate_snook_for_previous_comments
    assert_equal -2, @comment.snook_credits
    Comment.delete_all
  end
  
  def test_comment_loses_credit_for_each_spam_word_in_body
    @comment.body = "viagra, casino, poker, cialis"
    @comment.send :calculate_snook_for_spam_words
    assert_equal -4, @comment.snook_credits
  end
  
  def test_comment_loses_credit_for_each_spam_word_in_url
    @comment.url = "http://viagra-online.com"
    @comment.send :calculate_snook_for_spam_words
    assert_equal -2, @comment.snook_credits
  end
  
  def test_comment_loses_credit_per_suspect_url_in_body
    @comment.body = "<a href='http://foo.com/page.html'>foo</a> <a href='http://bar.info/'>bar</a>"
    @comment.send :calculate_snook_for_suspect_url
    assert_equal -2, @comment.snook_credits
  end
  
  def test_comment_loses_credit_per_suspect_url_in_url
    @comment.url = "http://foo.com/?bar=baz"
    @comment.send :calculate_snook_for_suspect_url
    assert_equal -1, @comment.snook_credits
  end
  
  def test_comment_loses_credit_per_suspect_tld_in_body
    @comment.body = "<a href='http://foo.de'>foo</a> <a href='http://bar.pl/'>bar</a> <a href='http://baz.cn/quux'></a>"
    @comment.send :calculate_snook_for_suspect_tld
    assert_equal -3, @comment.snook_credits
  end
  
  def test_comment_loses_credit_per_suspect_tld_in_url
    @comment.url = "http://foo.de"
    @comment.send :calculate_snook_for_suspect_tld
    assert_equal -1, @comment.snook_credits
  end
  
  def test_comment_credits_do_not_change_if_url_shorter_than_30_characters
    @comment.url = "http://acceptable-length.com/"
    @comment.send :calculate_snook_for_url_length
    assert_equal 0, @comment.snook_credits
  end
  
  def test_comment_loses_credit_if_url_longer_than_30_characters
    @comment.url = "http://i-have-a-long-url-because-i-am-spamming-keywords-in-it.com"
    @comment.send :calculate_snook_for_url_length
    assert_equal -1, @comment.snook_credits
  end
  
  def test_comment_does_not_lose_credit_if_body_does_not_start_with_lame_word
    @comment.body = "I am an acceptable comment"
    @comment.send :calculate_snook_for_lame_body_start
    assert_equal 0, @comment.snook_credits
  end
  
  def test_comment_loses_credit_if_body_starts_with_lame_word
    @comment.body = "Interesting post."
    @comment.send :calculate_snook_for_lame_body_start
    assert_equal -10, @comment.snook_credits
  end
  
  def test_comment_credits_do_not_change_if_no_http_in_author
    @comment.author = "Jack Shepherd"
    @comment.send :calculate_snook_for_author_link
    assert_equal 0, @comment.snook_credits
  end
  
  def test_comment_loses_credit_per_http_in_author
    @comment.author = "<a href='http://foo.com/'>http://foo.com/</a>"
    @comment.send :calculate_snook_for_author_link
    assert_equal -4, @comment.snook_credits
  end
  
  def test_comment_credits_do_not_change_if_body_does_not_match_previous_comment
    @comment.body = "Unique by default."
    @comment.send :calculate_snook_for_matching_previous_body
    assert_equal 0, @comment.snook_credits
  end
  
  def test_comment_loses_credit_per_body_matching_previous_comment
    setup_prior_comments
    @comment = bad_comment
    @comment.instance_variable_set("@snook_credits", 0)
    @comment.send :calculate_snook_for_matching_previous_body
    assert_equal -2, @comment.snook_credits
    Comment.delete_all
  end
  
  def test_comment_loses_credit_per_run_of_5_consonants
    @comment.body = "bvrrsd trnkdattlf"
    @comment.send :calculate_snook_for_consonant_runs
    assert_equal -3, @comment.snook_credits
  end
  
  def test_comment_credits_do_not_change_if_no_bbcode
    @comment.body = "This is good text. It contains no harmful, hackful bbcode"
    @comment.send :calculate_snook_for_bbcode
    assert_equal 0, @comment.snook_credits
  end
  
  def test_comment_loses_credit_per_instance_of_bbcode
    @comment.body = "[URL=http://foo.com]foo[/URL] and [URL=http://bar.com]bar[/URL]"
    @comment.send :calculate_snook_for_bbcode
    assert_equal -2, @comment.snook_credits
  end
end
