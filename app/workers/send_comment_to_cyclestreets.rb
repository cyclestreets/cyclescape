# frozen_string_literal: true

class SendCommentToCyclestreets
  extend Resque::Plugins::ExponentialBackoff
  @retry_limit = 3

  class << self
    def queue
      :medium
    end

    def perform(comment_id)
      return if Geocoder::API_KEY.blank?

      comment = SiteComment.find(comment_id)
      comment.with_lock do
        return if comment.sent_to_cyclestreets_at

        response = Excon.post(
          Geocoder::FEEDBACK_URL,
          body: comment.cyclestreets_body,
          headers: {
            "Content-Type" => Mime[:url_encoded_form].to_s,
            "X-API-KEY" => Geocoder::API_KEY
          }
        )
        comment.update!(sent_to_cyclestreets_at: Time.current, cyclestreets_response: JSON.parse(response.body))
      end
    end
  end
end
