class UserVinylsController < ApplicationController
  def create
    # TODO: Recreate UserVinyl controller create. Should take the ID of vinyl and ID of user. Maybe we can remove entirley
  end

  def destroy
    @user_vinyl = current_user.user_vinyls.find(params[:id])
    current_user.update!(favorite_vinyl_id: nil) if current_user.favorite_vinyl_id == @user_vinyl.vinyl_id
    @user_vinyl.destroy!
    redirect_back fallback_location: vinyls_path, notice: 'Vinyl removed from collection.'
  end

  private

  def release_id
    params[:release_id].presence || params.dig(:vinyl, :id).presence
  end

  def cover_image
    params[:cover_image].presence || params.dig(:vinyl, :cover_image).presence
  end
end
