$:.unshift ""

require 'test/unit'

begin
  # Load Rails environment if you can
  require File.join(File.dirname(__FILE__), '/../../../config/environment')
rescue LoadError
  # Load gem ActiveRecord if you can't
  require 'rubygems'
  gem 'activerecord'
  require 'active_record'
  
  RAILS_ROOT = File.dirname(__FILE__) 
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => "acts_as_url.sqlite3")

require File.join(File.dirname(__FILE__), '../init')
require File.join(File.dirname(__FILE__), 'schema')
require File.join(File.dirname(__FILE__), 'comment')
require File.join(File.dirname(__FILE__), 'entry')

Entry.create!(:title => "The Tale of Flight 815")

# To shut up whining about writing to the nil logger
class NilClass
  def debug(*args)
  end
end

class Test::Unit::TestCase # :nodoc:
  def link
    "<a href='http://lipsum.com/'>lorem ipsum</a>"
  end
  
  def good_comment(options = {})
    Comment.new({
      :author      => "Jack Shephard",
      :email       => "jack@st-sebastian.org",
      :body        => "If we don't live together, we're gonna die alone."
    }.merge(options))
  end
  
  def bad_comment(options = {})
    Comment.new({
      :author      => "Benjamin Linus",
      :email       => "leader@otherton.net",
      :body        => "Nice job. We're the good ones."
    }.merge(options))
  end
  
  def setup_prior_comments
    good_comment.save
    good_comment(:body => "Something different.").save
    bad_comment.save
    bad_comment.save
  end
  
  SPAM_COMMENTS = [
    {
      :author => 'osama187',
      :email => 'osama394@BinLaden.us',
      :url => 'www.mlx6.com',
      :body => 'alalah; <a href="http://www.frankharmer10k.com/">spain slots online frankharmer10k.com</a>; <a href="http://www.rogerperez.com">phentermine</a>; <a href="http://www.inca-trail-to-machupicchu.com">blackjack</a>; <a href="http://www.concordbridge.org/">gambling amchine jackpotter</a>; <a href="http://www.mysinglelesbianlife.com">lexapro</a>; <a href="http://www.pawneebillswildwestshow.com">blackjack</a>; <a href="http://www.onlinepokerlabs.de">pokerraume</a>; <a href="http://www.thegregmooreshow.com">life insurance</a>; <a href="http://www.rtlgrossepointe.org">slots</a>; <a href="http://www.cityinamber.com/">cityinamber.com combined auto and home insurance</a>; <a href="http://www.racetothestars.com">casino slots</a>; <a href="http://www.be-ga.net/">be-ga.net stacker 2 blackjack</a>; <a href="http://www.goe2007.com/">goe2007.com blackjack boats</a>; <a href="http://www.mlx6.com">paxil</a>; <a href="http://www.aiccn.org/">aiccn.org horace mann auto insurance</a>; <a href="http://www.smmmsa.com">buy rimonabant</a>; <a href="http://www.electrummel.org/">electrummel.org blackjack forward slash</a>; <a href="http://www.tschofenig.com">viagra</a>; <a href="http://www.consciouscultureblog.com/">consciouscultureblog.com simslots casino com</a>; <a href="http://www.u-can-sell-it.com">cheap car insurance</a>; <a href="http://www.isiskali.com">internet black jack</a>; <a href="http://www.bloggersnepal.com/">inside blackjack casino</a>; <a href="http://www.blogswana.org/">blogswana.org auto insurance hybrid vehicle</a>; '
    },
    {
      :author => 'assan90',
      :email => 'assan8@hassoni8.com',
      :url => 'buyaugmentinonline.blinklist.com/',
      :body => %q{a , <a href="http://buy-propecia-worldwide.wikidot.com">buy propecia</a>, <a href="http://buy-cheap-cialis-online.wikidot.com">buy cialis online</a>, <a href="http://cialisss.blinklist.com/">cialis levitra viagra,</a>, <a href="http://viagra-online-worldwide.blinklist.com/">viagra for sale</a>, <a href="http://buy-generic-viagra-worldwide.blinklist.com/">buy generic viagra</a>, <a href="http://buyaugmentinonline.blinklist.com/">augmentin</a>, <a href="http://byzoloftonline.blinklist.com/">zoloft</a>, <a href="http://augmentin-online-pharmacy.wikidot.com">augmentin</a>, <a href="http://acompliauspharmacy.blinklist.com/">acomplia</a>, <a href="http://buy-soma-worldwide.wikidot.com">buy soma</a>, <a href="http://buycialisonlineworldwide.blinklist.com/">generic cialis online</a>, <a href="http://buy-ultram-online-worldwide.blinklist.com/">buy ultram online</a>, <a href="http://buy-tramado-online-worldwide.wikidot.com">buy tramadol online</a>, }
    },
    {
      :author => 'cialis online',
      :email => '',
      :url => 'http://www.blogger.com/profile/11453893651597504089',
      :body => %q{<a href="http://www.theusapills.com/cialis" rel="nofollow">Order Cialis From The #1 Online Pharmacy</a><br>THE LOWEST CIALIS PRICE GUARANTEED<br>    Fast And Discreet Shipping Worldwide<br>    Free Medical Consultation And More<br>  <a href="http://www.theusapills.com/cialis" rel="nofollow">CLICK HERE TO ENTER<br>  http://www.theusapills.com/cialis</a>}
    },
    {
      :author => 'Charles Ford',
      :email => 'Joshua@internet.com',
      :url => 'http://www.av.com/',
      :body => %q{Very informative site. Good job. thins that excited you at 14:<br> <a target="_blank" class="ext" href="http://www.adobe.com" title="http://www.adobe.com">http://www.adobe.com</a> , <a href="http://www.yahoo.co.uk" rel="nofollow">thins<br> that excited you at 14</a> , <a href="http://www.panasonic.com" rel="nofollow">black girls on their mission</a>}
    },
    {
      :author => 'Welekneenia',
      :email => 'argenbrownou@yandex.ru',
      :url => 'http://replica-handbag.handbagreplicawatch.net/index.html',
      :body => %q{[URL=http://swiss-replica.handbagreplicawatch.net/swiss-replica-AND-canal.html]swiss replica AND canal[/URL] [URL=http://swiss-replica.handbagreplicawatch.net/swiss-replica-watch.html]swiss replica watch[/URL] [URL=http://replica-gucci-bag.handbagreplicawatch.net/gucci-messenger-bag-replica.html]gucci messenger bag replica[/URL] Swiss Replica Rolex is made of the highest quality materials. [URL=http://prada-replica-handbag.handbagreplicawatch.net/replica-prada-mens.html]replica prada mens[/URL] [URL=http://prada-replica-handbag.handbagreplicawatch.net/prada-replica-sport.html]prada replica sport[/URL] The fact is that only a few people are able to afford it. [URL=http://prada-replica-handbag.handbagreplicawatch.net/replica-prada-bags.html]replica prada bags[/URL] [URL=http://replica-oakley.handbagreplicawatch.net/replica-oakley-watch.html]replica oakley watch[/URL] They also specialize on luxury necklaces and bag replicas. [URL=http://tiffany-replica.handbagreplicawatch.net/replica-tiffany-and-co.html]replica tiffany and co[/URL] [URL=http://panerai-replica.handbagreplicawatch.net/panerai-radiomir-replica.html]panerai radiomir replica[/URL] All purchased in the last six months or so. [URL=http://replica-watch.handbagreplicawatch.net/chopard-replica-watch.html]chopard replica watch[/URL] [URL=http://replica-watch.handbagreplicawatch.net/buy-a-replica-watch.html]buy a replica watch[/URL] [URL=http://replica-bag.handbagreplicawatch.net/fendi-spy-bag-replica.html]fendi spy bag replica[/URL] The styling of the watches is the same as the originals. [URL=http://replica-bag.handbagreplicawatch.net/bag-diaper-kate-replica-spade.html]bag diaper kate replica spade[/URL] [URL=http://replica-watch.handbagreplicawatch.net/replica-citizen-watch.html]replica citizen watch[/URL]}
    },
    {
      :author => "Fearacreext",
      :email => "iledygoro@yandex.ua",
      :url => "http://www.nemogs.com/e/",
      :body => %q{Hey sweetie, you wanna attract  chick at the club? Try Ultra Allure pheromones! -Attract women of all ages -Excite women before even talking to them -Make women want to sleep with you immediately -Millions of men are already using them! -Proven to work! [URL=http://www.nemogs.com/r/]They are having a huge sale right now, check out the site for all the info.[/URL] [URL=http://www.nemogs.com/r/]Everybody I know has got a couple bottles of this stuff, it simply works! Don't be the only one left behind![/URL] Product here - http://nemogs.com/r/index.php}  
    },
    {
      :author => "Tweerasiaro",
      :email => "iledygoro@yandex.ru",
      :url => "http://www.nemogs.com",
      :body => %q{Hey bro, nice talking to you the other day. Thought you would want to check this out, I got some for myself cause they were on sale, you should check out the site, I added the link below.
        Steel Package: 10 Patches reg $79.95 Now $49.95! Free shipping too! Silver Package: 25 Patches reg $129.95, Now $99.95! Free shipping and free exercise manual included! Gold Package: 40 Patches reg $189.95, Now $149.95! Free shipping and free exercise manual included! Platinum Package: 65 Patches reg $259.95, Now $199.95! Free shipping and free exercise manual included! (Best Value!) I know like 10 guys who have already stocked up on these. [URL=http://www.nemogs.com]Here's the link to check out bro![/URL] Talk to you soon! Product here - http://www.nemogs.com}
    }
  ]
  
  HAM_COMMENTS = [
    {
      :author => 'Dan Cedarholm',
      :email => '',
      :url => 'http://www.simplebits.com/',
      :body => %q{Nicely said, Simon. I have a bit of a knee-jerk reaction to comments -- when I'm flooded I curse them, but like you, I feel the comments add far more value than my posts. So I feel more optimistic after reading your thoughts on the state of things. Something that didn't register until now is that MT's variation on your excellent redirect solution completely hides the URL, killing the "signature" aspect of a comment. I'm thinking your /redirect/?http://www.site.com is a nicer solution -- it's certainly a good way of verifying a frequent poster.}
    },
    {
      :author => 'Voyagerfan5761',
      :email => '',
      :url => 'http://voyagerfan5761.blogspot.com/',
      :body => %q{I like this post. The algorithm you've put together here is quite intriguing, though I'm a bit worried about a couple of the filter rules. For instance, my URL is more than 30 characters, simply because I'm using a subdomain at a free blog host. Does that necessarily mean I'm a spammer? No. I've been thinking about getting my own domain, but -- and this is where it gets interesting -- my ideal registered domain would be 7+3+1+14+1+3+1=30 characters exactly, including http:// and a trailing slash. I suppose I should be thankful that you don't seem to be filtering out *.blogspot.com completely, as I've seen suggested elsewhere on the 'Net. Regarding your filtering URLs containing .html, ?, or &, does that apply to the comment body or just the URL field? Some blog platforms and content sites (PC World for example) end their pages in .html, and/or use query strings to retrieve the correct page, so I'm just curious about that.}
    },
    {
      :author => 'Paul Decowski',
      :email => '',
      :url => '',
      :body => %q{Polish? Never heard of a word with 5 consonants in a row! Wstrzyknąć — to inject.}
    },
    {
      :author => 'Jamis Buck',
      :email => '',
      :url => '',
      :body => %q{@Steve, for #1, I did the following (more or less) with Capistrano’s gateway class, which runs in a thread but must allow other threads to begin connections through the gateway: <pre></code>require 'thread' @mutex = Mutex.new Thread.new do loop do @mutex.synchronize { @gateway.process(0.1) } end end @mutex.synchronize do @gateway.forward.local(1234, "remote-host", 22) end c = Net::SSH.start("localhost", "user", :port => 1234)</code</pre> In other words, run the event loop manually (by looping and calling Net::SSH::Connection::Session#process manually), and wrap the #process call in a mutex. Then, any time you need to access the session outside of a thread, employ the mutex again. As for #2, which “require” is failing?}
    }
  ]
  
  # From Active Support
  def assert_difference(expressions, difference = 1, message = nil, &block)
    expression_evaluations = Array(expressions).collect{ |expression| lambda { eval(expression, block.send(:binding)) } }

    original_values = expression_evaluations.inject([]) { |memo, expression| memo << expression.call }
    yield
    expression_evaluations.each_with_index do |expression, i|
      assert_equal original_values[i] + difference, expression.call, message
    end
  end
  
  def assert_no_difference(expressions, message = nil, &block)
    assert_difference expressions, 0, message, &block
  end
end