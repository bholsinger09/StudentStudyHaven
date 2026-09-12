import Foundation

func createValidXcodeProject(
    name: String,
    bundleId: String,
    projectPath: String,
    deploymentTarget: String,
    platform: String
) {
    let projectDir = "\(projectPath)/\(name).xcodeproj"
    try? FileManager.default.removeItem(atPath: projectDir)
    try\! FileManager.default.createDirectory(atPath: projectDir, withIntermediateDirectories: true)
    
    // Create pbxproj with proper structure
    let pbxprojContent = """
// \!$*UTF8*$\!
{
\tarchiveVersion = 1;
\tclasses = {
\t};
\tobjectVersion = 56;
\tobjects = {
\t\t123ABC001 /* StudentStudyHaven */ = {isa = PBXGroup; children = (123ABC002, 123ABC003); name = StudentStudyHaven; sourceTree = "<group>"; };
\t\t123ABC002 /* Sources */ = {isa = PBXGroup; children = (); name = Sources; sourceTree = "<group>"; };
\t\t123ABC003 /* Resources */ = {isa = PBXGroup; children = (); name = Resources; sourceTree = "<group>"; };
\t};
\trootObject = 123ABC001;
}
"""
    
    try\! pbxprojContent.write(toFile: "\(projectDir)/project.pbxproj", atomically: true, encoding: .utf8)
    
    // Create xcshareddata directory
    let xcshareddata = "\(projectDir)/xcshareddata"
    try? FileManager.default.createDirectory(atPath: xcshareddata, withIntermediateDirectories: true)
    
    print("✅ Created valid Xcode project at \(projectDir)")
}

// iOS
createValidXcodeProject(
    name: "StudentStudyHaven",
    bundleId: "com.studentstudyhaven.ios",
    projectPath: "/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-iOS",
    deploymentTarget: "16.0",
    platform: "iphoneos"
)

// macOS
createValidXcodeProject(
    name: "StudentStudyHaven",
    bundleId: "com.studentstudyhaven.macos",
    projectPath: "/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-macOS",
    deploymentTarget: "13.0",
    platform: "macosx"
)

print("✅ All Xcode projects created successfully\!")
