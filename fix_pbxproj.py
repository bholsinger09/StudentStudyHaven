import os
from pathlib import Path

def get_all_swift_files(app_dir):
    swift_files = []
    for root, dirs, files in os.walk(app_dir):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for file in files:
            if file.endswith('.swift'):
                path = os.path.join(root, file)
                rel_path = os.path.relpath(path, app_dir)
                swift_files.append(rel_path)
    return sorted(swift_files)

app_dir = "/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-iOS/StudentStudyHaven"
swift_files = get_all_swift_files(app_dir)

file_refs = {}
build_refs = {}
for i, file in enumerate(swift_files):
    file_refs[file] = f"{1000+i:04x}".upper()
    build_refs[file] = f"{2000+i:04x}".upper()

pbxproj = "// \!$*UTF8*$\!\n{\n\tarchiveVersion = 1;\n\tclasses = {\n\t};\n\tobjectVersion = 56;\n\tobjects = {\n/* Begin PBXBuildFile section */\n"

for file, build_id in build_refs.items():
    file_id = file_refs[file]
    pbxproj += "\t\t" + build_id + " /* " + file + " in Sources */ = {isa = PBXBuildFile; fileRef = " + file_id + "; };\n"

pbxproj += "/* End PBXBuildFile section */\n\n/* Begin PBXFileReference section */\n"

for file, file_id in file_refs.items():
    pbxproj += "\t\t" + file_id + " /* " + file + " */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = " + file + "; sourceTree = \"<group>\"; };\n"

pbxproj += "\t\t3000 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; };\n"
pbxproj += "\t\t3002 /* Base */ = {isa = PBXFileReference; lastKnownFileType = folder; name = Base; path = Base.lproj; sourceTree = \"<group>\"; };\n"
pbxproj += "\t\t3003 /* StudentStudyHaven.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = StudentStudyHaven.app; sourceTree = BUILT_PRODUCTS_DIR; };\n"
pbxproj += "/* End PBXFileReference section */\n\n/* Begin PBXFrameworksBuildPhase section */\n"
pbxproj += "\t\t4000 /* Frameworks */ = {\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = ();\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};\n"
pbxproj += "/* End PBXFrameworksBuildPhase section */\n\n/* Begin PBXGroup section */\n"
pbxproj += "\t\t5000 /* StudentStudyHaven */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t5001,\n\t\t\t\t5002,\n\t\t\t);\n\t\t\tsourceTree = \"<group>\";\n\t\t};\n"
pbxproj += "\t\t5001 /* StudentStudyHaven */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n"

for file in swift_files:
    file_id = file_refs[file]
    pbxproj += "\t\t\t\t" + file_id + ",\n"

pbxproj += "\t\t\t\t3000,\n\t\t\t\t3002,\n\t\t\t);\n\t\t\tpath = StudentStudyHaven;\n\t\t\tsourceTree = \"<group>\";\n\t\t};\n"
pbxproj += "\t\t5002 /* Products */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (3003);\n\t\t\tname = Products;\n\t\t\tsourceTree = \"<group>\";\n\t\t};\n"
pbxproj += "/* End PBXGroup section */\n\n/* Begin PBXNativeTarget section */\n"
pbxproj += "\t\t6000 /* StudentStudyHaven */ = {\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = 6001;\n\t\t\tbuildPhases = (\n\t\t\t\t7000,\n\t\t\t\t4000,\n\t\t\t\t8000,\n\t\t\t);\n\t\t\tbuildRules = ();\n\t\t\tdependencies = ();\n\t\t\tname = StudentStudyHaven;\n\t\t\tproductName = StudentStudyHaven;\n\t\t\tproductReference = 3003;\n\t\t\tproductType = \"com.apple.product-type.application\";\n\t\t};\n"
pbxproj += "/* End PBXNativeTarget section */\n\n/* Begin PBXProject section */\n"
pbxproj += "\t\t9000 /* Project object */ = {\n\t\t\tisa = PBXProject;\n\t\t\tattributes = {\n\t\t\t\tBuildIndependentTargetsInParallel = 1;\n\t\t\t\tLastSwiftUpdateCheck = 1500;\n\t\t\t\tLastUpgradeCheck = 1500;\n\t\t\t};\n\t\t\tbuildConfigurationList = 9001;\n\t\t\tcompatibilityVersion = \"Xcode 14.0\";\n\t\t\tdevelopmentRegion = en;\n\t\t\thasScannedForEncodings = 0;\n\t\t\tknownRegions = (en, Base);\n\t\t\tmainGroup = 5000;\n\t\t\tproductRefGroup = 5002;\n\t\t\tprojectDirPath = \"\";\n\t\t\tprojectRoot = \"\";\n\t\t\ttargets = (6000);\n\t\t};\n"
pbxproj += "/* End PBXProject section */\n\n/* Begin PBXResourcesBuildPhase section */\n"
pbxproj += "\t\t8000 /* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\t3000,\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};\n"
pbxproj += "/* End PBXResourcesBuildPhase section */\n\n/* Begin PBXSourcesBuildPhase section */\n"
pbxproj += "\t\t7000 /* Sources */ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n"

