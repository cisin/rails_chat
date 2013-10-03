module RailsChat
  module ViewHelpers
    # Publish the given data or block to the client by sending
    # a Net::HTTP POST request to the Faye server. If a block
    # or string is passed in, it is evaluated as JavaScript
    # on the client. Otherwise it will be converted to JSON
    # for use in a JavaScript callback.
    def publish_to(channel, data = nil, &block)
      RailsChat.publish_to(channel, data || capture(&block))
    end

    # Subscribe the client to the given channel. This generates
    # some JavaScript calling RailsChat.sign with the subscription
    # options.
    def subscribe_to(channel)
      subscription = RailsChat.subscription(:channel => channel)
      content_tag "script", :type => "text/javascript" do
        raw("RailsChat.sign(#{subscription.to_json});")
      end
    end
  end
end
