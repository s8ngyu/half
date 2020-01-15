ifeq ($(SIMULATOR),1)
ARCHS = x86_64
TARGET = simulator:clang::7.0
else
ARCHS = arm64 arm64e
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = half
half_FILES = Tweak.xm InvertedMaskLabel.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

after-all::
ifeq ($(SIMULATOR),1)
	rm /opt/simject/$(TWEAK_NAME).dylib
	cp .theos/obj/iphone_simulator/debug/$(TWEAK_NAME).dylib /opt/simject/
	../../simject/bin/resim
endif