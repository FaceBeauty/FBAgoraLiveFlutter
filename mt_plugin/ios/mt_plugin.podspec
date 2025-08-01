#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mt_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mt_plugin'
  s.version          = '0.0.1'
  s.summary          = 'FaceBeauty SDK的Flutter插件示范'
  s.description      = <<-DESC
FaceBeauty SDK的Flutter插件示范
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.static_framework = true
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  
  # 本地framework导入
  s.vendored_frameworks = 'Vendored/*.framework'
  s.resources = 'Vendored/*.bundle'
  s.libraries = ["c++"]
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'


  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
end
