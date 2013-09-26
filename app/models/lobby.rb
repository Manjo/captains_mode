class Lobby < ActiveRecord::Base
  before_create :assign_unique_token

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

  def register_team(user)
    return false unless self.can_register_team?

    case get_team_from_state
    when :team_one
      self.team_one = user
    when :team_two
      self.team_two = user
    end

    super
  end

  def ban(name)
    return false unless self.can_ban?

    bans_list = case get_team_from_state
    when :team_one
      self.bans_one
    when :team_two
      self.bans_two
    end

    bans_list << name
    super
  end

  def pick(name)
    return false unless self.can_pick?

    picks_list = case get_team_from_state
    when :team_one
      self.picks_one
    when :team_two
      self.picks_two
    end

    picks_list << name
    super
  end

  def current_action
    return self.state_paths.events[0]
  end
  alias_method :current_action?, :current_action

  private
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
