Rails.application.config.after_initialize do
  Rails.event.subscribe(AnalyticsSubscriber.new) do |event|
    AnalyticsSubscriber::TRACKED_EVENTS.include?(event[:name])
  end
end
