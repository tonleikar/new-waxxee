class PersonasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_return_path, only: %i[create destroy]

  def create
    # TODO: Remake the create personas method. Should be a simple API call.
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
