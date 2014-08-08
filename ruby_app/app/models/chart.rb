class Chart < ActiveRecord::Base
  belongs_to :user

  validates :series, presence: true
  validates :name, presence: true, uniqueness: {
      scope: :user,
      case_sensitive: false,
      message: "must be unique" }

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

end
