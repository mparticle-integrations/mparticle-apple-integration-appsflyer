Pod::Spec.new do |s|
    s.name             = "mParticle-AppsFlyer"
    s.version          = "7.3.6"
    s.summary          = "AppsFlyer integration for mParticle"

    s.description      = <<-DESC
                       This is the AppsFlyer integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-appsflyer.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-AppsFlyer/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 7.3.0'
    s.ios.dependency 'AppsFlyerFramework', '4.8.0'
    s.ios.pod_target_xcconfig = {
        'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/AppsFlyerFramework/**',
        'OTHER_LDFLAGS' => '$(inherited) -framework "AppsFlyerLib"'
    }
end
