module Concerns
  module Tempo
    extend ActiveSupport::Concern

    included do
      self.extend Concerns::Tempo
    end

    private

    def get_tempodb_client
      TempoDB::Client.new(ENV['TEMPODB_API_ID'], ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET'])
    end

  end
end