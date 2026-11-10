#!/usr/bin/env ruby
require 'xcodeproj'
require 'fileutils'

root = File.expand_path('../qa/pkr0205_upgrade_hosted', __dir__)
FileUtils.mkdir_p(root)
path = File.join(root, 'PKR0205UpgradeNative.xcodeproj')
abort('QA project already exists') if File.exist?(path)
project = Xcodeproj::Project.new(path)
target = project.new_target(:ui_test_bundle, 'PKR0205UpgradeNativeUITests', :ios, '15.0')
target.build_configurations.each do |config|
  config.build_settings.merge!({
    'SWIFT_VERSION' => '5.0',
    'PRODUCT_BUNDLE_IDENTIFIER' => 'org.sharky.pkr0205.upgrade.uitests',
    'IPHONEOS_DEPLOYMENT_TARGET' => '15.0',
    'TARGETED_DEVICE_FAMILY' => '1',
    'GENERATE_INFOPLIST_FILE' => 'YES',
    'CODE_SIGNING_ALLOWED' => 'NO',
    'ENABLE_TESTABILITY' => 'YES'
  })
end
group = project.main_group.new_group('PKR0205UpgradeNativeUITests')
file = group.new_file(File.expand_path('../qa/PKR0205UpgradeNativeUITests.swift', __dir__))
target.source_build_phase.add_file_reference(file)
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.add_test_target(target)
scheme.save_as(path, 'PKR0205UpgradeNativeUITests', true)
puts "PKR0205_UPGRADE_UI_TEST_ONLY_PROJECT=#{path}"
