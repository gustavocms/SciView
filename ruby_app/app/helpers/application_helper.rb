module ApplicationHelper
  
  # this wont work on production enviroment since everything is compiled
  #def javascript_for_action
  #  javascript_include_tag("#{controller_name}/#{action_name}")
  #end


  def get_tempodb_client
    TempoDB::Client.new(ENV['TEMPODB_API_ID'], ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET'])
  end

end