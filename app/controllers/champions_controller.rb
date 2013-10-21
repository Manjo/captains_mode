class ChampionsController < ApplicationController
  before_action :set_champion, only: [:show, :edit, :update, :destroy]

  # GET /champions
  # GET /champions.json
  def index
    @champions = Champion.all

    respond_to do |format|
      # format.json { }
    end
  end

  # GET /champions/1
  # GET /champions/1.json
  def show
    set_champion
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_champion
      @champion = Champion.find!(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def champion_params
      params.require(:champion).permit(:name, :role)
    end
end
