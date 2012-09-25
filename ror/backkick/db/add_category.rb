# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "../config/environment"

require 'csv'

category_name = ARGV[0]
category_filename = ARGV[1]

category_path = "#{File.dirname(__FILE__)}/#{category_filename}.csv" 

category = Category.find_or_create_by_name(category_name)

CSV.foreach(category_path, :col_sep => ";") do |row|
  PublicEntity.create(name: row[0].strip, category_id: category.id)
end
