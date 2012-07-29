# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'CSV'

Category.delete_all
PublicEntity.delete_all
Incidents.delete_all

categories_path = File.dirname(__FILE__) + "/categories.csv"

CSV.foreach(categories_path, :col_sep => ";") do |row|
  Category.create(name: row[0])
end

public_entities_path = File.dirname(__FILE__) + "/tax_offices.csv"

tax_office_category = Category.where(:name => "Εφορίες").first

CSV.foreach(public_entities_path, :col_sep => ";") do |row|
  PublicEntity.create(name: row[0], category_id: tax_office_category.id)
end

public_entities_path = File.dirname(__FILE__) + "/hospitals.csv"

hospital_category = Category.where(:name => "Νοσοκομεία").first

CSV.foreach(public_entities_path, :col_sep => ";", :quote_char => '"') do |row|
  PublicEntity.create(name: row[0], category_id: hospital_category.id)
end
