#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flama_flutter_libs.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flama_flutter_libs'
  s.version          = '0.0.1'
  s.summary          = 'llama.cpp libs for flutter'

  s.homepage         = 'https://github.com/luiscib3r/flama'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Luis Ciber' => 'luisciber640@gmail.com' }

  s.source           = { :path => '.' }
  s.public_header_files = 'Classes/**/*.h'
  s.source_files = 'Classes/**/*'
 
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'
  s.swift_version = '5.0'
  s.static_framework = true
  s.xcconfig = { 
    'OTHER_LDFLAGS' => '-framework Accelerate'
  }
  s.vendored_frameworks = 'llama.xcframework'
end
