ARCHS := armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MicroPlayer12
MicroPlayer12_FILES = MicroPlayer12.xm Classes/MPViewController.m Classes/MPBaseView.m Classes/PIWindow.m Classes/ScrollyLabel.m Classes/KBMediaViewController.m Classes/NSString+TimeToString.m Classes/KBTouchDownRecogniser.m Classes/KBForceTouchGestureRecognizer.m Classes/KBAppManager.m Classes/KBVolumeAnimation.m Classes/KBVolumeSlider.m Classes/PIUIImageView.m

MicroPlayer12_FRAMEWORKS= FrontBoard FrontBoardServices

MicroPlayer12_PRIVATE_FRAMEWORKS = MediaRemote BackBoardServices UIKit
MicroPlayer12_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += MicroPlayer12Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
