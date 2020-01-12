ARCHS := armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MicroPlayer12Prefs
MicroPlayer12Prefs_FILES = KBMainPrefPage.m
MicroPlayer12Prefs_INSTALL_PATH = /Library/PreferenceBundles
MicroPlayer12Prefs_FRAMEWORKS = UIKit
MicroPlayer12Prefs_PRIVATE_FRAMEWORKS = Preferences
MicroPlayer12Prefs_EXTRA_FRAMEWORKS += KBPreferences KBAppList

MicroPlayer12Prefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MicroPlayer12Prefs.plist$(ECHO_END)