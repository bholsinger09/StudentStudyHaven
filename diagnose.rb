#!/usr/bin/env ruby
require 'fileutils'

puts "=" * 80
puts "COMPREHENSIVE STUDYGROUPS TROUBLESHOOTING"
puts "=" * 80
puts

# Step 1: Check if debug code exists
puts "1. Checking for debug logging in GroupMembersView..."
detail_view = File.read('Sources/StudyGroups/Presentation/Views/StudyGroupDetailView.swift')

if detail_view.include?('👥 GroupMembersView INIT')
  puts "   ✅ Debug logging PRESENT in GroupMembersView init"
else
  puts "   ❌ Debug logging MISSING from GroupMembersView init"
end

if detail_view.include?('DEBUG INFO')
  puts "   ✅ DEBUG INFO section PRESENT"
else
  puts "   ❌ DEBUG INFO section MISSING"
end

if detail_view.include?('Manage Members')
  puts "   ✅ Manage Members section PRESENT"
else
  puts "   ❌ Manage Members section MISSING"
end

puts

# Step 2: Check RootView passes use cases
puts "2. Checking if RootView passes use cases to StudyGroupsView..."
root_view_sources = File.read('Sources/App/RootView.swift')
root_view_xcode = File.read('StudentStudyHaven/StudentStudyHaven/RootView.swift')

sources_has_use_cases = root_view_sources.include?('searchUsersUseCase: SearchUsersUseCase') &&
                       root_view_sources.include?('inviteUserToGroupUseCase: InviteUserToGroupUseCase')
xcode_has_use_cases = root_view_xcode.include?('searchUsersUseCase: SearchUsersUseCase') &&
                      root_view_xcode.include?('inviteUserToGroupUseCase: InviteUserToGroupUseCase')

puts "   Sources/App/RootView.swift: #{sources_has_use_cases ? '✅ HAS use cases' : '❌ MISSING use cases'}"
puts "   Xcode/RootView.swift: #{xcode_has_use_cases ? '✅ HAS use cases' : '❌ MISSING use cases'}"

if !xcode_has_use_cases
  puts "   ⚠️  WARNING: Xcode RootView.swift needs to be synced!"
end

puts

# Step 3: Check file timestamps
puts "3. Checking file modification times..."
require 'time'

source_file = 'Sources/StudyGroups/Presentation/Views/StudyGroupDetailView.swift'
source_time = File.mtime(source_file)

puts "   StudyGroupDetailView.swift: #{source_time}"
puts "   (Last modified #{((Time.now - source_time) / 60).round} minutes ago)"

puts

# Step 4: Build status
puts "4. Building Swift package..."
build_result = `swift build 2>&1`
if $?.success?
  puts "   ✅ Build SUCCESSFUL"
else
  puts "   ❌ Build FAILED"
  puts build_result.lines.grep(/error/).first(5)
end

puts

# Step 5: Count files that need syncing
puts "5. Checking for file synchronization..."
needs_sync = false

['AppState.swift', 'DependencyContainer.swift', 'HomeView.swift', 
 'ProfileView.swift', 'ProfileViewModel.swift', 'RootView.swift', 
 'StudentStudyHavenApp.swift'].each do |file|
  
  source = File.read("Sources/App/#{file}")
  target = File.read("StudentStudyHaven/StudentStudyHaven/#{file}")
  
  if source != target
    puts "   ⚠️  #{file} - DIFFERS (needs sync)"
    needs_sync = true
  else
    puts "   ✅ #{file} - synced"
  end
end

puts

# Final recommendation
puts "=" * 80
puts "DIAGNOSIS & NEXT STEPS"
puts "=" * 80
puts

if needs_sync
  puts "❌ PROBLEM: Files are out of sync!"
  puts ""
  puts "SOLUTION:"
  puts "  1. Run: ruby sync_to_xcode.rb"
  puts "  2. In Xcode: Product → Clean Build Folder (Cmd+Shift+K)"
  puts "  3. In Xcode: Product → Build (Cmd+B)"
  puts "  4. In Xcode: Product → Run (Cmd+R)"
elsif !xcode_has_use_cases
  puts "❌ PROBLEM: Xcode RootView missing use case initialization!"
  puts ""
  puts "SOLUTION: Re-run sync script, then rebuild in Xcode"
else
  puts "✅ CODE APPEARS CORRECT"
  puts ""
  puts "If the button still doesn't appear:"
  puts "1. Force quit the app on your device"
  puts "2. In Xcode: Product → Clean Build Folder"
  puts "3. Delete derived data: rm -rf ~/Library/Developer/Xcode/DerivedData/*"
  puts "4. Build and run fresh"
  puts "5. Check Xcode console for logs starting with:"
  puts "   - 🔍 StudyGroupDetailView INIT"
  puts "   - 👥 GroupMembersView INIT"
  puts ""
  puts "If NO logs appear, the view might not be loading from the package."
  puts "Check Xcode's build settings and make sure StudyGroups framework is linked."
end

puts
