class User < ApplicationRecord
  has_many :images
  has_many :comments, dependent: :destroy
  has_many :commented_images, through: :comments, source: :image
  has_many :liked_images, through: :likes, source: :image

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

   def self.from_omniauth(auth)
     where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
       user.email = auth.info.email
       user.password = Devise.friendly_token[0,20]
     end
   end

   def self.new_with_session(params, session)
     super.tap do |user|
       if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
         user.email = data["email"] if user.email.blank?
       end
     end
   end

   def has_liked?(image)
    liked_images.include? image
  end
end
