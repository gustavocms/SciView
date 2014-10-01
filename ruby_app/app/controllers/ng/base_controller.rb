class Ng::BaseController < ApplicationController
  layout 'ng'
  before_filter :authenticate_user!

  def home
  end
end
