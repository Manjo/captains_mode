require 'exceptions'

# TODO: atomic transactions

class Lobby < ActiveRecord::Base
  # Using this to publish the correct event for Redis
  # Should I probably use an observer pattern instead?
  attr_accessor :event_contents
  attr_accessible :event_contents
  
  before_create :assign_unique_token
  after_save :notify_event
  after_destroy :clear_redis

  serialize :bans_one,  Array
  serialize :bans_two,  Array
  serialize :picks_one, Array
  serialize :picks_two, Array

  state_machine :initial => :team_one_waiting do
    event :register_team do
      transition :team_one_waiting => :team_two_waiting,
                 :team_two_waiting => :team_one_ban
    end

    event :ban do
      transition :team_one_ban => :team_two_ban,
                 :team_two_ban => :team_one_pick_one
    end

    event :pick do
      transition :team_one_pick_one   => :team_two_pick_one,
                 :team_two_pick_one   => :team_two_pick_two,
                 :team_two_pick_two   => :team_one_pick_two,
                 :team_one_pick_two   => :team_one_pick_three,
                 :team_one_pick_three => :team_two_pick_three,
                 :team_two_pick_three => :team_two_pick_four,
                 :team_two_pick_four  => :team_one_pick_four,
                 :team_one_pick_four  => :team_one_pick_five,
                 :team_one_pick_five  => :team_two_pick_five,
                 :team_two_pick_five  => :done
    end
  end

  def register(user)
    unless self.can_register_team?
      raise Exceptions::InvalidEvent, "Team captains cannot be registered currently"
    end

    case get_team_from_state
    when :team_one
      self.team_one = user
    when :team_two
      self.team_two = user
    end
    
    @event_contents = [:register, user]

    super
  end

  def ban(team, name)
    unless self.can_ban?
      raise Exceptions::InvalidEvent, "Teams cannot currently ban"
    end
    
    case team
    when :team_one
      self.bans_one << name
    when :team_two
      self.bans_two << name
    end
    
    @event_name = [:ban, name]

    super
  end

  def pick(team, name)
    unless self.can_pick?
      raise Exceptions::InvalidEvent, "Teams cannot currently pick"
    end

    case team
    when :team_one
      self.picks_one << name
    when :team_two
      self.picks_two << name
    end
    
    @event_name = [:pick, name]
    
    super
  end
  
  # Returns false if the supplied user is not a registered team captain
  def get_team(user)
    case user
    when self.team_one
      :team_one
    when self.team_two
      :team_two
    else
      false
    end
  end
  
  # Returns :done if there is no longer a team necessary ("done")
  def current_team
    get_team_from_state
  end
  alias_method :current_team?, :current_team

  def current_action
    return self.state_paths.events[0]
  end
  alias_method :current_action?, :current_action
  
  def to_param
    self.unique_token
  end
  
  def channel_name
    self.unique_token.to_s
  end

  private
    
    def build_event_json
      json = {}
      json[:event] = @event_name[0].to_s
      if json[:event] == :pick or json[:event] == :ban
        json[:name] = @event_name[1]
      end
      json[:next] = next_event
    end
    
    def notify_event
      redis = Redis.new
      json = build_event_json
      redis.publish(channel_name, json)
    end
    
    def clear_redis
      redis = Redis.new
      redis.delete(channel_name)
    end
    
    def next_event
      return :done if self.state == "done"
      
      # First 8 say "team_one" or "team_two" so after that is 'pick' 'ban' or 'register'
      self.state[8..-1]
    end
  
    def get_team_from_state
      return :done if self.state == "done"

      # Return the first 8 characters, will always contain 'team_one' or 'team_two'
      self.state[0,8].to_sym
    end

    def assign_unique_token
      begin
        self.unique_token = SecureRandom.hex(4)
      end until unique_token?
    end

    def unique_token?
      !Lobby.where(unique_token: self.unique_token).exists?
    end
end
