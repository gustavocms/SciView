require 'benchmark'

namespace :data do

  desc 'benchmarks TempoDB API Rollup functions using different intervals over wide time extents'
  task :benchmark do
    s = tempodb_client.get_series('sample_0a75cf_1404935738')
    summary = tempodb_client.get_summary('sample_0a75cf_1404935738', Time.utc(1999), Time.utc(2020))
    puts summary.inspect

    Benchmark.bm do |m|
      %w{1min PT30S PT10S PT1S PT0.5S}.each do |period|
        m.report(period) do
          cursor = tempodb_client.read_multi(
            Time.utc(2013), 
            Time.utc(2015), 
            { 
              keys: %w{sample_0a75cf_1404935738 sample_870ed9_1404946027},
              rollup_function: "mean",
              rollup_period: period
            })

          data = cursor.to_a
        end
      end
    end
  end

  private

  def tempodb_client
    @tempodb_client ||= TempoDB::Client.new(ENV['TEMPODB_API_ID'], ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET'])
  end
end
