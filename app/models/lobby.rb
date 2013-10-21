require 'exceptions'

# TODO: atomic transactions
# TODO: Change picks and bans into relationships with champions

class Lobby < ActiveRecord::Base
  include Tokenable
  
  # Ordered by time of team creation
  # This limit doesn't really prevent anything...
  has_many :teams, -> { order('created_at ASC').limit(2) }

  # Using this to publish the correct event for Redis
  # Should I probably use an observer pattern instead?
  attr_accessor :event_contents

  after_save :notify_event
  after_destroy :clear_redis

  state_machine :initial => :team_one_waiting do
    event :register do
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

  # === Utility ===
  # TODO: Rewrite these less crappy...
  def team(team)
    case team
    when :team_one
      return nil if teams.size < 1
      teams[0]
    when :team_two
      return nil if teams.size < 2
      teams[1]
    end
  end

  def bans(team=:both)
    case team
    when :team_one
      return [] if teams.size < 1
      teams[0].bans.map { |b| b.champion }
    when :team_two
      return [] if teams.size < 2
      teams[1].bans.map { |b| b.champion }
    when :both
      [bans(:team_one), bans(:team_two)].flatten
    end
  end

  def picks(team=:both)
    case team
    when :team_one
      return [] if teams.size < 1
      teams[0].picks.map { |p| p.champion }
    when :team_two
      return [] if teams.size < 2
      teams[1].picks.map { |p| p.champion }
    when :both
      [picks(:team_one), picks(:team_two)].flatten
    end
  end

  def captains(team=:both)
    case team
    when :team_one
      return nil if teams.size < 1
      teams[0].captain_id
    when :team_two
      return nil if teams.size < 2
      teams[1].captain_id
    when :both
      return 
      [captains(:team_one), captains(:team_two)]
    end
  end

  def to_param
    self.token
  end
  
  def channel_name
    self.token
  end


  # === Workflow Actions ===

  def register(user)
    unless self.can_register?
      raise Exceptions::InvalidEvent, "Team captains cannot be registered currently"
    end
    
    teams << Team.new(captain_id: user)
    @event_contents = [:register, user]

    super
  end

  def ban(team, name)
    unless self.can_ban?
      raise Exceptions::InvalidEvent, "Teams cannot currently ban"
    end

    champ = Champion.find_by_name!(name)
    team(team).ban(champ)
    
    @event_name = [:ban, name]

    super
  end

  def pick(team, name)
    unless self.can_pick?
      raise Exceptions::InvalidEvent, "Teams cannot currently pick"
    end

    champ = Champion.find_by_name!(name)
    team(team).pick(champ)
    
    @event_name = [:pick, name]
    
    super
  end

  # Returns nil if there's no captain with given id
  def get_team_by_captain(user)
    teams.find { |x| x.team_captain?(user) }
  end
  
  # Returns false if the supplied user is not a registered team captain
  def get_team_symbol(user)
    case teams.find_index { |x| x.team_captain?(user) }
    when 0
      :team_one
    when 1
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

  private
    
    def build_event_json
      return nil if @event_name.nil? # In case it's just a raw save

      json = {}
      json[:event] = @event_name[0].to_s
      if json[:event] == :pick or json[:event] == :ban
        json[:name] = @event_name[1]
      end
      json[:next] = next_event
    end
    
    def notify_event
      redis = Redis.new(port: REDIS_PORT)
      json = build_event_json
      redis.publish(channel_name, json) unless json.nil?
    end
    
    def clear_redis
      redis = Redis.new(port: REDIS_PORT)
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
end
