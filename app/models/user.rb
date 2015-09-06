require 'file_size_validator'
class User
	include Mongoid::Document
  include ActiveModel::SecurePassword
  field :name, type: String
  field :email, type: String
  field :bio, type: String
  field :skills, type: String
  field :sex, type: String
  field :number, type: Integer
  field :avatar
  field :avatar_processing, type: Boolean, default: false
  index({ email: 1 }, { unique: true })
  field :password_digest, type: String
  field :email_verify_token, type: String
  field :email_verified, type: Boolean
  field :forgot_password, type: String 
  field :jobmatches, type: Array
  field :mobiletoken, type: String
  index({ mobiletoken: 1 }, { unique: true })
  embeds_one :facebook_profile
  embeds_one :linked_in_profile
  has_secure_password
  has_many :companies
  has_and_belongs_to_many :jobs
  validates_presence_of :name, :email, :mobiletoken
  mount_uploader :avatar, AvatarUploader
  validates :avatar, :file_size => {:maximum => 1.megabytes.to_i}
  process_in_background :avatar
end
