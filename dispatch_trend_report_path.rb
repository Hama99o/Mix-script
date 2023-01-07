def dispatch_trend_report_path(trend_report_id)
  ActionCable.server.broadcast "delayed_link_channel",
    { content: { model_id: "trend_report_#{trend_report_id}", path: trend_report_path(trend_report_id) } }
  Rails.logger.info "Trend Report ##{trend_report_id} exported"
end