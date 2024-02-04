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
  s.source_files     = 'Classes/**/*'
  
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.11'
  s.swift_version = '5.3'
  s.vendored_libraries  = 'libllama.dylib'
end
