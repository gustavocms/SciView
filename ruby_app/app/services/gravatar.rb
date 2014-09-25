require 'digest'
class Gravatar
  attr_reader :email
  def initialize(email)
    @email = email
  end

  def to_s
    "https://secure.gravatar.com/avatar/#{email_hash}"
  end

  alias_method :to_str, :to_s

  private

  def email_hash
    Digest::MD5.hexdigest(email)
  end
end
