# Podfile for mParticle-AppsFlyer framework target.
# Run `pod install` to fetch dependencies and open mParticle-AppsFlyer.xcworkspace to build.
# Use script/build_xcframework.sh to produce mParticle_AppsFlyer.framework.zip and mParticle_AppsFlyer.xcframework.zip.

platform :ios, '12.0'
use_frameworks! :linkage => :static

workspace 'mParticle-AppsFlyer'
project 'mParticle-AppsFlyer.xcodeproj'

target 'mParticle-AppsFlyer' do
  project 'mParticle-AppsFlyer.xcodeproj'
  pod 'mParticle-Apple-SDK/mParticleNoLocation', '~> 8.19'
  pod 'AppsFlyerFramework', '~> 6.16'
end

target 'mParticle_AppsFlyerTests' do
  project 'mParticle-AppsFlyer.xcodeproj'
  pod 'OCMock', '~> 3.9'
end
