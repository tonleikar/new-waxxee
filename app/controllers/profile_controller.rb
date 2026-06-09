class ProfileController < ApplicationController
  before_action :set_profile_user, only: [:show]
  before_action :ensure_current_user!, only: %i[edit update destroy]
  before_action :set_current_user, only: %i[edit update destroy]

  def show
    @vinyls = @user.vinyls
    @favorite_vinyl = @vinyls.find_by(id: @user.favorite_vinyl_id)
    @following_users = @user.following.order(:username)
    @personas = @user.personas.generated_for_profile
    @own_profile = @user == current_user
  end

  def edit
    @genres = Vinyl.distinct.order(:genre).pluck(:genre)
  end

  def update
    @user.update!(normalized_profile_params)

    respond_to do |format|
      format.html { redirect_to profile_path(@user) }
      format.json { render json: { success: true, favorite_vinyl_id: @user.favorite_vinyl_id } }
    end
  end

  def destroy
    @user.destroy!
    redirect_to authenticated_root_path
  end

  private

  def set_profile_user
    @user = User.find(params[:id])
  end

  def ensure_current_user!
    return if params[:id].blank? || params[:id].to_s == current_user.id.to_s

    redirect_to profile_path(current_user)
  end

  def set_current_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:name, :username, :favorite_genre, :favorite_vinyl_id)
  end
end
