class CoffeeChartsController < ChartsController
  def show
    super
    puts @chart.inspect
  end
end
