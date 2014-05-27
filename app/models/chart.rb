class Chart
  attr_accessor :name, :dataset_url

  def self.for_datasets(datasets)
    chart = new
    chart.name = "Chart for #{datasets.values.join(',')}"
    chart.dataset_url = Rails.application.routes.url_helpers.multiple_datasets_path(datasets)
    chart
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
