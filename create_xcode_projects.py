#\!/usr/bin/env python3
import os
from pathlib import Path

def create_pbxproj(project_type, project_path):
    """Create a basic xcodeproj structure"""
    proj_dir = Path(project_path) / "StudentStudyHaven.xcodeproj"
    proj_dir.mkdir(parents=True, exist_ok=True)
    
    pbxproj_path = proj_dir / "project.pbxproj"
    
    if project_type == "ios":
        app_identifier = "com.studentstudyhaven.ios"
        min_deployment = "16.0"
        platform = "iphoneos"
    else:
        app_identifier = "com.studentstudyhaven.macos"
        min_deployment = "13.0"
        platform = "macosx"
    
    content = """// \!$*UTF8*$\!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
		123ABC001 /* StudentStudyHaven */ = {isa = PBXGroup; children = (); name = StudentStudyHaven; sourceTree = "<group>"; };
	};
	rootObject = 123ABC001;
}
"""
    pbxproj_path.write_text(content)
    print(f"✅ Created {pbxproj_path}")

create_pbxproj("ios", "/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-iOS")
create_pbxproj("macos", "/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-macOS")
print("✅ Xcode project files created\!")
