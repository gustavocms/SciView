class Chart
  attr_accessor :name, :dataset_url

  def self.for_dataset(dataset)
    chart = new
    chart.name = "Chart for #{dataset}"
    chart.dataset_url = Rails.application.routes.url_helpers.dataset_path(dataset)
    chart
  end
end
