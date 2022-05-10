#
# Be sure to run `pod lib lint DDSwiftHook.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name     = 'DDSwiftHook'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A description of DDSwiftHook.'
  s.homepage = 'https://github.com/dondong/DDSwiftHook'
  s.authors  = { 'dondong' => 'the-last-choice@qq.com' }
  s.source   = { :git => 'https://github.com/dondong/DDSwiftHook.git', :tag => s.version  }
  s.module_name   = 'DDSwiftHook'
  s.swift_version = '5.5'
  
  s.platform = :ios
  s.ios.deployment_target = '11.0'


  s.ios.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.dd.kit.swift.hook' }

  s.source_files = 'Framework/*'
  
end
