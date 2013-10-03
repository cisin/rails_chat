require "spec_helper"

describe RailsChat::FayeExtension do
  before(:each) do
    RailsChat.reset_config
    @faye = RailsChat::FayeExtension.new
    @message = {"channel" => "/meta/subscribe", "ext" => {}}
  end

  it "adds an error on an incoming subscription with a bad signature" do
    @message["subscription"] = "hello"
    @message["ext"]["rails_chat_signature"] = "bad"
    @message["ext"]["rails_chat_timestamp"] = "123"
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should eq("Incorrect signature.")
  end

  it "has no error when the signature matches the subscription" do
    sub = RailsChat.subscription(:channel => "hello")
    @message["subscription"] = sub[:channel]
    @message["ext"]["rails_chat_signature"] = sub[:signature]
    @message["ext"]["rails_chat_timestamp"] = sub[:timestamp]
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should be_nil
  end

  it "has an error when signature just expired" do
    RailsChat.config[:signature_expiration] = 1
    sub = RailsChat.subscription(:timestamp => 123, :channel => "hello")
    @message["subscription"] = sub[:channel]
    @message["ext"]["rails_chat_signature"] = sub[:signature]
    @message["ext"]["rails_chat_timestamp"] = sub[:timestamp]
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should eq("Signature has expired.")
  end

  it "has an error when trying to publish to a custom channel with a bad token" do
    RailsChat.config[:secret_token] = "good"
    @message["channel"] = "/custom/channel"
    @message["ext"]["rails_chat_token"] = "bad"
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should eq("Incorrect token.")
  end

  it "raises an exception when attempting to call a custom channel without a secret_token set" do
    @message["channel"] = "/custom/channel"
    @message["ext"]["rails_chat_token"] = "bad"
    lambda {
      message = @faye.incoming(@message, lambda { |m| m })
    }.should raise_error("No secret_token config set, ensure rails_chat.yml is loaded properly.")
  end

  it "has no error on other meta calls" do
    @message["channel"] = "/meta/connect"
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should be_nil
  end

  it "should not let message carry the RailsChat token after server's validation" do
    RailsChat.config[:secret_token] = "good"
    @message["channel"] = "/custom/channel"
    @message["ext"]["rails_chat_token"] = RailsChat.config[:secret_token]
    message = @faye.incoming(@message, lambda { |m| m })
    message['ext']["rails_chat_token"].should be_nil
  end

end
