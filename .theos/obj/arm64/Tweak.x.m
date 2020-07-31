#line 1 "Tweak.x"
#import "Tweak.h"

extern dispatch_queue_t __BBServerQueue;
static NSString *const kFlashNotifyBulletinID = @"com.greg0109.FlashNotify-ID";
static NSString *const kFlashNotifyBulletinAction = @"!com.greg0109.FlashNotify-Action";

PCSimpleTimer *timer;
BBServer *server;

static BOOL notifyWhileUnplugged = YES;
static NSInteger unpluggedNotificationDelay;
static BOOL notifyWhileCharging = YES;
static NSInteger chargingNotificationDelay;

static void removeBulletin() {
  if(server) {
    dispatch_async(__BBServerQueue, ^{
      [server withdrawBulletinRequestsWithPublisherBulletinID:kFlashNotifyBulletinID forSectionID:@"com.apple.Preferences"];
    });
  }
}

static void sendNotif() {
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

@class BBServer; @class SBUIFlashlightController; @class BBBulletin; @class PCSimpleTimer; 
static SBUIFlashlightController* (*_logos_orig$_ungrouped$SBUIFlashlightController$init)(_LOGOS_SELF_TYPE_INIT SBUIFlashlightController*, SEL) _LOGOS_RETURN_RETAINED; static SBUIFlashlightController* _logos_method$_ungrouped$SBUIFlashlightController$init(_LOGOS_SELF_TYPE_INIT SBUIFlashlightController*, SEL) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$)(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$)(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST, SEL, id); static BBServer* (*_logos_orig$_ungrouped$BBServer$initWithQueue$)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static id (*_logos_orig$_ungrouped$BBBulletin$responseForAction$)(_LOGOS_SELF_TYPE_NORMAL BBBulletin* _LOGOS_SELF_CONST, SEL, BBAction *); static id _logos_method$_ungrouped$BBBulletin$responseForAction$(_LOGOS_SELF_TYPE_NORMAL BBBulletin* _LOGOS_SELF_CONST, SEL, BBAction *); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$PCSimpleTimer(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("PCSimpleTimer"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBUIFlashlightController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBUIFlashlightController"); } return _klass; }
#line 46 "Tweak.x"
static void startTimer() {
  if(timer) {
    [timer invalidate];
    timer = nil;
  }
  id selectorBlock = [^{sendNotif();} copy];
  NSInteger timeInterval = ([UIDevice currentDevice].batteryState == 2 && notifyWhileCharging) ? chargingNotificationDelay : unpluggedNotificationDelay;
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


static SBUIFlashlightController* _logos_method$_ungrouped$SBUIFlashlightController$init(_LOGOS_SELF_TYPE_INIT SBUIFlashlightController* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
  [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];

  return _logos_orig$_ungrouped$SBUIFlashlightController$init(self, _cmd);
}

static void _logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$(_LOGOS_SELF_TYPE_NORMAL SBUIFlashlightController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
  startTimer();
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

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBUIFlashlightController = objc_getClass("SBUIFlashlightController"); { MSHookMessageEx(_logos_class$_ungrouped$SBUIFlashlightController, @selector(init), (IMP)&_logos_method$_ungrouped$SBUIFlashlightController$init, (IMP*)&_logos_orig$_ungrouped$SBUIFlashlightController$init);}{ MSHookMessageEx(_logos_class$_ungrouped$SBUIFlashlightController, @selector(turnFlashlightOnForReason:), (IMP)&_logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$, (IMP*)&_logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOnForReason$);}{ MSHookMessageEx(_logos_class$_ungrouped$SBUIFlashlightController, @selector(turnFlashlightOffForReason:), (IMP)&_logos_method$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$, (IMP*)&_logos_orig$_ungrouped$SBUIFlashlightController$turnFlashlightOffForReason$);}Class _logos_class$_ungrouped$BBServer = objc_getClass("BBServer"); { MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(initWithQueue:), (IMP)&_logos_method$_ungrouped$BBServer$initWithQueue$, (IMP*)&_logos_orig$_ungrouped$BBServer$initWithQueue$);}Class _logos_class$_ungrouped$BBBulletin = objc_getClass("BBBulletin"); { MSHookMessageEx(_logos_class$_ungrouped$BBBulletin, @selector(responseForAction:), (IMP)&_logos_method$_ungrouped$BBBulletin$responseForAction$, (IMP*)&_logos_orig$_ungrouped$BBBulletin$responseForAction$);}} }
#line 103 "Tweak.x"
