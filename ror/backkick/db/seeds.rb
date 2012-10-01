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
  next unless row[0]
  public_entity_name = row[0].strip
  next if public_entity_name.start_with?('#')
  if public_entity_name != ""
    public_entity_types[public_entity_name] = row[1]
    puts "Create category #{row[1].strip}"
  end
end

public_entity_types.each do |public_entity_name, greek_label|
  file_path = File.dirname(__FILE__) + "/#{public_entity_name}.csv"
  puts "processing #{file_path}"
  category = Category.where(:name => greek_label).first
  CSV.foreach(file_path, :col_sep => ";") do |row|
    puts "Create public_entity #{row[0].strip}:#{category_id}"
  end
end
