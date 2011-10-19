require 'active_support/concern'
require 'active_support/core_ext/hash'
require 'chronologic/event' # HAX

class Chronologic::Service::Event
  include Chronologic::Event::Behavior
  include Chronologic::Event::State

  def self.from_columns(columns)
    from_attributes(
      :data      => json_decode(columns["data"], {}),
      :objects   => json_decode(columns["objects"], {}),
      :timelines => json_decode(columns["timelines"], []),
      :token     => columns.fetch("token", '')
    )
  end
  # Total HAX
  class <<self
    alias_method :load_from_columns, :from_columns
  end

  def to_columns
    {
      "token"     => token,
      "data"      => json_encode(data),
      "objects"   => json_encode(objects),
      "timelines" => json_encode(timelines)
    }
  end

  def to_client_encoding
    {
      "key" => key,
      "data" => data,
      "objects" => objects,
      "timelines" => timelines,
      "subevents" => subevents.map(&:to_client_encoding)
    }
  end

  def set_token(force_timestamp=false)
    timestamp = if force_timestamp
      force_timestamp
    else
      Time.now.utc.tv_sec
    end
    self.token = [timestamp, key].join('_')
  end

end

