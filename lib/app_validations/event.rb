class EventValidator < ActiveModel::Validator
  def validate(event)
    unless (weekly_event = event.weekly_event).nil? ||
           (date = event.date).nil?
      unless date.wday == (wewd = weekly_event.week_day)
        event.errors[:date] <<
          ( options[:message] ||
            I18n.t('errors.messages.unexpected_week_day',
                   :week_day => I18n.t('date.day_names')[wewd]) )
      end
    end
  end
end