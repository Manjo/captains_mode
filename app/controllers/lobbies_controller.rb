require 'exceptions'
require 'sse/writer'

class LobbiesController < ApplicationController
  include ActionController::Live
  
  rescue_from Exceptions::InvalidEvent, :with => :invalid_event
  rescue_from Exceptions::InvalidSession, :with => :invalid_session
  
  def index
    @lobbies = Lobby.all
  end
  
  def create
    @lobby = Lobby.new
    if @lobby.save
      flash[:notice] = 'Lobby successfully created!'
      redirect_to(@lobby)
    else
      flash[:error] = 'Cannot create new lobby. Try again soon.'
      render :index
    end
  end

  # TODO Inform a user if they're a captain (in case of refresh)
  def show
    @lobby = Lobby.find_by_unique_token!(params[:id])
    @characters = ["Wonder", "Batman", "Zatanna", "Flash", "Joker"]
  end
  
  def stream
    @lobby = Lobby.find_by_unique_token!(params[:id])
    
    response.headers['Content-Type'] = 'text/event-stream'
    stream = SSE::Writer.new(response.stream)
    redis = Redis.new
    
    begin
      redis.subscribe(@lobby.channel_name) do |on|
        on.message do |event, data|
          e = data.delete(:event)
          stream.write(JSON.parse(data).to_json, :event => data[:event])
        end
      end
    rescue IOError
    ensure
      stream.close
    end
  end
  
  def register
    @lobby = Lobby.find_by_unique_token!(params[:id])
    user = session[:user_id]
    @lobby.register(user)
    render :json => { :message => "Registered as #{team_name(user)}"}, :status => :ok
  end
  
  def ban
    @lobby = Lobby.find_by_unique_token!(params[:id])
    team = find_team
    name = params[:name]
    @lobby.ban(team, name)
    render :json => { :message => "#{team_name(team)} has banned #{name}"}, :status => :ok
  end
  
  def pick
    @lobby = Lobby.find_by_unique_token!(params[:id])
    team = find_team
    name = params[:name]
    @lobby.pick(team, name)
    render :json => { :message => "#{team_name(team)} has picked #{name}"}, :status => :ok
  end
  
  private
  
    def team_name(team)
      unless team.is_a? Symbol
        team = @lobby.get_team(user)
      end
      team.to_s.titleize
    end
    
    def find_team
      team = @lobby.get_team(session[:user_id])
      raise Exceptions::InvalidSession if team == false
      team
    end
  
    def invalid_event(error)
      render :json => { :error => error.message }, :status => :unprocessable_entity
    end
    
    def invalid_session(error)
      render :json => { :error => "You are not a team captain" }, :status => :unauthorized
    end
end
