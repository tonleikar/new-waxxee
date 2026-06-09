class PersonasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_return_path, only: %i[create destroy]

  def create
    persona = PersonaUpdater.new(
      user: current_user,
      prompt: persona_params[:prompt],
      primary_profile: primary_profile_request?
    ).call
    puts "Creating Persona #{params}"
    redirect_to next_path_for(persona), notice: persona_notice
  rescue StandardError => e
    redirect_to @return_path, alert: "Could not generate persona: #{e.message}"
  end

  def destroy
    persona = current_user.personas.find(params[:id])
    persona.destroy!

    redirect_to @return_path, notice: 'Persona removed.'
  end

  private

  def persona_params
    params.fetch(:persona, {}).permit(:prompt, :primary_profile, :return_to, :redirect_to_swiper)
  end
end
