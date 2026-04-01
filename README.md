## AppsFlyer Kit Integration

This repository contains the [AppsFlyer](https://www.appsflyer.com) integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

### Building the framework (fat .framework.zip and XCFramework)

To build the kit and produce both archives from the repo root:

1. Install CocoaPods dependencies (generates `mParticle-AppsFlyer.xcworkspace`):
   ```bash
   pod install
   ```
2. Run the build script:
   ```bash
   ./script/build_xcframework.sh
   ```
   Output in the repo root:
   - `mParticle_AppsFlyer.framework.zip` — fat (universal) framework (device + simulator)
   - `mParticle_AppsFlyer.xcframework.zip` — XCFramework (device and simulator slices; preferred for App Store)

Open `mParticle-AppsFlyer.xcworkspace` (not the `.xcodeproj`) when building or testing from Xcode.

### Adding the integration

1. Add the kit dependency to your app's Podfile or Cartfile:

    ```
    pod 'mParticle-AppsFlyer', '~> 8'
    ```

    OR

    ```
    github "mparticle-integrations/mparticle-apple-integration-appsflyer" ~> 8.0
    ```

2. Follow the mParticle iOS SDK [quick-start](https://github.com/mParticle/mparticle-apple-sdk), then rebuild and launch your app, and verify that you see `"Included kits: { AppsFlyer }"` in your Xcode console 

> (This requires your mParticle log level to be at least Debug)

3. Reference mParticle's integration docs below to enable the integration.

### Documentation

[AppsFlyer integration](https://docs.mparticle.com/integrations/appsflyer/event/)

### License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
