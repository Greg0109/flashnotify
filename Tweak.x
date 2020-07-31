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

static void startTimer() {
  if(timer) {
    [timer invalidate];
    timer = nil;
  }
  id selectorBlock = [^{sendNotif();} copy];
  NSInteger timeInterval = ([UIDevice currentDevice].batteryState == 2 && notifyWhileCharging) ? chargingNotificationDelay : unpluggedNotificationDelay;
  timer = [[%c(PCSimpleTimer) alloc] initWithTimeInterval:timeInterval serviceIdentifier:kFlashNotifyBulletinID target:selectorBlock selector:@selector(invoke) userInfo:nil];
  timer.disableSystemWaking = NO;
  [timer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
}

static void stopTimer() {
  if(timer) {
    [timer invalidate];
    timer = nil;
  }
}

%hook SBUIFlashlightController
-(instancetype)init {
  [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];

  return %orig;
}

-(void)turnFlashlightOnForReason:(id)arg1 {
  startTimer();
  %orig;
}

-(void)turnFlashlightOffForReason:(id)arg1 {
  stopTimer();
  removeBulletin();
  %orig;
}
%end

%hook BBServer
-(id)initWithQueue:(id)arg1 {
  return server = %orig;
}
%end

%hook BBBulletin
-(id)responseForAction:(BBAction *)arg1 {
  if([arg1.identifier isEqualToString:kFlashNotifyBulletinAction]) {
    SBUIFlashlightController *flashlightController = [%c(SBUIFlashlightController) sharedInstance];
    if(flashlightController.level > 0) {
      [flashlightController setLevel:0];
    }
    return nil;
  }
  return %orig;
}
%end
