
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "loginModal.h"
#import "isql.h"
@class FirstDetailView3;

@interface FirstDetailViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate> {

    UIToolbar *toolbar;
    NSTimer *update_timer;
    NSString *cellHeight;
    NSString *cellFullHeight;
}


@property (nonatomic, strong) IBOutlet UILabel *current_user;

@property (nonatomic, strong) IBOutlet UITableView *tableviews;

@property (strong, nonatomic) IBOutlet UITableView *tableviews2;

@property (strong, nonatomic) IBOutlet UITableView *tableviews3;

@property (nonatomic, strong) NSMutableArray *locationList;

@property (nonatomic, strong) NSMutableArray *timeLocationList;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSMutableArray *datetimeList;

@property (nonatomic, strong) NSMutableArray *savedLocationList;

@property (nonatomic, strong) NSMutableArray *savedDateList;

@property (nonatomic, strong) NSMutableArray *allRoomList;

@property (nonatomic, strong) NSMutableArray *completeList;

@property (nonatomic, strong) NSMutableArray *syncedList;

@property (nonatomic, strong) NSMutableArray *failFileList;

@property (nonatomic, strong) NSMutableArray *ActivityList;

@property (nonatomic, strong) NSMutableArray *SQList;

@property (nonatomic, strong) NSMutableArray *SOList;

@property (nonatomic, strong) NSMutableArray *savedActivityList;

@property (nonatomic, strong) NSMutableArray *savedSQList;

@property (nonatomic, strong) NSMutableArray *savedSOList;

@property (nonatomic, strong) NSMutableArray *secondSectionHeightList;

@property (nonatomic, strong) NSString *firstSectionHeight;

@property (nonatomic, strong) NSString *savedActivity;

@property (nonatomic, strong) NSString *savedSQ;

@property (nonatomic, strong) NSString *savedSO;

@property (nonatomic, strong) NSString *selectedActivity;

@property (nonatomic, strong) NSString *selectedSQ;

@property (nonatomic, strong) NSString *selectedSO;

@property (nonatomic, strong) NSString *currentDate;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet FirstDetailView3 *firstDetailView3;

@property (strong, nonatomic) IBOutlet UIButton *createButton;

@property (strong, nonatomic) IBOutlet UIButton *loadButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@property (strong, nonatomic) IBOutlet UILabel *updatedTime;

@property (strong, nonatomic) IBOutlet UIButton *refreshBtn;

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureRecognizer;

- (IBAction)createButtonTouched:(id)sender;

- (IBAction)loadButtonTouched;

- (IBAction)refreshBtnTouched:(id)sender;

- (IBAction)createEmptyButtonTouched;


@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)segmentControlValueChanged:(id)sender;


-(void) welcomeUser;

-(void) loadSavedRecord; 

@end
