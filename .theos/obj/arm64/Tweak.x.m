#line 1 "Tweak.x"
#import "Tweak.h"

extern dispatch_queue_t __BBServerQueue;
static NSString *const kFlashNotifyBulletinID = @"com.greg0109.FlashNotify-ID";
static NSString *const kFlashNotifyBulletinAction = @"!com.greg0109.FlashNotify-Action";

PCSimpleTimer *timer;
BBServer *server;

BOOL enabled;
NSInteger remind;
BOOL charging;
NSInteger remindCharging;
BOOL autooff;
NSInteger autooffTimer;

static void removeBulletin() {
  if(server) {
    dispatch_async(__BBServerQueue, ^{
      [server withdrawBulletinRequestsWithPublisherBulletinID:kFlashNotifyBulletinID forSectionID:@"com.apple.Preferences"];
    });
  }
}


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class BBServer; @class BBBulletin; @class PCSimpleTimer; @class SBUIController; @class SBUIFlashlightController; 
static void (*_logos_orig$_ungrouped$SBUIController$playChargingChimeIfAppropriate)(_LOGOS_SELF_TYPE_NORMAL SBUIController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBUIController$playChargingChimeIfAppropriate(_LOGOS_SELF_TYPE_NORMAL SBUIController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$)(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$)(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST, SEL, id); static BBServer* (*_logos_orig$_ungrouped$BBServer$initWithQueue$)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static id (*_logos_orig$_ungrouped$BBBulletin$responseForAction$)(_LOGOS_SELF_TYPE_NORMAL BBBulletin* _LOGOS_SELF_CONST, SEL, BBAction *); static id _logos_method$_ungrouped$BBBulletin$responseForAction$(_LOGOS_SELF_TYPE_NORMAL BBBulletin* _LOGOS_SELF_CONST, SEL, BBAction *); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBUIFlashlightController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBUIFlashlightController"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$PCSimpleTimer(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("PCSimpleTimer"); } return _klass; }
#line 25 "Tweak.x"
static void sendNotif() {
  if (!autooff && remind) {
    BBBulletinRequest *bulletin = [[BBBulletinRequest alloc] init];
    bulletin.header = @"FLASHNOTIFY";
    bulletin.title = @"Your flashlight is still on";
    bulletin.message = @"Would you like to turn it off?";
    bulletin.sectionID = @"com.apple.Preferences";
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = kFlashNotifyBulletinID;
    bulletin.turnsOnDisplay = YES;
    bulletin.lockScreenPriority = 3;
    bulletin.preventAutomaticRemovalFromLockScreen = YES;

    BBAction *disableFlashlight = [BBAction actionWithIdentifier:kFlashNotifyBulletinAction];
    bulletin.defaultAction = disableFlashlight;

    if(server) {
      dispatch_async(__BBServerQueue, ^{
        [server publishBulletinRequest:bulletin destinations:15];
      });
    }
  } else {
    SBUIFlashlightController *flashlightController = [_logos_static_class_lookup$SBUIFlashlightController() sharedInstance];
    if (flashlightController.level > 0) {
      [flashlightController setLevel:0];
    }
  }
}

static void startTimer(NSInteger timeInterval) {
  if(timer) {
    [timer invalidate];
    timer = nil;
  }
  id selectorBlock = [^{sendNotif();} copy];
  
  timer = [[_logos_static_class_lookup$PCSimpleTimer() alloc] initWithTimeInterval:timeInterval serviceIdentifier:kFlashNotifyBulletinID target:selectorBlock selector:@selector(invoke) userInfo:nil];
  timer.disableSystemWaking = NO;
  [timer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
}

static void stopTimer() {
  if(timer) {
    [timer invalidate];
    timer = nil;
  }
}


static void _logos_method$_ungrouped$SBUIController$playChargingChimeIfAppropriate(_LOGOS_SELF_TYPE_NORMAL SBUIController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  if (charging) {
    SBUIFlashlightController *flashlightController = [_logos_static_class_lookup$SBUIFlashlightController() sharedInstance];
  	if (self.isConnectedToExternalChargingSource && !self.isBatteryCharging && flashlightController.level > 0) {
      startTimer(remindCharging);
  	}
  }
  _logos_orig$_ungrouped$SBUIController$playChargingChimeIfAppropriate(self, _cmd);
}



static void _logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
  if (!autooff) {
    startTimer(remind);
  } else {
    startTimer(autooffTimer);
  }
  _logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$(self, _cmd, arg1);
}

static void _logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
  stopTimer();
  removeBulletin();
  _logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$(self, _cmd, arg1);
}



