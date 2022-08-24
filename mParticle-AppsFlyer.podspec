Pod::Spec.new do |s|
    s.name             = "mParticle-AppsFlyer"
    s.version          = "8.1.0"
    s.summary          = "AppsFlyer integration for mParticle"

    s.description      = <<-DESC
                       This is the AppsFlyer integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-appsflyer.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"
    
    s.static_framework = true

    s.ios.deployment_target = "9.0"
    s.ios.source_files      = 'Sources/**/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.0'
    s.ios.dependency 'AppsFlyerFramework', '~> 6.8'

    s.ios.pod_target_xcconfig = {
        'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/AppsFlyerFramework/**',
        'OTHER_LDFLAGS' => '$(inherited) -framework "AppsFlyerLib"'
    }
end
