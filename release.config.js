module.exports = {
    branches: ["main"],
    tagFormat: "v${version}",
    plugins: [
      [
        "@semantic-release/commit-analyzer",
        {
          preset: "angular",
        },
      ],
      [
        "@semantic-release/release-notes-generator",
        {
          preset: "angular",
        },
      ],
      [
        "@semantic-release/changelog",
        {
          changelogFile: "CHANGELOG.md",
        },
      ],
      [
        "@semantic-release/exec",
        {
          prepareCmd: "sh ./Scripts/release.sh ${nextRelease.version} \"${nextRelease.notes}\"",
        },
      ],
      [
        "@semantic-release/github",
        {
          assets: [
            "mParticle_AppsFlyer.framework.zip",
            "mParticle_AppsFlyer.xcframework.zip",
            "generated-docs.zip",
          ],
        },
      ],
    ],
  };
