VERSION="$1"
PREFIXED_VERSION="v$1"
NOTES="$2"

# Update version number
#

# Update Carthage release json file
jq --indent 3 '. += {'"\"$VERSION\""': "'"https://github.com/mparticle-integrations/mparticle-apple-integration-appsflyer/releases/download/$PREFIXED_VERSION/mParticle_AppsFlyer.framework.zip?alt=https://github.com/mparticle-integrations/mparticle-apple-integration-appsflyer/releases/download/$PREFIXED_VERSION/mParticle_AppsFlyer.xcframework.zip"'"}'
mParticle_AppsFlyer.json > tmp.json
mv tmp.json mParticle_AppsFlyer.json

# Update CocoaPods podspec file
sed -i '' 's/\(^    s.version[^=]*= \).*/\1"'"$VERSION"'"/' mParticle-AppsFlyer.podspec

# Make the release commit in git
#

git add mParticle-AppsFlyer.podspec
git add mParticle_AppsFlyer.json
git add CHANGELOG.md
git commit -m "chore(release): $VERSION [skip ci]

$NOTES"
