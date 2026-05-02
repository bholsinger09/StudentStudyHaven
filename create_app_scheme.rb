#!/usr/bin/env ruby

require 'fileutils'

puts "=" * 80
puts "CREATING APP SCHEME FOR XCODE PROJECT"
puts "=" * 80
puts ""

PROJECT_DIR = "StudentStudyHaven.xcodeproj"
SCHEME_DIR = "#{PROJECT_DIR}/xcshareddata/xcschemes"

FileUtils.mkdir_p(SCHEME_DIR)

# Read the project.pbxproj to get the target ID
pbxproj_content = File.read("#{PROJECT_DIR}/project.pbxproj")

# Extract target ID
target_id = pbxproj_content.match(/([A-F0-9]{24}) \/\* StudentStudyHaven \*\/ = \{\s*isa = PBXNativeTarget;/)[1]
project_id = pbxproj_content.match(/([A-F0-9]{24}) \/\* Project object \*\/ = \{/)[1]

puts "Target ID: #{target_id}"
puts "Project ID: #{project_id}"

# Create StudentStudyHaven.xcscheme
scheme_content = <<~SCHEME
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "#{target_id}"
               BuildableName = "StudentStudyHaven.app"
               BlueprintName = "StudentStudyHaven"
               ReferencedContainer = "container:StudentStudyHaven.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "#{target_id}"
            BuildableName = "StudentStudyHaven.app"
            BlueprintName = "StudentStudyHaven"
            ReferencedContainer = "container:StudentStudyHaven.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "#{target_id}"
            BuildableName = "StudentStudyHaven.app"
            BlueprintName = "StudentStudyHaven"
            ReferencedContainer = "container:StudentStudyHaven.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
SCHEME

File.write("#{SCHEME_DIR}/StudentStudyHaven.xcscheme", scheme_content)

puts "✅ Created StudentStudyHaven.xcscheme"
puts ""
puts "=" * 80
puts "SCHEME CREATED!"
puts "=" * 80
puts ""
puts "Close and reopen Xcode:"
puts "1. Quit Xcode (Cmd+Q)"
puts "2. Run: open StudentStudyHaven.xcworkspace"
puts "3. You should now see 'StudentStudyHaven' in the scheme dropdown"
puts "4. Select your iPhone as destination"
puts "5. Press Cmd+R to run!"
puts ""
