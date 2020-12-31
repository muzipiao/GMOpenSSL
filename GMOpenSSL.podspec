#
# Be sure to run `pod lib lint GMOpenSSL.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GMOpenSSL'
  s.version          = '2.2.1'
  s.summary          = '编译 OpenSSL 为 framework，版本对应 OpenSSL 1.1.1i。'

  s.description      = <<-DESC
通过 cocoapods 集成 OpenSSL，编译为 framework，方便使用。
                       DESC

  s.homepage         = 'https://github.com/muzipiao/GMOpenSSL'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lifei' => 'lifei_zdjl@126.com' }
  s.source           = { :git => 'https://github.com/muzipiao/GMOpenSSL.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.preserve_paths = 'GMOpenSSL/openssl.framework'
  s.source_files = 'GMOpenSSL/openssl.framework/Headers/**/*{.h}'
  s.public_header_files = 'GMOpenSSL/openssl.framework/Headers/*.{h}'
  s.frameworks = 'Foundation'
  s.vendored_frameworks = 'GMOpenSSL/openssl.framework'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
end
