[:companies, :company_users, :company_user_activities, :company_user_activities].each do |a| ActiveRecord::Base.connection.truncate(a) end

require 'json'
require File.expand_path('../../config/environment', File.dirname(__FILE__))

FOLDER = Rails.root.join('bin', 'insights_data', "all_data")

def upsert_all_resources(resource_name)
  all_resources = JSON.parse(File.read("#{FOLDER.to_s}/#{resource_name}.json"))
  class_name = Kernel.const_get(resource_name.singularize.camelize)
  class_name.where(id: all_resources.pluck(:id)).try(:delete_all)
  created_resources = class_name.insert_all(all_resources)
  p "#{created_resources.count} #{resource_name} created"
end

upsert_all_resources('companies')
upsert_all_resources('company_users')
upsert_all_resources('company_user_activities')
upsert_all_resources('trends_activities')
