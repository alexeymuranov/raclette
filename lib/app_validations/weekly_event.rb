class WeeklyEventValidator < ActiveModel::Validator
  def validate(weekly_event)
    latest_allowed_end_date = weekly_event.start_on + 1.year
    unless weekly_event.end_on <= latest_allowed_end_date
      weekly_event.errors[:end_on] <<
        ( options[:message] ||
          I18n.t('errors.messages.date_before_or_on',
                 :date => I18n.l(latest_allowed_end_date)) )
    end
  end
end
