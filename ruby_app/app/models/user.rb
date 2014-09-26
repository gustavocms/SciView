class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :charts, dependent: :destroy

  def as_json(*args)
    super(*args).merge({ avatar_url: gravatar_url, name: full_name_or_email })
  end

  def gravatar_url
    gravatar.avatar_url
  end

  def full_name_or_email
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
      attrs.inject(gravatar.profile) { |hash, attr| hash.fetch(attr, {}) }[final].tap do |attr| 
        return attr if attr
      end
    end

    default
  end

  def gravatar
    @gravatar ||= Gravatar.new(email)
  end

end
