

#import <UIKit/UIKit.h>
#import "LandscapeOnlyViewController.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    LandscapeOnlyViewController *splitViewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet LandscapeOnlyViewController *splitViewController;

@end

