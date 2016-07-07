#
#  Be sure to run `pod spec lint PWImageNet.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "PWImageNet"
  s.version      = "0.0.1"
  s.summary      = "PWImageNet is used to load image from net."


  s.description  = "PWImageNet is used to load image from net. Support gif, png, jpg, tiff and so on. You can chose cache type in memory and disk"

  s.homepage     = "https://github.com/wangweicheng7/PWImageNet"

  s.license      = "MIT"

  s.author             = { "wangweicheng" => "wangweicheng@putao.com" }

  s.source       = { :git => "git@github.com:wangweicheng7/PWImageNet.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.source_files  = "PWImageNet", "PWImageNet/*"
# s.exclude_files = "PWImageNet/module.map"
# s.frameworks = 'PWImageNet/module.map/CommonDigest'
# s.module_name = "CommonDigest"
  s.preserve_path = 'PWImageNet/module.map'
end