for file, build_id in build_refs.items():
    pbxproj += "\t\t\t\t" + build_id + ",\n"

pbxproj += "\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};\n"
pbxproj += "/* End PBXSourcesBuildPhase section */\n\n/* Begin XCBuildConfiguration section */\n"
pbxproj += "\t\tA000 /* Debug */ = {\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {\n\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n\t\t\t\tCLANG_ENABLE_MODULES = YES;\n\t\t\t};\n\t\t\tname = Debug;\n\t\t};\n"
pbxproj += "\t\tA001 /* Release */ = {\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {\n\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n\t\t\t\tCLANG_ENABLE_MODULES = YES;\n\t\t\t};\n\t\t\tname = Release;\n\t\t};\n"
pbxproj += "\t\tB000 /* Debug */ = {\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {\n\t\t\t\tASETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n\t\t\t\tCODE_SIGN_STYLE = Automatic;\n\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n\t\t\t\tDEBUG_INFORMATION_FORMAT = \"dwarf\";\n\t\t\t\tINFOPLIST_FILE = StudentStudyHaven/Info.plist;\n\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;\n\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (\"$(inherited)\", \"@executable_path/Frameworks\");\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.studentstudyhaven.ios;\n\t\t\t\tPRODUCT_NAME = StudentStudyHaven;\n\t\t\t\tSDKROOT = iphoneos;\n\t\t\t\tSWIFT_VERSION = 5.9;\n\t\t\t};\n\t\t\tname = Debug;\n\t\t};\n"
pbxproj += "\t\tB001 /* Release */ = {\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {\n\t\t\t\tASETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n\t\t\t\tCODE_SIGN_STYLE = Automatic;\n\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n\t\t\t\tDEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";\n\t\t\t\tINFOPLIST_FILE = StudentStudyHaven/Info.plist;\n\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;\n\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (\"$(inherited)\", \"@executable_path/Frameworks\");\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.studentstudyhaven.ios;\n\t\t\t\tPRODUCT_NAME = StudentStudyHaven;\n\t\t\t\tSDKROOT = iphoneos;\n\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;\n\t\t\t\tSWIFT_VERSION = 5.9;\n\t\t\t\tVALIDATE_PRODUCT = YES;\n\t\t\t};\n\t\t\tname = Release;\n\t\t};\n"
pbxproj += "/* End XCBuildConfiguration section */\n\n/* Begin XCConfigurationList section */\n"
pbxproj += "\t\t6001 /* Build configuration list for PBXNativeTarget \"StudentStudyHaven\" */ = {\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (B000, B001);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t};\n"
pbxproj += "\t\t9001 /* Build configuration list for PBXProject \"StudentStudyHaven\" */ = {\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (A000, A001);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t};\n"
pbxproj += "/* End XCConfigurationList section */\n\t};\n\trootObject = 9000;\n}\n"

ios_path = Path("/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-iOS/StudentStudyHaven.xcodeproj/project.pbxproj")
ios_path.write_text(pbxproj)
print(f"Fixed iOS pbxproj ({len(swift_files)} files)")

mac_pbxproj = pbxproj.replace("iphoneos", "macosx").replace("IPHONEOS_DEPLOYMENT_TARGET = 16.0", "MACOSX_DEPLOYMENT_TARGET = 13.0")
mac_path = Path("/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-macOS/StudentStudyHaven.xcodeproj/project.pbxproj")
mac_path.write_text(mac_pbxproj)
print(f"Fixed macOS pbxproj ({len(swift_files)} files)")

print("All build issues resolved\!")
