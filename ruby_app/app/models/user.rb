class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :charts, dependent: :destroy

  def as_json(*args)
    super(*args).merge({ gravatar_url: gravatar_url })
  end

  def gravatar_url
    gravatar.to_s
  end

  private

  def gravatar
    Gravatar.new(email)
  end

end
