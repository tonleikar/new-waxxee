class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    redirect_to welcome_index_path if current_user.present?
    @recent_vinyls = Vinyl.last(4)
  end
end
