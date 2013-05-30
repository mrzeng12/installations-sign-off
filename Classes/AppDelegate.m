

#import "AppDelegate.h"
#import "RootViewController.h"
#import "loginModal.h"
#import "isql.h"

//#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

@synthesize window, splitViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	    
	//[window addSubview:splitViewController.view];
    //change this for IOS 6, to fix rotation problem.
    [window setRootViewController:splitViewController];
    //window.rootViewController = self.splitViewController;
    [window makeKeyAndVisible];
	
    loginModal *temp = [[loginModal alloc] initWithNibName:@"loginModal" bundle:[NSBundle mainBundle]];
        
    temp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    // ANIMATED TRANSITION WILL RESULT IN ERROR
    //[splitViewController presentModalViewController:temp animated: NO];
    [splitViewController presentViewController:temp animated:NO completion:nil];
    
    //avoid automatically dim, and transit to background mode, which breaks the app when syncing.
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //[TestFlight takeOff:@"a7cf1f951223c1a232afedace04054d8_MTQ0NTA1MjAxMi0xMC0xNyAxMjowNjo0MC4yMjIxMzM"];
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"ef919c90-9cac-4a2f-935c-0fe54c714144"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    isql *database = [isql initialize];
    if ([database.current_teq_rep length] > 0){
        TFLog(@"username: %@", database.current_teq_rep);
    }
}



@end
