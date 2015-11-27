Pod::Spec.new do |s|
  s.name         = "KWListView"
  s.version      = "1.0.1"
  s.ios.deployment_target = '6.0'
# s.osx.deployment_target = '10.8'
  s.summary      = "The better way to deal with list view and datas"
  s.homepage     = "http://makaiwen.com/items/KWListView.html"
  s.license      = "MIT"
  s.author             = { "kevin-ma" => "devKevinMa@gmail.com" }
  s.social_media_url   = "http://makaiwen.com/"
  s.source       = { :git => "https://github.com/kevin-ma/KWListView.git", :tag=>s.version.to_s }
  s.source_files  = "KWListView/*.{h,m}"
  s.resources = "KWListView/KWListView.bundle","KWListViewLoading.bundle"
  s.requires_arc = true
  s.framework = 'UIKit','Foundation'
end
