#!/usr/bin/env ruby

puts "=" * 80
puts "CHECKING FOR DUPLICATE VIEW FILES IN XCODE PROJECT"
puts "=" * 80
puts

require 'find'

# Search for any Swift files in StudentStudyHaven directory that might override package
xcode_swift_files = []
Find.find('StudentStudyHaven') do |path|
  if path.end_with?('.swift') && File.file?(path)
    xcode_swift_files << path
  end
end

puts "Swift files in Xcode app directory:"
xcode_swift_files.sort.each do |file|
  basename = File.basename(file)
  puts "  - #{file}"
  
  # Check if there's a corresponding file in Sources that might be shadowed
  content = File.read(file)
  if content.include?('StudyGroupDetailView') || content.include?('GroupMembersView')
    puts "    ⚠️  THIS FILE CONTAINS STUDYGROUP VIEWS - PROBLEM!"
  end
end

puts
puts "=" * 80
puts "CHECKING IF XCODE PROJECT REFERENCES SWIFT PACKAGE"
puts "=" * 80
puts

# Look for Package.resolved in Xcode project
if File.exist?('StudentStudyHaven.xcworkspace/xcshareddata/swiftpm/Package.resolved')
  puts "✅ Package.resolved exists in workspace"
  resolved = File.read('StudentStudyHaven.xcworkspace/xcshareddata/swiftpm/Package.resolved')
  
  # Check if it's being used
  if resolved.include?('firebase')
    puts "✅ Firebase dependencies resolved"
  else
    puts "❌ Firebase not in resolved dependencies!"
  end
else
  puts "❌ Package.resolved NOT FOUND in workspace!"
  puts "   This means Xcode workspace isn't using Swift Package Manager"
end

puts
puts "Checking for .xcworkspace references..."
if File.exist?('StudentStudyHaven.xcworkspace/contents.xcworkspacedata')
  workspace_data = File.read('StudentStudyHaven.xcworkspace/contents.xcworkspacedata')
  puts "Workspace contents:"
  puts workspace_data
end

puts
puts "=" * 80
puts "DIAGNOSIS"
puts "=" * 80
puts

if xcode_swift_files.any? { |f| File.read(f).include?('GroupMembersView') }
  puts "❌ CRITICAL: Xcode project has its own copy of GroupMembersView!"
  puts "   This is shadowing the package version."
  puts ""
  puts "SOLUTION: We need to ensure Xcode uses the Swift Package, not local copies."
else
  puts "✅ No duplicate view files found."
  puts ""
  puts "PROBLEM: Xcode isn't linking to the Swift Package properly."
  puts ""
  puts "SOLUTION: The project needs to be configured to use Swift Package Manager."
end
