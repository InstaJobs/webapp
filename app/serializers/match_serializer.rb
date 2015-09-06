class MatchSerializer < ActiveModel::Serializer
	 attributes :id, :title, :description, :salary, :hours, :location, :address, :email, :number, :responsibility, :created_at

  def attributes
  	data = super
  	data[:company_id] = object.company.id
  	data[:company_name] = Company.find(data[:company_id]).name
  	data[:users_liked] = object.user_ids.length
  	data
  end
end
