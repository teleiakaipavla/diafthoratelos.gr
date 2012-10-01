# -*- coding: utf-8 -*-
# invoke in production mode by:
# RAILS_ENV=production ruby add_category.rb <category_name> <category_basefilename>.csv

require "../config/environment"

require 'csv'

category_name = ARGV[0]
category_filename = ARGV[1]

category_path = "#{File.dirname(__FILE__)}/#{category_filename}.csv" 

category = Category.find_or_create_by_name(category_name)

CSV.foreach(category_path, :col_sep => ";") do |row|
  PublicEntity.create(name: row[0].strip, category_id: category.id)
end
