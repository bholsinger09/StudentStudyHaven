#\!/usr/bin/env python3
from pathlib import Path

pbxproj_content = """// \!$*UTF8*$\!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
/* Begin PBXBuildFile section */
		07D0 /* AppState.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03E8; };
		07D1 /* Components/ErrorView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03E9; };
		07D2 /* Components/LoadingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03EA; };
		07D3 /* DependencyContainer.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03EB; };
		07D4 /* HomeView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03EC; };
		07D5 /* Onboarding/CollegeSelectionView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03ED; };
		07D6 /* Onboarding/OnboardingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03EE; };
		07D7 /* ProfileView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03EF; };
		07D8 /* ProfileViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03F0; };
		07D9 /* RootView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03F1; };
		07DA /* Settings/SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03F2; };
		07DB /* StudentStudyHavenApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 03F3; };
		3000A /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 3000; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		03E8 /* AppState.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppState.swift; sourceTree = "<group>"; };
		03E9 /* Components/ErrorView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Components/ErrorView.swift; sourceTree = "<group>"; };
		03EA /* Components/LoadingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Components/LoadingView.swift; sourceTree = "<group>"; };
		03EB /* DependencyContainer.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DependencyContainer.swift; sourceTree = "<group>"; };
		03EC /* HomeView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeView.swift; sourceTree = "<group>"; };
		03ED /* Onboarding/CollegeSelectionView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Onboarding/CollegeSelectionView.swift; sourceTree = "<group>"; };
		03EE /* Onboarding/OnboardingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Onboarding/OnboardingView.swift; sourceTree = "<group>"; };
		03EF /* ProfileView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProfileView.swift; sourceTree = "<group>"; };
		03F0 /* ProfileViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProfileViewModel.swift; sourceTree = "<group>"; };
		03F1 /* RootView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RootView.swift; sourceTree = "<group>"; };
		03F2 /* Settings/SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Settings/SettingsView.swift; sourceTree = "<group>"; };
		03F3 /* StudentStudyHavenApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StudentStudyHavenApp.swift; sourceTree = "<group>"; };
		3000 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		3002 /* Base */ = {isa = PBXFileReference; lastKnownFileType = folder; name = Base; path = Base.lproj; sourceTree = "<group>"; };
		3003 /* StudentStudyHaven.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = StudentStudyHaven.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		4000 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = ();
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		5000 /* StudentStudyHaven */ = {
			isa = PBXGroup;
			children = (
				5001,
				5002,
			);
			sourceTree = "<group>";
		};
		5001 /* StudentStudyHaven */ = {
			isa = PBXGroup;
			children = (
				03E8,
				03E9,
				03EA,
				03EB,
				03EC,
				03ED,
				03EE,
				03EF,
				03F0,
				03F1,
				03F2,
				03F3,
				3000,
				3002,
			);
			path = StudentStudyHaven;
			sourceTree = "<group>";
		};
		5002 /* Products */ = {
			isa = PBXGroup;
			children = (3003);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		6000 /* StudentStudyHaven */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 6001;
			buildPhases = (
				7000,
				4000,
				8000,
			);
			buildRules = ();
			dependencies = ();
			name = StudentStudyHaven;
			productName = StudentStudyHaven;
			productReference = 3003;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		9000 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = 9001;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (en, Base);
			mainGroup = 5000;
			productRefGroup = 5002;
			projectDirPath = "";
			projectRoot = "";
			targets = (6000);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		8000 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				3000A,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		7000 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				07D0,
				07D1,
				07D2,
				07D3,
				07D4,
				07D5,
				07D6,
				07D7,
				07D8,
				07D9,
				07DA,
				07DB,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		A000 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
			};
			name = Debug;
		};
		A001 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
			};
			name = Release;
		};
		B000 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = dwarf;
				INFOPLIST_FILE = StudentStudyHaven/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.studentstudyhaven.ios;
				PRODUCT_NAME = StudentStudyHaven;
				SDKROOT = iphoneos;
				SWIFT_VERSION = 5.9;
			};
			name = Debug;
		};
		B001 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				INFOPLIST_FILE = StudentStudyHaven/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.studentstudyhaven.ios;
				PRODUCT_NAME = StudentStudyHaven;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_VERSION = 5.9;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		6001 /* Build configuration list for PBXNativeTarget "StudentStudyHaven" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				B000,
				B001,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		9001 /* Build configuration list for PBXProject "StudentStudyHaven" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A000,
				A001,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 9000;
}
"""

# Write the clean pbxproj
ios_pbxproj = Path("/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-iOS/StudentStudyHaven.xcodeproj/project.pbxproj")
ios_pbxproj.write_text(pbxproj_content)
print("iOS pbxproj fixed")

# Do the same for macOS
mac_pbxproj_content = pbxproj_content.replace("iphoneos", "macosx").replace("IPHONEOS_DEPLOYMENT_TARGET", "MACOSX_DEPLOYMENT_TARGET")
mac_pbxproj = Path("/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-macOS/StudentStudyHaven.xcodeproj/project.pbxproj")
mac_pbxproj.write_text(mac_pbxproj_content)
print("macOS pbxproj fixed")

print("Done\! File is now valid")