static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer* __unused self, SEL __unused _cmd, id arg1) _LOGOS_RETURN_RETAINED {
  return server = _logos_orig$_ungrouped$BBServer$initWithQueue$(self, _cmd, arg1);
}



static id _logos_method$_ungrouped$BBBulletin$responseForAction$(_LOGOS_SELF_TYPE_NORMAL BBBulletin* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BBAction * arg1) {
  if([arg1.identifier isEqualToString:kFlashNotifyBulletinAction]) {
    SBUIFlashlightController *flashlightController = [_logos_static_class_lookup$SBUIFlashlightController() sharedInstance];
    if(flashlightController.level > 0) {
      [flashlightController setLevel:0];
    }
    return nil;
  }
  return _logos_orig$_ungrouped$BBBulletin$responseForAction$(self, _cmd, arg1);
}


static __attribute__((constructor)) void _logosLocalCtor_60a54890(int __unused argc, char __unused **argv, char __unused **envp) {
  NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.greg0109.flashnotifyprefs.plist"];
  enabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
  remind = prefs[@"remind"] ? [prefs[@"remind"] integerValue] : 120;
  charging = prefs[@"charging"] ? [prefs[@"charging"] boolValue] : YES;
  remindCharging = prefs[@"remindCharging"] ? [prefs[@"remindCharging"] integerValue] : 30;
  autooff = prefs[@"autooff"] ? [prefs[@"autooff"] boolValue] : NO;
  autooffTimer = prefs[@"autooffTimer"] ? [prefs[@"autooffTimer"] integerValue] : 30;
  if (enabled) {
    {Class _logos_class$_ungrouped$SBUIController = objc_getClass("SBUIController"); { MSHookMessageEx(_logos_class$_ungrouped$SBUIController, @selector(playChargingChimeIfAppropriate), (IMP)&_logos_method$_ungrouped$SBUIController$playChargingChimeIfAppropriate, (IMP*)&_logos_orig$_ungrouped$SBUIController$playChargingChimeIfAppropriate);}Class _logos_class$_ungrouped$SBUIFlashlightController = objc_getClass("SBUIFlashlightController"); { MSHookMessageEx(_logos_class$_ungrouped$SBUIFlashlightController, @selector(turnFlashlightOnForReason:), (IMP)&_logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$, (IMP*)&_logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$);}{ MSHookMessageEx(_logos_class$_ungrouped$SBUIFlashlightController, @selector(turnFlashlightOffForReason:), (IMP)&_logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$, (IMP*)&_logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$);}Class _logos_class$_ungrouped$BBServer = objc_getClass("BBServer"); { MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(initWithQueue:), (IMP)&_logos_method$_ungrouped$BBServer$initWithQueue$, (IMP*)&_logos_orig$_ungrouped$BBServer$initWithQueue$);}Class _logos_class$_ungrouped$BBBulletin = objc_getClass("BBBulletin"); { MSHookMessageEx(_logos_class$_ungrouped$BBBulletin, @selector(responseForAction:), (IMP)&_logos_method$_ungrouped$BBBulletin$responseForAction$, (IMP*)&_logos_orig$_ungrouped$BBBulletin$responseForAction$);}}
  }
}
