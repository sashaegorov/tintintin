require File.dirname(__FILE__) + '/base'

describe Post do
  before do
    @post = Post.new
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
    Post.filter(:title => 'hello').first.body.should == 'world'
  end

  it "generates a slug from the title (but saved to db on first pass so that url never changes)" do
    Post.make_slug("RestClient 0.8").should == 'restclient_08'
    Post.make_slug("Rushmate, rush + TextMate").should == 'rushmate_rush_textmate'
    Post.make_slug("Object-Oriented File Manipulation").should == 'objectoriented_file_manipulation'
  end

  it 'returns tag list' do
    posts = [{:body=>"code", :tags=>nil, :title=>"tag1,tag2"},
             {:body=>"code", :tags=>nil, :title=>"tag1,tag2"},
             {:body=>"code", :tags=>"tag1,tag2", :title=>"hey there"},
             {:body=>"asdasdasdad", :tags=>"web, another", :title=>"web"},
             {:body=>"code", :tags=>"tag1, tag2", :title=>"all rigth"},
             {:body=>"code", :tags=>"tag1, tag2", :title=>"all suppy rigth"},
             {:body=>"code", :tags=>"tag, tagga", :title=>"un post de prueba"} ]
    posts.each { |p| Post.create p }

    Post.tags.should == ["tag1", "tag2", "web", "another", "tag2",
                         "tag", "tagga"]
  end
end
