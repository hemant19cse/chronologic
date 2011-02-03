require "active_support/core_ext/class"
require "will_paginate/array"
require "httparty"

class Chronologic::Client

  include HTTParty

  cattr_accessor :instance

  def initialize(host)
    self.class.default_options[:base_uri] = host
  end

  def record(object_key, data)
    body = {"object_key" => object_key, "data" => data}
    resp = self.class.post("/object", :body => body)

    raise Chronologic::ServiceError.new(resp) if resp.code == 500
    raise Chronologic::Exception.new("Error creating new record") unless resp.code == 201
    true
  end

  def unrecord(object_key)
    resp = self.class.delete("/object/#{object_key}")

    raise Chronologic::ServiceError.new(resp) if resp.code == 500
    raise Chronologic::Exception.new("Error removing record") unless resp.code == 204
    true
  end

  def subscribe(subscriber_key, timeline_key)
    body = {
      "subscriber_key" => subscriber_key,
      "timeline_key" => timeline_key
    }
    resp = self.class.post("/subscription", :body => body)

    raise Chronologic::ServiceError.new(resp) if resp.code == 500
    raise Chronologic::Exception.new("Error creating subscription") unless resp.code == 201
    true
  end

  def unsubscribe(subscriber_key, timeline_key)
    resp = self.class.delete("/subscription/#{subscriber_key}/#{timeline_key}")

    raise Chronologic::ServiceError.new(resp) if resp.code == 500
    raise Chronologic::Exception.new("Error removing subscription") unless resp.code == 204
    true
  end

  def publish(event)
    resp = self.class.post("/event", :body => event.to_transport)

    raise Chronologic::ServiceError.new(resp) if resp.code == 500
    raise Chronologic::Exception.new("Error publishing event") unless resp.code == 201
    url = resp.headers["Location"]
    url
  end

  def unpublish(event_key, uuid)
    resp = self.class.delete("/event/#{event_key}/#{uuid}")

    raise Chronologic::ServiceError.new(resp) if resp.code == 500
    raise Chronologic::Exception.new("Error unpublishing event") unless resp.code == 204
    true
  end

  def timeline(timeline_key, options={})
    resp = if options.length > 0
             self.class.get("/timeline/#{timeline_key}", :query => options)
           else
             self.class.get("/timeline/#{timeline_key}")
           end

    raise Chronologic::ServiceError.new(resp) if resp.code == 500
    raise Chronologic::Exception.new("Error fetching timeline") unless resp.code == 200
    {
      "feed" => resp["feed"],
      "count" => resp["count"],
      "next_page" => resp["next_page"],
      "items" => resp["feed"].
        map { |v| Chronologic::Event.new(v) }.
        paginate(:total_entries => resp["count"])
    }
  end

end

