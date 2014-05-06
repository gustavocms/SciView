module ApplicationHelper
  def javascript_for_action
    javascript_include_tag("#{controller_name}/#{action_name}")
  end
end
