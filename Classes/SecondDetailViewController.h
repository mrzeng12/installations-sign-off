

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "loginModal.h"

@interface SecondDetailViewController : UIViewController <UITextFieldDelegate> {
    
    UINavigationBar *navigationBar;
    loginModal *myModalViewController;
}

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) loginModal *myModalViewController;

@property (strong, nonatomic) IBOutlet UILabel *schoolNameOutlet;

@property (strong, nonatomic) IBOutlet UILabel *teqRepOutlet;

@property (strong, nonatomic) IBOutlet UILabel *activityNoOutlet;

@property (strong, nonatomic) IBOutlet UILabel *dateOutlet;

@property (strong, nonatomic) IBOutlet UILabel *existingEquipOutlet;

@property (strong, nonatomic) IBOutlet UITextField *roomNoInTextField;

@property (strong, nonatomic) IBOutlet UITextField *floorNoTextField;

@property (strong, nonatomic) IBOutlet UITextField *notesNoTextField;

@property (strong, nonatomic) IBOutlet UITextField *gradeNoTextField;

@property (nonatomic, strong) IBOutlet UITableView *tableviews;

@property (strong, nonatomic) NSString *lastLocation;

@property (strong, nonatomic) NSString *lastDate;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@property (strong, nonatomic) IBOutlet UIButton *loadButton;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)addRoom;

- (IBAction)loadRoom;

- (IBAction)duplicateRoom;

- (IBAction)deleteRoom;


//-(IBAction)goToModalView;

-(void)saveAndGoToNextPage;

-(void)loadRoomFromDB;


@property (nonatomic) int goBackToWhichPage;

-(void) checkIfPreviousPagesAreFinished;

@end
