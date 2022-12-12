require "semantic_version"
# semantic_version.cr:1 (001)
# EXAMPLE_SEQ=1
# semantic_version.cr:1
# require "semantic_version"

prerelease = SemanticVersion::Prerelease.parse("rc.1.3")
prerelease # => SemanticVersion::Prerelease(@identifiers=["rc", 1, 3])
