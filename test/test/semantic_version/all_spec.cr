# semantic_version.cr
require "spec"
require "../helper"
require "semantic_version"
# semantic_version.cr:1 (001)
# EXAMPLE_SEQ=1
# require "semantic_version"

prerelease = SemanticVersion::Prerelease.parse("rc.1.3")
( __demodulize__(( prerelease ).inspect) ).should eq( "SemanticVersion::Prerelease(@identifiers=[\"rc\", 1, 3])" )
puts "TEST_PASSED_SEQ=1" # :nocode:

