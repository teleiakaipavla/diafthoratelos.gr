require 'digest/md5'


desc "generating js assets"
task :jsassets do
  puts "generating prod assets"
  Jammit.package!
  assets = YAML::load( File.open( 'config/assets.yml' ) )
  assets["javascripts"].keys.each do |k|
    file = "public/packages/#{k}.js"
    digest = Digest::MD5.hexdigest(File.read(file))[0..9]
    assets["javascripts"][k.split('_').first] = ["/packages/#{k}.js"]
    assets["javascripts"].delete(k) if k.include?('_')
  end
  assets["stylesheets"].keys.each do |k|
    file = "public/packages/#{k}.css"
    digest = Digest::MD5.hexdigest(File.read(file))[0..9]
    assets["stylesheets"][k.split('_').first] = ["/packages/#{k}.css"]
    assets["stylesheets"].delete(k) if k.include?('_')
  end
  jsassets = assets["javascripts"].to_json
  cssassets = assets["stylesheets"].to_json
  assets_content = "/*THIS FILE IS AUTO-GENERATED FOR DEV, DO NOT MODIFY IT. MODIFY config/assets.yml INSTEAD*/\n jsassets = #{jsassets}; cssassets = #{cssassets};"
  File.open('public/javascripts/app/initializers/assets.js', 'w') do |f|
    f.puts assets_content
  end
  Jammit.package!
  puts "done generating assets.js."
end
