# semantic_version.cr
require "spec"
require "../helper"
require "semantic_version"
# semantic_version.cr:1 (001)
# EXAMPLE_SEQ=1
# require "semantic_version"

current_version = SemanticVersion.new 1, 1, 1, "rc"
( __sort_ivars__(__demodulize__(( current_version.copy_with(patch: 2) ).inspect)) ).should eq( "SemanticVersion(@build=nil, @major=1, @minor=1, @patch=2, @prerelease=SemanticVersion::Prerelease(@identifiers=[\"rc\"]))" )
( __sort_ivars__(__demodulize__(( current_version.copy_with(prerelease: nil) ).inspect)) ).should eq( "SemanticVersion(@build=nil, @major=1, @minor=1, @patch=2, @prerelease=SemanticVersion::Prerelease(@identifiers=[]))" )
puts "TEST_PASSED_SEQ=1" # :nocode:

