

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <QuickLook/QuickLook.h>
#import "FirstDetailViewController.h"
#import "SecondDetailViewController.h"
#import "LandscapeOnlyViewController.h"
@class FirstDetailViewController;
@class SecondDetailViewController;
/*
 SubstitutableDetailViewController defines the protocol that detail view controllers must adopt. The protocol specifies methods to hide and show the bar button item controlling the popover.

 */



@interface RootViewController : UITableViewController <UISplitViewControllerDelegate, UIDocumentInteractionControllerDelegate,QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIActionSheetDelegate> {
	
	LandscapeOnlyViewController *__weak splitViewController;
    
    UIPopoverController *popoverController;    
    UIBarButtonItem *rootPopoverButtonItem;
    
    UIAlertView *menuAlert;
    UIAlertView *logoutAlert;
    UIAlertView *existWithoutSavingAlert;
    NSMutableArray *srcDBArray;
    
    UIBarButtonItem *menuButton;
    UIBarButtonItem *logoutButton;
    UIBarButtonItem *summaryButton;
    UIBarButtonItem *debugButton;
    
    UILabel *saveTimeLabel;
    
    UIActionSheet *menuActionSheet;
}

@property (retain, nonatomic) UIDocumentInteractionController *docController;

@property (nonatomic, weak) IBOutlet LandscapeOnlyViewController *splitViewController;

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIBarButtonItem *rootPopoverButtonItem;


@property (nonatomic, strong) NSArray *firstViewControllers;

@property (nonatomic, strong) NSArray *secondViewControllers;

@property (nonatomic, strong) NSArray *thirdViewControllers;

@property (nonatomic, strong) NSArray *fourthViewControllers;

@property (nonatomic, strong) NSArray *fifthViewControllers;

@property (nonatomic, strong) NSArray *sixthViewControllers;

@property (nonatomic, strong) NSArray *seventhViewControllers;

@property (nonatomic, strong) NSArray *sevenPointFiveViewControllers;

@property (nonatomic, strong) NSArray *eighthViewControllers;

@property (nonatomic, strong) NSArray *ninethViewControllers;

@property (nonatomic, strong) NSArray *tenthViewControllers;

@property (nonatomic, strong) NSArray *eleventhViewControllers;

@property (nonatomic, strong) NSArray *twelfthViewControllers;

@property (nonatomic, strong) NSArray *thirteenthViewControllers;

@property (nonatomic, strong) NSArray *fourteenthViewControllers;

@property (nonatomic, strong) NSArray *fifteenthViewControllers;

@property (nonatomic, strong) FirstDetailViewController *firstview;

@property (nonatomic, strong) SecondDetailViewController *secondview;


@end
