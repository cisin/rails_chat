require "spec_helper"

describe RailsChat do
  before(:each) do
    RailsChat.reset_config
  end

  it "defaults server to nil" do
    RailsChat.config[:server].should be_nil
  end

  it "defaults signature_expiration to nil" do
    RailsChat.config[:signature_expiration].should be_nil
  end

  it "defaults subscription timestamp to current time in milliseconds" do
    time = Time.now
    Time.stub!(:now).and_return(time)
    RailsChat.subscription[:timestamp].should eq((time.to_f * 1000).round)
  end

  it "loads a simple configuration file via load_config" do
    RailsChat.load_config("spec/fixtures/rails_chat.yml", "production")
    RailsChat.config[:server].should eq("http://example.com/faye")
    RailsChat.config[:secret_token].should eq("PRODUCTION_SECRET_TOKEN")
    RailsChat.config[:signature_expiration].should eq(600)
  end

  it "raises an exception if an invalid environment is passed to load_config" do
    lambda {
      RailsChat.load_config("spec/fixtures/rails_chat.yml", :test)
    }.should raise_error ArgumentError
  end

  it "includes channel, server, and custom time in subscription" do
    RailsChat.config[:server] = "server"
    subscription = RailsChat.subscription(:timestamp => 123, :channel => "hello")
    subscription[:timestamp].should eq(123)
    subscription[:channel].should eq("hello")
    subscription[:server].should eq("server")
  end

  it "does a sha1 digest of channel, timestamp, and secret token" do
    RailsChat.config[:secret_token] = "token"
    subscription = RailsChat.subscription(:timestamp => 123, :channel => "channel")
    subscription[:signature].should eq(Digest::SHA1.hexdigest("tokenchannel123"))
  end

  it "formats a message hash given a channel and a string for eval" do
    RailsChat.config[:secret_token] = "token"
    RailsChat.message("chan", "foo").should eq(
      :ext => {:rails_chat_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :eval => "foo"
      }
    )
  end

  it "formats a message hash given a channel and a hash" do
    RailsChat.config[:secret_token] = "token"
    RailsChat.message("chan", :foo => "bar").should eq(
      :ext => {:rails_chat_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :data => {:foo => "bar"}
      }
    )
  end

  it "publish message as json to server using Net::HTTP" do
    RailsChat.config[:server] = "http://localhost"
    message = 'foo'
    form = mock(:post).as_null_object
    http = mock(:http).as_null_object

    Net::HTTP::Post.should_receive(:new).with('/').and_return(form)
    form.should_receive(:set_form_data).with(message: 'foo'.to_json)

    Net::HTTP.should_receive(:new).with('localhost', 80).and_return(http)
    http.should_receive(:start).and_yield(http)
    http.should_receive(:request).with(form).and_return(:result)

    RailsChat.publish_message(message).should eq(:result)
  end

  it "it should use HTTPS if the server URL says so" do
    RailsChat.config[:server] = "https://localhost"
    http = mock(:http).as_null_object

    Net::HTTP.should_receive(:new).and_return(http)
    http.should_receive(:use_ssl=).with(true)

    RailsChat.publish_message('foo')
  end

  it "it should not use HTTPS if the server URL says not to" do
    RailsChat.config[:server] = "http://localhost"
    http = mock(:http).as_null_object

    Net::HTTP.should_receive(:new).and_return(http)
    http.should_receive(:use_ssl=).with(false)

    RailsChat.publish_message('foo')
  end

  it "raises an exception if no server is specified when calling publish_message" do
    lambda {
      RailsChat.publish_message("foo")
    }.should raise_error(RailsChat::Error)
  end

  it "publish_to passes message to publish_message call" do
    RailsChat.should_receive(:message).with("chan", "foo").and_return("message")
    RailsChat.should_receive(:publish_message).with("message").and_return(:result)
    RailsChat.publish_to("chan", "foo").should eq(:result)
  end

  it "has a Faye rack app instance" do
    RailsChat.faye_app.should be_kind_of(Faye::RackAdapter)
  end

  it "says signature has expired when time passed in is greater than expiration" do
    RailsChat.config[:signature_expiration] = 30*60
    time = RailsChat.subscription[:timestamp] - 31*60*1000
    RailsChat.signature_expired?(time).should be_true
  end

  it "says signature has not expired when time passed in is less than expiration" do
    RailsChat.config[:signature_expiration] = 30*60
    time = RailsChat.subscription[:timestamp] - 29*60*1000
    RailsChat.signature_expired?(time).should be_false
  end

  it "says signature has not expired when expiration is nil" do
    RailsChat.config[:signature_expiration] = nil
    RailsChat.signature_expired?(0).should be_false
  end
end
