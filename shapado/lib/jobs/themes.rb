module Jobs
  class Themes
    extend Jobs::Base

    def self.generate_stylesheet(theme_id)
      theme = Theme.find(theme_id)
      css = StringIO.new
      template_file = File.join(Rails.root,"lib","sass","theme_template.scss")

      buffer = self.define_vars(theme) << File.read(template_file) << "\n" << theme.custom_css || ""

      theme.last_error = ""
      2.times do
        template = Sass::Engine.new(buffer,
                                   {:style => Sass::Plugin.options[:style],
                                    :syntax => :scss,
                                    :cache => false,
                                    :load_paths => [File.join(Rails.root,"lib","sass"), "#{Gem.loaded_specs['compass'].full_gem_path}/frameworks/compass/stylesheets"]})

        compiled_css = ""
        begin
          compiled_css = template.render
        rescue => e
          last_error = e.to_s
          puts "Error processing #{theme_id}: #{last_error}"
          theme.last_error = last_error

          buffer = self.define_vars(theme) << File.read(template_file) << "\n"
        end

        if theme.last_error.empty?
          if Rails.env == "production"
            css << YUI::CssCompressor.new.compress(compiled_css)
          else
            css << compiled_css
          end

          break
        end
      end

      theme.stylesheet = css
      theme.stylesheet["extension"] = "css"
      theme.stylesheet["content_type"] = "text/css"
      theme.ready = true
      theme.increment_version
      theme.save
    end

    private
    def self.define_vars(theme)
%@
$has_bg_image: #{theme.has_bg_image?};
$bg_color: ##{theme.bg_color};
$fg_color: ##{theme.fg_color};
$bg_image_url: '/_files/themes/bg_image/#{theme.group_id}/#{theme.id}/#{theme.version}.png';
$topbar_color: ##{theme.topbar_color};
$logo_url: '/_files/groups/logo/#{theme.group_id}/#{theme.version}.png';
$view_bg_color: ##{theme.view_bg_color};
$brand_color: ##{theme.brand_color};
$fluid: #{theme.fluid};
$bg_shadow:      #999;
@
    end
  end
end
