
require File.dirname(__FILE__) + '/base'

describe Scanty::Post do
  before do
    @post = Scanty::Post.new
  end

  it "has a url in simplelog format: /past/2008/10/17/my_post/" do
    @post.created_at = '2008-10-22'
    @post.slug = "my_post"
    @post.url.should == '/past/2008/10/22/my_post/'
  end

  it "has a full url including the Blog.url_base" do
    @post.created_at = '2008-10-22'
    @post.slug = "my_post"
    Blog.stub!(:url_base).and_return('http://blog.example.com/')
    @post.full_url.should == 'http://blog.example.com/past/2008/10/22/my_post/'
  end

  it "produces html from the textile body" do
    @post.body = "* Bullet"
    @post.body_html.should == "<ul>\n\t<li>Bullet</li>\n</ul>"
  end

  it "makes the tags into links to the tag search" do
    @post.tags = "one, two"
    @post.linked_tags.should ==
      "<a href='/past/tags/one'>one</a>&nbsp;<a href='/past/tags/two'>two</a>"
  end

  it "can save itself (primary key is set up)" do
    @post.title = 'hello'
    @post.body = 'world'
    @post.save
    Scanty::Post.filter(:title => 'hello').first.body.should == 'world'
  end

  it "generates a slug from the title (but saved to db on first pass so that url never changes)" do
    Scanty::Post.make_slug("RestClient 0.8").should == 'restclient_08'
    Scanty::Post.make_slug("Rushmate, rush + TextMate").should == 'rushmate_rush_textmate'
    Scanty::Post.make_slug("Object-Oriented File Manipulation").should == 'objectoriented_file_manipulation'
  end

  describe 'tags method' do
    before(:each) do
      #OPTIMIZE sequel should have cleaner ways of accomplish this
      Scanty::Post.all { |p| p.destroy }
    end

    it 'should not return nil tags' do
      posts = [{:body=>"code", :tags=>nil, :title=>"only nil tags"},
               {:body=>"code", :tags=>"tag1,tag2", :title=>"non nil tags"} ]
      posts.each { |p| Scanty::Post.create p }

      Scanty::Post.tags.should_not include(nil)
    end

    it 'should not return empty string tags' do
      posts = [{:body=>"code", :tags=>"", :title=>"empty string tags"},
               {:body=>"code", :tags=>"tag1, tag2", :title=>"non empty  tags"} ]
      posts.each { |p| Scanty::Post.create p }

      Scanty::Post.tags.should_not include("")
    end

    it 'should return tags clean of spaces' do
      Scanty::Post.create({ :title=>"spaced tags", :body=>"code",
                            :tags=>" before,after , around "})

      Scanty::Post.tags.should == ["after", "around", "before"]
    end

    it 'should not repeat tags' do
      posts = [ {:body=>"code", :tags=>"tag1, tag2", :title=>"first occurence tags"},
                {:body=>"code", :tags=>"tag1, tag2, tag3", :title=>"repeated tags"} ]
      posts.each { |p| Scanty::Post.create p }

      Scanty::Post.tags.should == ["tag1", "tag2", "tag3"]
    end

    it 'returns a sorted tag list' do
      posts = [{:body=>"code", :tags=>"", :title=>"empty string tags"},
               {:body=>"code", :tags=>nil, :title=>"only nil tags"},
               {:body=>"code", :tags=>"1, 2", :title=>"numbered tags"},
               {:body=>"code", :tags=>"aa, bb", :title=>"lettered tags"},
               {:body=>"code", :tags=>"tag1, tag2", :title=>"first occurence tags"},
               {:body=>"code", :tags=>"tag1, tag2, tag3", :title=>"repeated tags"} ]
      posts.each { |p| Scanty::Post.create p }

      Scanty::Post.tags.should == ["1", "2", "aa", "bb","tag1", "tag2", "tag3"]
    end

  end
end
