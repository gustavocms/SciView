class Chart < ActiveRecord::Base
  belongs_to :user

  validate :unique_series

  def self.for_datasets(datasets)
    new do |chart|
      chart.series = datasets
      chart.name = "Chart for #{datasets.values.join(',')}"
    end
  end

  def self.for_dataset(dataset)
    chart = new
    chart.name = "Chart for #{dataset}"
    chart.dataset_url = Rails.application.routes.url_helpers.dataset_path(dataset)
    chart
  end

  def to_partial_path
    self.class.to_s.downcase
  end

  private

  def unique_series
    values = series.values.sort
    user.charts.pluck(:series)
    value_exists = user.charts.pluck(:series).find { |s| s.values.sort ==  values }.present?
    errors[:base] << 'Chart already in your list' if value_exists 
  end

end