class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :charts, dependent: :destroy
  has_many :tdms_files, dependent: :destroy

end
