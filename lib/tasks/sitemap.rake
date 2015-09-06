require 'rubygems'
require 'sitemap_generator'
namespace :sitemap do
  desc "TODO"
  task :generate do
  	SitemapGenerator::Sitemap.default_host = 'http://instajobs.io'
		SitemapGenerator::Sitemap.create do
		  add '/home', :changefreq => 'daily', :priority => 0.9
		  add '/contact_us', :changefreq => 'weekly'
		end
  end
end
