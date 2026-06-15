require 'json'
require 'open-uri'
require 'uri'

class UserVinylsController < ApplicationController
  def create
    release_id = user_vinyl_params[:release_id]
    discogs_url = "https://www.discogs.com/release/#{release_id}"

    @new_vinyl = Vinyl.find_by(discogs_url: discogs_url)

    unless @new_vinyl
      vinyl_attributes = get_vinyl_from_discogs(release_id)
      unless vinyl_attributes
        return respond_to_request({ error: 'Failed to fetch vinyl from Discogs.' }, :unprocessable_entity)
      end

      @new_vinyl = Vinyl.new(vinyl_attributes)

      unless @new_vinyl.save
        return respond_to_request({ error: 'Failed to save vinyl to collection.' }, :unprocessable_entity)
      end
    end

    @new_user_vinyl = UserVinyl.new(user: current_user, vinyl: @new_vinyl)
    if @new_user_vinyl.save
      respond_to_request({ message: 'Vinyl added to collection.' }, :created)
    else
      respond_to_request({ error: 'Failed to add vinyl to collection.' }, :unprocessable_entity)
    end
  end

  def destroy
    @user_vinyl = current_user.user_vinyls.find(params[:id])
    current_user.update!(favorite_vinyl_id: nil) if current_user.favorite_vinyl_id == @user_vinyl.vinyl_id
    @user_vinyl.destroy!
    redirect_back fallback_location: vinyls_path, notice: 'Vinyl removed from collection.'
  end

  private

  def respond_to_request(data, status)
    respond_to do |format|
      format.json { render json: data, status: status }
      format.html { redirect_back fallback_location: vinyls_path, alert: data[:error] || data[:message] }
    end
  end

  def user_vinyl_params
    params.permit(:release_id, :cover_image, user_vinyl: {})
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
      artist: vinyl.dig('artists', 0, 'name') || vinyl['artists_sort'] || 'Unknown Artist',
      artwork_url: vinyl.dig('images', 0, 'resource_url'),
      country: vinyl['country'],
      discogs_url: "https://www.discogs.com/release/#{vinyl['id']}",
      genre: vinyl['genres']&.join(', ') || 'Unknown Genre',
      title: vinyl['title'] || 'Unknown Title',
      year: vinyl['year'] || vinyl['released']
    }
  rescue OpenURI::HTTPError, JSON::ParserError, SocketError, URI::InvalidURIError => e
    Rails.logger.error("Discogs API error: #{e.message}")
    nil
  end
end
