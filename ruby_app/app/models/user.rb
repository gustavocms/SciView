class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :charts, dependent: :destroy

  def as_json(*args)
    super(*args).merge({ gravatar_url: gravatar_url })
  end

  def gravatar_url
    gravatar.avatar_url
  end

  def gravatar_profile
    @gravatar_profile ||= JSON.parse(gravatar_profile_response.body).fetch("entry", []).first
  end

  def full_name
    try_profile_attributes(["name", "formatted"], ["displayName"], email)
  end

  private

  # Traverses the nested hash structure until a present group is found, then returns
  # that attribute.
  #
  # Otherwise returns the last argument (default).
  #
  # Ex: 
  # ["name", "formatted"] returns "My Name" for profile
  # { "name" => { "formatted"  => "My Name" }}
  def try_profile_attributes(*attr_groups, default)
    attr_groups.each do |*attrs, final|
      attrs.inject(gravatar_profile) { |hash, attr| hash.fetch(attr, {}) }[final].tap {|x| return x if x }
    end
    default
  end

  def gravatar
    Gravatar.new(email)
  end

  def gravatar_profile_uri
    URI.parse("#{gravatar.profile_url}.json")
  end

  def gravatar_profile_response
    Net::HTTP.get_response(gravatar_profile_uri)
  end

end
