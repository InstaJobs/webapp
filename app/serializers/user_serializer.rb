class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :bio, :skills, :sex, :number
  def attributes
  	data = super
  	data[:propic] = object.avatar.url || "/assets/images/propic.jpg"
  	data
  end
end
