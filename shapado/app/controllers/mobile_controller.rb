class MobileController < ApplicationController
  layout 'mobile'

  def index
    redirect_to questions_path(:format => :mobile)
  end

end
