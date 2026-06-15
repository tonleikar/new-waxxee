require 'json'
require 'open-uri'
require 'uri'

class UserVinylsController < ApplicationController
  def create
    release_id = user_vinyl_params[:release_id]
    discogs_url = release_id

    @new_vinyl = Vinyl.find_by(discogs_url: discogs_url)

    unless @new_vinyl
      vinyl_attributes = get_vinyl_from_discogs(release_id)
      unless vinyl_attributes
        return redirect_back fallback_location: vinyls_path,
                             alert: 'Failed to add vinyl to collection.'
      end

      @new_vinyl = Vinyl.new(
        vinyl_attributes.except(:thumb).merge(artwork_url: vinyl_attributes[:thumb])
      )

      unless @new_vinyl.save
        return redirect_back fallback_location: vinyls_path,
                             alert: 'Failed to add vinyl to collection.'
      end
    end

    @new_user_vinyl = UserVinyl.new(user: current_user, vinyl: @new_vinyl)
    if @new_user_vinyl.save
      redirect_back fallback_location: vinyls_path, notice: 'Vinyl added to collection.'
    else
      redirect_back fallback_location: vinyls_path, alert: 'Failed to add vinyl to collection.'
    end
  end

  def destroy
    @user_vinyl = current_user.user_vinyls.find(params[:id])
    current_user.update!(favorite_vinyl_id: nil) if current_user.favorite_vinyl_id == @user_vinyl.vinyl_id
    @user_vinyl.destroy!
    redirect_back fallback_location: vinyls_path, notice: 'Vinyl removed from collection.'
  end

  private

  def user_vinyl_params
    params.require(:user_vinyl).permit(:release_id, :cover_image)
  end

  def get_vinyl_from_discogs(release_id)
    url = URI.parse("https://api.discogs.com/releases/#{release_id}")
    query_params = {
      key: ENV['DISCOGS_CONSUMER_KEY'],
      secret: ENV['DISCOGS_CONSUMER_SECRET']
    }.compact
    url.query = URI.encode_www_form(query_params) if query_params.any?

    vinyl = JSON.parse(URI.open(url).read)
    {
      artist: artist_name,
      artwork_url: vinyl['images'][0]['resource_url`'],
      country: vinyl['country'],
      discogs_url: vinyl['release_id'],
      genre: vinyl['genres'],
      title: vinyl['title'],
      year: vinyl['released']
    }
  rescue OpenURI::HTTPError, JSON::ParserError, SocketError, URI::InvalidURIError => e
    flash[:alert] = e.message
    nil
  end
end
