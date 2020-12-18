#
# Be sure to run `pod lib lint HandyRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HandyRequest'
  s.version          = '0.0.3'
  s.summary          = 'Convenient network request, fast processing result.'
  s.description      = 'Quickly and quickly request processing of analytical data'

  s.homepage         = 'https://github.com/OrchidBloom/HandyRequest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'OrchidBloom' => 'temagsoft@gmail.com' }
  s.source           = { :git => 'https://github.com/OrchidBloom/HandyRequest.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'HandyRequest/Classes/**/*'
  s.dependency 'Moya', '~> 14.0.0'
  s.dependency 'RxSwift', '~> 5.1.1'
  s.dependency 'ObjectMapper', '~> 4.2.0'
  s.dependency 'SwiftyJSON', '~> 5.0'
end
