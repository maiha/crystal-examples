  # ```
  # require "semantic_version"
  #
  # current_version = SemanticVersion.new 1, 1, 1, "rc"
  # current_version.copy_with(patch: 2) # => SemanticVersion(@build=nil, @major=1, @minor=1, @patch=2, @prerelease=SemanticVersion::Prerelease(@identifiers=["rc"]))
  # current_version.copy_with(prerelease: nil) # => SemanticVersion(@build=nil, @major=1, @minor=1, @patch=2, @prerelease=SemanticVersion::Prerelease(@identifiers=[]))
  # ```
