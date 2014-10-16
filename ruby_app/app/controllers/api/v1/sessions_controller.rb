class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/vnd.radd.v1' }

  def create
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    render :status => 200, :json => { :success => true, :info => "Logged in", :user => current_user }
  end

  def destroy
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_out
    render :status => 200, :json => { :success => true, :info => "Logged out", :csrfParam => request_forgery_protection_token, :csrfToken => form_authenticity_token }
  end

  def failure
    # using distinct code from 401 to avoid conflict with angular interceptor
    render :status => 400, :json => { :success => false, :info => "Login Credentials Failed" }
  end

  def show_current_user
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    render :status => 200, :json => { :success => true, :info => "Current User", :user => current_user }
  end
end
