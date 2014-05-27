module Concerns
  module Tempo
    extend ActiveSupport::Concern

    included do
      extend Concerns::Tempo
    end

    private

    def tempodb_client
      @tempodb_client ||= TempoDB::Client.new(ENV['TEMPODB_API_ID'],
                                              ENV['TEMPODB_API_KEY'],
                                              ENV['TEMPODB_API_SECRET'])
    end
  end
end
