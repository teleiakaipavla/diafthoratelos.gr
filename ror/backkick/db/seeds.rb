# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

Category.delete_all
PublicEntity.delete_all
Incident.delete_all

categories_path = File.dirname(__FILE__) + "/categories.csv"

public_entity_types = {}
CSV.foreach(categories_path, :col_sep => ",") do |row|
  if row[0]
    public_entity_types[row[0]] = row[1]
  end
  Category.create(name: row[1])
end

public_entity_types.each do |english_name, greek_name|
  file_path = File.dirname(__FILE__) + "/#{english_name}.csv"
  puts "processing #{file_path}"
  category = Category.where(:name => greek_name).first
  CSV.foreach(file_path, :col_sep => ";") do |row|
    PublicEntity.create(name: row[0], category_id: category.id)
  end
end
