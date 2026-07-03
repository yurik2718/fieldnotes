class AnalyticsSubscriber
  TRACKED_EVENTS = %w[ essay.viewed field.viewed ]

  def emit(event)
    PageView.create!(event: event[:name], payload: event[:payload])
  rescue => e
    Rails.logger.error("AnalyticsSubscriber error: #{e.message}")
  end
end
