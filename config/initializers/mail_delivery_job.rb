# frozen_string_literal: true

return if ENV["RAILS_WEB"]

ActionMailer::MailDeliveryJob.class_eval do
  discard_on ActiveJob::DeserializationError
end
