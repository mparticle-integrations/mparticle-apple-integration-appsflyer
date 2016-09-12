Pod::Spec.new do |s|
    s.name             = "mParticle-AppsFlyer"
    s.version          = "6.8.0"
    s.summary          = "AppsFlyer integration for mParticle"

    s.description      = <<-DESC
                       This is the AppsFlyer integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-appsflyer.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"
    s.default_subspec  = "DefaultVersion"

    def s.subspec_common(ss)
        ss.ios.deployment_target = "7.0"
        ss.ios.source_files      = 'mParticle-AppsFlyer/*.{h,m,mm}'
        ss.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 6.7'

        ss.ios.pod_target_xcconfig = {
            'LIBRARY_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/AppsFlyer-SDK/**',
            'OTHER_LDFLAGS' => '$(inherited) -l"AppsFlyerLib"'
        }
    end

    s.subspec 'DefaultVersion' do |ss|
        ss.ios.dependency 'AppsFlyer-SDK', '4.5.3'
        s.subspec_common(ss)
    end

    s.subspec 'UserDefinedVersion' do |ss|
        ss.ios.dependency 'AppsFlyer-SDK'
        s.subspec_common(ss)
    end

end
