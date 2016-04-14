#
#  Be sure to run `pod spec lint MinScrollMenu.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
	
  s.name         = "MinScrollMenu"
  s.version      = "1.0.0"
  s.summary      = "A custom horizontal scroll menu."
  s.description  = <<-DESC
  					模仿tableview写的一个横向滚动的menu，操作方式类似tableview，实现delegate方法即可
                   DESC

  s.homepage     = "https://github.com/zsmzhu/MinScrollMenu.git"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "MIT"
  s.author             = { "zsm" => "zsmzhug@gmail.com" }
  # s.social_media_url   = "http://twitter.com/zsm"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/zsmzhu/MinScrollMenu.git", :tag => "1.0.0" }
  s.source_files = "MinScrollMenu/**/*.{h,m}"
  s.framework  = "UIKit", "Foundation"
  s.requires_arc = true

end
