#!/usr/bin/env ruby
require 'xcodeproj'
require 'fileutils'

root = File.expand_path('../qa/s12_hosted', __dir__)
FileUtils.mkdir_p(root)
project_path = File.join(root, 'S12GenuineNative.xcodeproj')
abort('QA project path already exists') if File.exist?(project_path)
project = Xcodeproj::Project.new(project_path)
target = project.new_target(:ui_test_bundle, 'S12GenuineNativeUITests', :ios, '15.0')
target.build_configurations.each do |config|
  config.build_settings.merge!({
    'SWIFT_VERSION' => '5.0',
    'PRODUCT_BUNDLE_IDENTIFIER' => 'org.sharky.s12.hosted.uitests',
    'IPHONEOS_DEPLOYMENT_TARGET' => '15.0',
    'TARGETED_DEVICE_FAMILY' => '1',
    'GENERATE_INFOPLIST_FILE' => 'YES',
    'CODE_SIGNING_ALLOWED' => 'NO',
    'ENABLE_TESTABILITY' => 'YES'
  })
end
group = project.main_group.new_group('S12GenuineNativeUITests')
file = group.new_file(File.expand_path('../qa/T2SBStageAOneSeatNativeUITests.swift', __dir__))
target.source_build_phase.add_file_reference(file)
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.add_test_target(target)
scheme.save_as(project_path, 'S12GenuineNativeUITests', true)
puts "S11_HOSTED_XCODEPROJECT_CREATED=#{project_path}"
puts 'ONLY UI-TEST TARGET; NO PRODUCT APPLICATION BUILD'
