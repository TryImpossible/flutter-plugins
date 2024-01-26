##
## To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
## Run `pod lib lint flutter_uni_applet.podspec` to validate before publishing.
##
#Pod::Spec.new do |s|
#  s.name             = 'flutter_uni_applet'
#  s.version          = '0.0.1'
#  s.summary          = 'A uni applet Flutter plugin.'
#  s.description      = <<-DESC
#A uni applet Flutter plugin.
#                       DESC
#  s.homepage         = 'http://example.com'
#  s.license          = { :file => '../LICENSE' }
#  s.author           = { 'Your Company' => 'email@example.com' }
#  s.source           = { :path => '.' }
#  s.source_files = 'Classes/**/*.{swift,h}'
#  s.public_header_files = 'Classes/Core/Headers/*.h','Classes/Core/Headers/weexHeader/*.h'
#  s.static_framework = true
#  s.frameworks = 'JavaScriptCore', 'CoreMedia', 'MediaPlayer', 'AVFoundation', 'AVKit', 'GLKit', 'OpenGLES', 'CoreText', 'QuartzCore', 'CoreGraphics', 'QuickLook', 'CoreTelephony'
#  s.libraries             = 'c++', 'iconv'
#  s.vendored_frameworks = 'Classes/Core/Libs/*.framework'
#  s.vendored_libraries = 'Classes/Core/Libs/*.a'
#  s.resources = "Classes/Core/Resources/*.js", "Classes/Core/Resources/*.bundle"
#
#  s.dependency 'Flutter'
#  s.platform = :ios, '11.0'
#
#  # Flutter.framework does not contain a i386 slice.
#  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
#  s.swift_version = '5.0'
#end

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_uni_applet.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_uni_applet'
  s.version          = '0.0.1'
  s.summary          = 'A uni applet Flutter plugin.'
  s.description      = <<-DESC
A uni applet Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.*', 'UniMP/Core/Headers/**/*.*'
  s.public_header_files = 'UniMP/Core/Headers/**/*.h'
  s.static_framework = true
  s.frameworks = 'JavaScriptCore', 'CoreMedia', 'MediaPlayer', 'AVFoundation', 'AVKit', 'GLKit', 'OpenGLES', 'CoreText', 'QuartzCore', 'CoreGraphics', 'QuickLook', 'CoreTelephony'
  s.libraries = 'c++', 'iconv'
  s.vendored_frameworks = 'UniMP/Core/Libs/*.framework'
  s.vendored_libraries = 'UniMP/Core/Libs/*.a'
  s.resources = "UniMP/Core/Resources/*.*"

  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
