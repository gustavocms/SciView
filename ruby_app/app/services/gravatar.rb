require 'digest'
class Gravatar
  attr_reader :email
  def initialize(email)
    @email = email
  end

  def to_s
    avatar_url
  end

  alias_method :to_str, :to_s

  def avatar_url
    "https://secure.gravatar.com/avatar/#{email_hash}"
  end

  def profile_url
    "https://secure.gravatar.com/#{email_hash}"
  end

  private

  def email_hash
    Digest::MD5.hexdigest(email)
  end
end
