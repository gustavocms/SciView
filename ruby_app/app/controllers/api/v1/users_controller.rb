class Api::V1::UsersController < ApplicationController
  respond_to :json
  before_filter :authenticate_user!, :except => [:create, :show]

  def show
    render status: 200, json: {:info => "Current User", :user => current_user}
  end

  def create
    @user = User.create(user_params)
    if @user.valid?
      sign_in(@user)
      render status: 200, json: @user, location: api_v1_users_path
    else
      render status: 401, json: @user.errors, location: api_v1_users_path
    end
  end

  def update
    respond_with :api, User.update(current_user.id, user_params)
  end

  def destroy
    respond_with :api, User.find(current_user.id).destroy
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end