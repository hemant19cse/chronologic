class Chronologic::Service::Feed

  def self.create(timeline_key, options={})
    fetch_subevents = options[:fetch_subevents]
    count = options[:per_page] || 20
    start = options[:page] || nil

    feed = new(timeline_key, count, start, fetch_subevents)
  end

  attr_accessor :timeline_key, :per_page, :start, :subevents
  attr_accessor :next_page, :count

  def initialize(timeline_key, per_page=20, start=nil, subevents=false)
    self.timeline_key = timeline_key
    self.per_page = per_page
    self.start = start
    self.subevents = subevents
  end

  def items
    return @items if @items

    set_next_page
    set_count

    events = schema.fetch_timelines(timeline_key, per_page, start)
    subevents = schema.fetch_timelines(events.map { |e| e.key }, per_page, start)

    all_events = schema.fetch_objects([events, subevents].flatten)
    @items = schema.reify_timeline(all_events)
  end

  def set_count
    self.count = schema.timeline_count(timeline_key)
  end

  def set_next_page
    current = schema.timeline_events_for(
      timeline_key,
      :per_page => per_page + 1,
      :page => start
    )

    if current.length == (per_page + 1)
      self.next_page = current.keys.last
    else
      self.next_page = nil
    end
  end

  # Private: easier access to the Chronologic schema
  def schema
    Chronologic.schema
  end

end

