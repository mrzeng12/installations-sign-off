#import "FirstDetailViewController.h"
#import "FirstDetailView3.h"
#import <sqlite3.h>
#import "LGViewHUD.h"
#import "NewActivityCell.h"
#import "SavedActivityCell.h"
#import "CompletePDFRenderer.h"

@implementation FirstDetailViewController
@synthesize segmentControl;
@synthesize createButton;
@synthesize loadButton;
@synthesize scrollview;
@synthesize updatedTime;
@synthesize refreshBtn;
@synthesize tableviews2;
@synthesize tableviews3;

@synthesize current_user, currentDate, tableviews, dataList, locationList, activityIndicator, firstDetailView3, savedDateList, savedLocationList;
@synthesize gestureRecognizer;
//tableviews2: first table that loads date
//tableviews:  second table that loads time and location
//tableviews3: third table that loads saved date and location.

#pragma mark -
#pragma mark View lifecycle
// tableview: location, tableview2: date, tableview3: Saved
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        cellHeight = @"44";
        cellFullHeight = @"96";
    }
    return self;
}
- (void)viewDidLoad {
    
    //prevent first page from loading before login
    
    isql *database= [isql initialize];
    if (database.current_username == nil) {
        [super viewDidLoad];
        return;
    }
    
    [scrollview setFrame:CGRectMake(0, 44, 703, 704)];
    [scrollview setContentSize:CGSizeMake(703, 705)];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(userLoggedIn:)
     name:@"Logged in" object:nil];   
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(LoadFirstPageAfterSync:)
     name:@"LoadFirstPageAfterSync" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(continueToCreateNewActivity:)
     name:@"continueToCreateNewActivity" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(continueToLoadOldActivity:)
     name:@"continueToLoadOldActivity" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(autoLoadCurrentActivity:)
     name:@"autoLoadCurrentActivity" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(continueToCreateEmptySurvey:)
     name:@"continueToCreateEmptySurvey" object:nil];
    
    [refreshBtn setImage:[[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"refresh_btn" ofType:@"png" ]] forState:UIControlStateNormal];
    [refreshBtn setContentMode:UIViewContentModeCenter];
    
    [tableviews setBackgroundView:nil];
    [tableviews setBackgroundColor:nil];
    [tableviews2 setBackgroundView:nil];
    [tableviews2 setBackgroundColor:nil];
    [tableviews3 setBackgroundView:nil];
    [tableviews3 setBackgroundColor:nil];
    
    self.tableviews.scrollEnabled = NO;
    self.tableviews2.scrollEnabled = NO;
    self.tableviews3.scrollEnabled = NO;
    
    activityIndicator.hidesWhenStopped = YES; 
    //activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    self.currentDate = [formatter stringFromDate: today];
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    //NSLog(@"%@",currentDate);
    
    //isql *database = [isql initialize];
    
    //[activityIndicator startAnimating];
    //[database remoteSrcToLocalSrc:NO];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"No" forKey:@"upload"];    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:dict];
    
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.tableviews addGestureRecognizer:gestureRecognizer];
    [self.tableviews2 addGestureRecognizer:gestureRecognizer];
    [self.tableviews3 addGestureRecognizer:gestureRecognizer];
    [self.view addGestureRecognizer:gestureRecognizer];
    //[self.createButton removeGestureRecognizer:gestureRecognizer];
    NSLog(@"load firstview");
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setTableviews2:nil];
    [self setTableviews:nil];
    [self setTableviews3:nil];
    [self setCreateButton:nil];
    [self setSegmentControl:nil];
    [self setLoadButton:nil];
    [self setScrollview:nil];
    [self setUpdatedTime:nil];
    [self setRefreshBtn:nil];
    
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    
    isql *database = [isql initialize];
    [scrollview scrollRectToVisible:CGRectMake(0, 0, 703, 704) animated:YES];
    [self.scrollview flashScrollIndicators];
    [super viewWillAppear:YES];
    [self welcomeUser];
    [database addNumberToAppIcon];
}

- (void) viewDidAppear:(BOOL)animated {
    update_timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                    target:self
                                                  selector:@selector(updateLabel)
                                                  userInfo:nil
                                                   repeats:YES];
    
    [self loadDate];
    [self loadActivities:@""];
    [self loadSavedRecord];
}

- (void) viewDidDisappear {
    [update_timer invalidate];
    update_timer = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark Rotation support

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self      name:@"Logged in" object:nil];   
}	


-(void)userLoggedIn:(NSNotification*)notifications 

{
    [self welcomeUser];
}

-(void)continueToCreateNewActivity:(NSNotification *)notifications
{
    isql *database = [isql initialize];
    database.current_date = database.selected_date;
    database.current_location = database.selected_location;
    database.current_activity_no = database.selected_activity_no;
    //set up these values after creating, because the new activity may not be in local_dest, therefore not be able to set in loadSavedRecord
    self.savedActivity = self.selectedActivity;
    self.savedSQ = self.selectedSQ;
    self.savedSO = self.selectedSO;
    self.firstSectionHeight = cellFullHeight;
    
    [tableviews setHidden:YES];
    [tableviews2 setHidden:YES];
    [createButton setHidden:YES];
    [loadButton setHidden:NO];
    [tableviews3 setHidden:NO];
    
    segmentControl.selectedSegmentIndex = 1;
    [self loadDate];
    [self loadActivities:@""];
    [self loadSavedRecord];
    
    self.firstDetailView3.title = @"Cover Sheet";
    [self.navigationController pushViewController:self.firstDetailView3 animated:YES];
}

-(void)continueToLoadOldActivity:(NSNotification *)notifications
{
    isql *database = [isql initialize];
    database.current_date = database.selected_date;
    database.current_location = database.selected_location;
    database.current_activity_no = database.selected_activity_no;
    
    [self loadDate];
    [self loadActivities:@""];
    [self loadSavedRecord];
    
    self.firstDetailView3.title = @"Cover Sheet";
    [self.navigationController pushViewController:self.firstDetailView3 animated:YES];
}

-(void)continueToCreateEmptySurvey:(NSNotification *)notifications
{
    isql *database = [isql initialize];
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    database.current_date = [formatter stringFromDate: today];
    
    database.customDate = database.current_date;
    database.customLocation = database.current_location;
    database.customOnthefly = @"Yes";
    
    //set up these values after creating, because the new activity may not be in local_dest, therefore not be able to set in loadSavedRecord
    self.savedActivity = database.current_activity_no;
    self.savedSQ = @"";
    self.savedSO = @"";
    self.firstSectionHeight = cellFullHeight;
    
    [tableviews setHidden:YES];
    [tableviews2 setHidden:YES];
    [createButton setHidden:YES];
    [loadButton setHidden:NO];
    [tableviews3 setHidden:NO];
    
    segmentControl.selectedSegmentIndex = 1;
    [self loadDate];
    [self loadActivities:@""];
    [self loadSavedRecord];
    
    self.firstDetailView3.title = @"Cover Sheet";
    [self.navigationController pushViewController:self.firstDetailView3 animated:YES];
}

- (IBAction)createButtonTouched:(id)sender {
    
    if ([[tableviews indexPathsForSelectedRows] count] > 0
        && [[tableviews2 indexPathsForSelectedRows] count] > 0 ) {
        
        [NSThread detachNewThreadSelector:@selector(myThreadMethodAfterExit:) toTarget:self withObject:nil];
        // save locally when create a new task
        isql *database = [isql initialize];
        [database updateLocalDestForCoverPage];
        
        // save previous pdf when create a new task, run callback function afterwards
        CompletePDFRenderer *renderer = [CompletePDFRenderer new];
        renderer.callBackFunction = @"continueToCreateNewActivity";
        [renderer loadVariablesForPDF];
    }   
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please pick a date and a location." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
    }
}

- (IBAction)loadButtonTouched {
    
    if ([[tableviews3 indexPathsForSelectedRows] count] > 0 ) {
        isql *database = [isql initialize];
        
        if ([[[tableviews3 indexPathsForSelectedRows] objectAtIndex:0] isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
            //NSLog(@"current");
            database.selected_date = database.current_date;
            database.selected_location = database.current_location;
            database.selected_activity_no = database.current_activity_no;
            
            [self loadDate];
            [self loadActivities:@""];
            [self loadSavedRecord];
            
            self.firstDetailView3.title = @"Cover Sheet";
            [self.navigationController pushViewController:self.firstDetailView3 animated:YES];
        }
        else {
            //NSLog(@"previous");
            [NSThread detachNewThreadSelector:@selector(myThreadMethodAfterExit:) toTarget:self withObject:nil];
            // save locally when create a new task
            [database updateLocalDestForCoverPage];
            
            // save previous pdf when load another task, run callback function afterwards
            CompletePDFRenderer *renderer = [CompletePDFRenderer new];
            renderer.callBackFunction = @"continueToLoadOldActivity";
            [renderer loadVariablesForPDF];
        }
    }   
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please pick a saved survey" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
    }
}

-(void)autoLoadCurrentActivity:(NSNotification *)notifications {
    
    isql *database = [isql initialize];
    //if no activity is selected, do not do anything, otherwise it will pops up error after log out and log back in, because of this line [self.navigationController pushViewController:self.firstDetailView3 animated:YES];
    if ([database.current_date length] == 0 || [database.current_location length] == 0) {
        return;
    }
    
    if ([[tableviews3 indexPathsForSelectedRows] count] > 0 ) {
        
        if ([[[tableviews3 indexPathsForSelectedRows] objectAtIndex:0] isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
            //NSLog(@"current");
            database.selected_date = database.current_date;
            database.selected_location = database.current_location;
            database.selected_activity_no = database.current_activity_no;
            
            [self loadDate];
            [self loadActivities:@""];
            [self loadSavedRecord];
            
            self.firstDetailView3.title = @"Cover Sheet";
            [self.navigationController pushViewController:self.firstDetailView3 animated:YES];
        }
    }
    
}

- (void)myThreadMethodAfterExit:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Saving";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (IBAction)refreshBtnTouched:(id)sender {
    isql *database = [isql initialize];
    //[activityIndicator startAnimating];
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Loading";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];    

    [database checkLatestVersion];

    [self deleteOldFiles];
    [database remoteSrcToLocalSrc:NO];
}

- (void) deleteOldFiles {
    // Code to delete images older than two days.
#define kDOCSFOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator* en = [fileManager enumeratorAtPath:kDOCSFOLDER];
    
    NSString* file;
    while (file = [en nextObject])
    {
        //NSLog(@"File To Delete : %@",file);
        NSError *error= nil;
        
        NSString *filepath=[NSString stringWithFormat:[kDOCSFOLDER stringByAppendingString:@"/%@"],file];
        
        
        NSDate   *modifiedDate =[[fileManager attributesOfItemAtPath:filepath error:nil] fileModificationDate];
        
        NSDate *sixMonthAgo =[[NSDate date] dateByAddingTimeInterval:-180*24*60*60];
        
        NSDate *oneMonthAgo =[[NSDate date] dateByAddingTimeInterval:-30*24*60*60];
        
        NSDateFormatter *df=[[NSDateFormatter alloc]init];// = [NSDateFormatter initWithDateFormat:@"yyyy-MM-dd"];
        [df setDateFormat:@"yyyy-MM-dd"];
        
        NSString *modifiedDateString = [df stringFromDate:modifiedDate];
        
        //NSString *twoDaysOld = [df stringFromDate:d];
        
        if ([modifiedDate compare:sixMonthAgo] == NSOrderedAscending)
            
        {
            if ([[file pathExtension] caseInsensitiveCompare: @"jpg"] == NSOrderedSame ) {
                
                [[NSFileManager defaultManager] removeItemAtPath:[kDOCSFOLDER stringByAppendingPathComponent:file] error:&error];
                
                NSLog(@"File removed -- %@ -- modified by: %@", file, modifiedDateString);
            };
        }
        
        if ([modifiedDate compare:oneMonthAgo] == NSOrderedAscending)
            
        {
            if ([[file pathExtension] caseInsensitiveCompare: @"pdf"] == NSOrderedSame ) {
                
                [[NSFileManager defaultManager] removeItemAtPath:[kDOCSFOLDER stringByAppendingPathComponent:file] error:&error];
                
                NSLog(@"File removed -- %@ -- modified by: %@", file, modifiedDateString);
            };
        }
    }
}

- (IBAction)segmentControlValueChanged:(id)sender {
    if (segmentControl.selectedSegmentIndex == 0) {
        [tableviews setHidden:NO];
        [tableviews2 setHidden:NO];
        [createButton setHidden:NO];
        [loadButton setHidden:YES];
        [tableviews3 setHidden:YES];
        
        float temp_height = 100 + [tableviews2 contentSize].height + [tableviews contentSize].height;
        if ([self.timeLocationList count] == 0) {
            temp_height = 135 + [tableviews2 contentSize].height;
        }
        float height = (temp_height > 615)? temp_height: 615;
        
        [createButton setFrame:CGRectMake(41, height + 20, 234, 49)];
        [scrollview setContentSize:CGSizeMake(703, height+210)];
        
    }
    else {
        [tableviews setHidden:YES];
        [tableviews2 setHidden:YES];
        [createButton setHidden:YES];
        [loadButton setHidden:NO];
        [tableviews3 setHidden:NO];
        float temp_height = 121 + [tableviews3 contentSize].height;
        
        float height = (temp_height > 615)? temp_height: 615;
        //float height = temp_height;
        [loadButton setFrame:CGRectMake(41, height + 20, 237, 49)];
        
        if (segmentControl.selectedSegmentIndex == 1) {
            [scrollview setContentSize:CGSizeMake(703, height+90)];
        }
    }
}

-(void) welcomeUser {
    isql *database = [isql initialize];
    
    NSMutableString* userString = [NSMutableString string];
    
    [userString appendString:[NSString stringWithFormat:@"%@", @"Welcome"]];
    
    if ([database.current_teq_rep length] > 0) {
        [userString appendString:[NSString stringWithFormat:@"%@", @", "]];
        [userString appendString:[NSString stringWithFormat:@"%@", database.current_teq_rep]];
    }    
    
    self.current_user.text = userString;
    
}

-(void)updateLabel {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *lastUpdatedDateTimeString = [prefs stringForKey:@"lastUpdated"];
    self.updatedTime.text = [self dateDiff:lastUpdatedDateTimeString];
}

-(NSString *)dateDiff:(NSString *)origDate {
    //NSLog(@"%@", origDate);
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //[df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSDate *convertedDate = [df dateFromString:origDate];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    //NSLog(@"%f", ti);
    if(ti < 1) {
        return @"just now";
    } else      if (ti < 60) {
        //return @"less than a minute ago";
        int diff = round(ti);
        return [NSString stringWithFormat:@"%d seconds ago", diff];
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return @"never";
    }
}

-(void)LoadFirstPageAfterSync:(NSNotification*)notifications 

{
    isql *database = [isql initialize];
    
    //[activityIndicator stopAnimating];
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    [database addNumberToAppIcon];
    
    /*********** each time after sync, update currentDate ***********/
    
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    self.currentDate = [formatter stringFromDate: today];
    
    [self loadDate];
    [self loadActivities:@""];
    [self loadSavedRecord];
    
    /* deprecated, sync never starts from remote-to-local
    NSString * upload = [[notifications userInfo] valueForKey:@"upload"];
    
    if ([upload isEqualToString:@"Yes"]) {
        [database localDestToRemoteDest];
    } 
     */
}

-(void) loadActivities : (NSString *) oneDay
{
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    [database copyDatabaseIfNeeded];
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            //if exists in local_dest, do not come up in New Survey List
            NSString *selectSQL = [NSString stringWithFormat:@"select distinct time([StartDateTime]), [StartDateTime], [BP_Name], [Activity_Number], [SQ], [SO] from local_src where date('%@') = date([StartDateTime]) and Assigned_Name like '%%%@%%' and [Activity_Number] not in (select distinct [Activity_no] from local_dest where [Teq_rep] like '%%%@%%' ) order by [StartDateTime], [BP_Name];", oneDay, database.current_teq_rep, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                self.locationList = [NSMutableArray arrayWithObjects: nil];
                self.timeLocationList = [NSMutableArray arrayWithObjects:nil];
                self.datetimeList = [NSMutableArray arrayWithObjects:nil];
                self.ActivityList = [NSMutableArray arrayWithObjects:nil];
                self.SQList = [NSMutableArray arrayWithObjects:nil];
                self.SOList = [NSMutableArray arrayWithObjects:nil];
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                { 
                    NSMutableString *string = [NSMutableString string];
                    [string appendString:[[NSString alloc]
                                         initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 0)]];
                    [string appendString:@"          "];
                    [string appendString:[[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 2)]];
                    [self.timeLocationList addObject: string];
                    [self.datetimeList addObject:[[NSString alloc]
                                                 initWithUTF8String:
                                                  (const char *) sqlite3_column_text(statement, 1)]];
                    [self.locationList addObject:[[NSString alloc]
                                                  initWithUTF8String:
                                                  (const char *) sqlite3_column_text(statement, 2)]];
                    [self.ActivityList addObject:[[NSString alloc]
                                                  initWithUTF8String:
                                                  (const char *) sqlite3_column_text(statement, 3)]];
                    [self.SQList addObject:[[NSString alloc]
                                            initWithUTF8String:
                                            (const char *) sqlite3_column_text(statement, 4)]];
                    [self.SOList addObject:[[NSString alloc]
                                            initWithUTF8String:
                                            (const char *) sqlite3_column_text(statement, 5)]];
                }
                [self.tableviews reloadData];
                sqlite3_finalize(statement);
            } 
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {        
        sqlite3_close(db);
        
        [tableviews setFrame:CGRectMake(0, 121 + [tableviews2 contentSize].height, 703, [tableviews contentSize].height)];
        float temp_height = 100 + [tableviews2 contentSize].height + [tableviews contentSize].height;
        if ([self.timeLocationList count] == 0) {
            temp_height = 135 + [tableviews2 contentSize].height;
        }
        float height = (temp_height > 615)? temp_height: 615;
        
        [createButton setFrame:CGRectMake(41, height + 20, 234, 49)];
        if (segmentControl.selectedSegmentIndex == 0) {
            [scrollview setContentSize:CGSizeMake(703, height+210)];
        }
        
    }  
    
}

-(void) loadSavedRecord 
{
    isql *database = [isql initialize];
    [database copyDatabaseIfNeeded];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            NSString *selectSQL = [NSString stringWithFormat:@"select count(*), [Date], [Location], [Activity_no], [Sales_Quote], [Sales_Order] from local_dest where [Teq_rep] like '%%%@%%' group by [Activity_no] order by [Date] desc, [Location] desc", database.current_teq_rep];            
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                self.allRoomList = [NSMutableArray arrayWithObjects: nil];
                self.savedDateList = [NSMutableArray arrayWithObjects: nil];   
                self.savedLocationList = [NSMutableArray arrayWithObjects: nil];
                self.secondSectionHeightList = [NSMutableArray arrayWithObjects:nil];
                self.savedActivityList = [NSMutableArray arrayWithObjects:nil];
                self.savedSQList = [NSMutableArray arrayWithObjects:nil];
                self.savedSOList = [NSMutableArray arrayWithObjects:nil];
                database.activity_room_count = @"0"; //in case that a new room is created, nothing in db yet
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *tempRoom = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 0)];
                    NSString *tempDate = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 1)];
                    NSString *tempLocation = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 2)];
                    NSString *tempActivity = [[NSString alloc]
                                              initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 3)];
                    NSString *tempSQ = [[NSString alloc]
                                              initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 4)];
                    NSString *tempSO = [[NSString alloc]
                                              initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 5)];
                    
                    if ([tempActivity isEqualToString:database.current_activity_no])
                    {
                        database.activity_room_count = tempRoom;
                        self.savedActivity = tempActivity;
                        self.savedSQ = tempSQ;
                        self.savedSO = tempSO;
                        self.firstSectionHeight = cellFullHeight;
                    }
                    else {
                        [self.allRoomList addObject: tempRoom];                        
                        [self.savedDateList addObject: tempDate];
                        [self.savedLocationList addObject: tempLocation];
                        [self.savedActivityList addObject:tempActivity];
                        [self.savedSQList addObject:tempSQ];
                        [self.savedSOList addObject:tempSO];
                        [self.secondSectionHeightList addObject:cellHeight];
                    }
                    
                }        
                   
                sqlite3_finalize(statement);
            } 
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
                
            }            
            //NSLog(@"%@", selectSQL);
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {        
        sqlite3_close(db);
        [self loadCompleteList];
    }
    
}

-(void) loadCompleteList
{
    isql *database = [isql initialize];
    [database copyDatabaseIfNeeded];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            
            NSString *selectSQL = [NSString stringWithFormat:@"select * from (select count(*) as count, [Activity_no], [Date], [Location] from local_dest where [Teq_rep] like '%%%@%%' and Raceway_part_9='complete' group by [Activity_no],Raceway_part_9 union select 0 as count, [Activity_no], [Date], [Location] from local_dest where [Teq_rep] like '%%%@%%' and Raceway_part_9!='complete' and Activity_no not in (select Activity_no from local_dest where [Teq_rep] like '%%%@%%' and Raceway_part_9='complete')) a1 order by [Date] desc, [Location] desc", database.current_teq_rep, database.current_teq_rep, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                self.completeList = [NSMutableArray arrayWithObjects: nil];
                //self.savedDateList = [NSMutableArray arrayWithObjects: nil];
                //self.savedLocationList = [NSMutableArray arrayWithObjects: nil];
                database.activity_complete_count = @"0"; //in case that a new room is created, nothing in db yet
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *tempRoom = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 0)];
                    
                    NSString *tempActivity = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 1)];
                    /*
                    NSString *tempLocation = [[NSString alloc]
                                              initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 2)];
                    */                    
                    if ([tempActivity isEqualToString:database.current_activity_no])
                    {
                        database.activity_complete_count = tempRoom;
                    }
                    else {
                        [self.completeList addObject: tempRoom];
                        //[self.savedDateList addObject: tempDate];
                        //[self.savedLocationList addObject: tempLocation];
                    }
                    
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
            
           // NSLog(@"%@", selectSQL);
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        [self loadSyncList];
    }
    
}

-(void) loadSyncList
{
    isql *database = [isql initialize];
    [database copyDatabaseIfNeeded];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            
            NSString *selectSQL = [NSString stringWithFormat:@"select * from (select count(*) as count, [Activity_no], [Date], [Location] from local_dest where [Teq_rep] like '%%%@%%' and sync_time >= save_time group by [Activity_no], Raceway_part_9 union select 0 as count, [Activity_no], [Date], [Location] from local_dest where [Teq_rep] like '%%%@%%' and sync_time < save_time and Activity_no not in (select Activity_no from local_dest where [Teq_rep] like '%%%@%%' and sync_time >= save_time)  ) a1 order by [Date] desc, [Location] desc", database.current_teq_rep, database.current_teq_rep, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                self.syncedList = [NSMutableArray arrayWithObjects: nil];
                //self.savedDateList = [NSMutableArray arrayWithObjects: nil];
                //self.savedLocationList = [NSMutableArray arrayWithObjects: nil];
                database.activity_synced_count = @"0";//in case that a new room is created, nothing in db yet
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *tempRoom = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 0)];
                    NSString *tempActivity = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 1)];
                    /*
                    NSString *tempLocation = [[NSString alloc]
                                              initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 2)];
                    */                    
                    if ([tempActivity isEqualToString:database.current_activity_no])
                    {
                        database.activity_synced_count = tempRoom;
                    }
                    else {
                        [self.syncedList addObject: tempRoom];
                        //[self.savedDateList addObject: tempDate];
                        //[self.savedLocationList addObject: tempLocation];
                    }
                    
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
            
            //NSLog(@"%@", selectSQL);
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        [self loadFailFileList];
    }
    
}

-(void) loadFailFileList {
    isql *database = [isql initialize];
    [database copyDatabaseIfNeeded];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {            
            NSString *selectSQL = [NSString stringWithFormat:@"select count(distinct path), A.[Activity_no], A.[Date], A.[Location] from local_dest A left join fail_upload_log B on A.[Activity_no] = B.[Activity_no] and A.[Teq_rep] = B.[Teq_rep] where A.[Teq_rep] like '%%%@%%' group by A.[Activity_no] order by A.[Date] desc, A.[Location] desc", database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                self.failFileList = [NSMutableArray arrayWithObjects: nil];
                //self.savedDateList = [NSMutableArray arrayWithObjects: nil];
                //self.savedLocationList = [NSMutableArray arrayWithObjects: nil];
                database.activity_failfile_count = @"0";//in case that a new room is created, nothing in db yet
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *tempRoom = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 0)];
                    NSString *tempActivity = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 1)];
                    /*
                    NSString *tempLocation = [[NSString alloc]
                                              initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 2)];
                    */
                    if ([tempActivity isEqualToString:database.current_activity_no])
                    {
                        database.activity_failfile_count = tempRoom;
                    }
                    else {
                        [self.failFileList addObject: tempRoom];
                        //[self.savedDateList addObject: tempDate];
                        //[self.savedLocationList addObject: tempLocation];
                    }
                    
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
            
            //NSLog(@"%@", selectSQL);
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        //NSLog(@"loadSaved");
        //move tableviews3 from within the database success block above to here, to make sure it always execute.
        //fix a potential bug that might selectRowAtIndexpath when the indexPath does not exist.
        [self.tableviews3 reloadData];
        if (database.current_location!=nil
            && database.current_date!=nil) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0]; // create a new index path
            [self.tableviews3 selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop]; // tell the table to highlight the new row
            [self.tableviews3 cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        [tableviews3 setFrame:CGRectMake(0, 159, 703, [tableviews3 contentSize].height+20)];
        float temp_height = 121 + [tableviews3 contentSize].height;
        
        float height = (temp_height > 615)? temp_height: 615;
        //float height = temp_height;
        [loadButton setFrame:CGRectMake(41, height + 20, 237, 49)];
        
        if (segmentControl.selectedSegmentIndex == 1) {
            [scrollview setContentSize:CGSizeMake(703, height+90)];
        }
    }
    
}

-(void) loadDate
{
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    [database copyDatabaseIfNeeded];
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            //if exists in local_dest, do not come up in New Survey List
            NSString *selectSQL = [NSString stringWithFormat:@"select distinct date([StartDateTime]) from local_src where Assigned_Name like '%%%@%%' and [Activity_Number] not in (select distinct [Activity_no] from local_dest where [Teq_rep] like '%%%@%%' ) order by date([StartDateTime]) ;", database.current_teq_rep, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                self.dataList = [NSMutableArray arrayWithObjects: nil];   
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                { 
                    
                    if ([[[NSString alloc] 
                         initWithUTF8String:
                         (const char *) sqlite3_column_text(statement, 0)] length] > 9) {
                        
                        [self.dataList addObject: [[NSString alloc] 
                                                   initWithUTF8String:
                                                   (const char *) sqlite3_column_text(statement, 0)]];
                        
                    }
                    
                }   
                NSLog(@"loadDate success");
                sqlite3_finalize(statement);
                
                int indexNumber = -1;
                for (int i = 0; i<[dataList count]; i++) {
                    
                    if ([[NSString stringWithFormat:@"%@", [self.dataList objectAtIndex:i]]  isEqual:self.currentDate]) {
                        indexNumber = i;
                    }
                }
                
                //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexNumber inSection:0]; // create a new index path 
                [self.tableviews2 reloadData];
                
                if (indexNumber > [dataList count]) {
                    return;
                }
                
                //[self.tableviews2 selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop]; // tell the table to highlight the new row
                //[self.tableviews2 cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
                /*
                [self.tableviews2 cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor colorWithRed:53.0/255.0 green:71.0/255.0 blue:190.0/255.0 alpha:1];
                 */
                database.selected_date = currentDate;
            } 
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
                
            }
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {        
        sqlite3_close(db);
        
        float temp_height = 100 + [tableviews2 contentSize].height + [tableviews contentSize].height;
        if ([self.timeLocationList count] == 0) {
            temp_height = 135 + [tableviews2 contentSize].height;
        }
        float height = (temp_height > 615)? temp_height: 615;
        
        [createButton setFrame:CGRectMake(41, height + 20, 234, 49)];
        if (segmentControl.selectedSegmentIndex == 0) {
            [scrollview setContentSize:CGSizeMake(703, height+210)];
        }
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    if (tableView == tableviews2) {
        return 1;
    }
    else if (tableView == tableviews) {
        return 1;
    }
    else {
        return 2;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    isql *database = [isql initialize];
    
    if (tableView == tableviews2) {        
        return [self.dataList count];
    }
    else if (tableView == tableviews) {
        return [self.timeLocationList count];
    }
    else {
        if (section == 0) {
            if (database.current_location != nil && database.current_date != nil) {
                return 1;
            }
            else {
                return 0;
            }
        }
        else {
            return [self.savedDateList count];  
        }              
    }
}

- (NSString *)tableView: (UITableView *) tableView titleForHeaderInSection:(NSInteger)section
{
    isql *database = [isql initialize];
    
    if (tableView == tableviews3) {
        if (section == 0) {
            if (database.current_location != nil && database.current_date != nil) {
                return @"Current";
            }  
        }
        else {
            if ([self.savedDateList count]>0) {
                return @"Previous";
            }
        }
    }
    else if (tableView == tableviews2){
        if ([self.dataList count] > 0) {
            return @"Please pick a date";
        }
        
    }
    else {
        if ([self.locationList count] > 0) {
            return @"Please pick a location";
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    isql *database = [isql initialize];
        
    if (tableView == tableviews2) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.dataList objectAtIndex:[indexPath row]]] ;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else if (tableView == tableviews) {
        /*
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [self.timeLocationList objectAtIndex:[indexPath row]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
         */
        static NSString *CellIdentifier = @"NewActivityCell";
        NewActivityCell *cell = (NewActivityCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewActivityCell" owner:self options:nil];
            for(NewActivityCell *temp_cell in nib) {
                if (temp_cell.tag == 1) {
                    cell = temp_cell;
                }
            }
        }
        cell.timeLocationLabel.text = [self.timeLocationList objectAtIndex:[indexPath row]];
        NSString *temp_sq;
        if ([[self.SQList objectAtIndex:[indexPath row]] length] > 0) {
            temp_sq = [self.SQList objectAtIndex:[indexPath row]];
        }
        else {
            temp_sq = @"N/A";
        }
        NSString *temp_so;
        if ([[self.SOList objectAtIndex:[indexPath row]] length] > 0) {
            temp_so = [self.SOList objectAtIndex:[indexPath row]];
        }
        else {
            temp_so = @"N/A";
        }
        cell.activityLabel.text = [NSString stringWithFormat:@"Activity: %@", [self.ActivityList objectAtIndex:[indexPath row]]];
        cell.sqLabel.text = [NSString stringWithFormat:@"Sales Quote: %@", temp_sq];
        cell.soLabel.text = [NSString stringWithFormat:@"Sales Order: %@", temp_so];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
    else {
        
        static NSString *CellIdentifier = @"SavedActivityCell";
        SavedActivityCell *cell = (SavedActivityCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SavedActivityCell" owner:self options:nil];
            for(SavedActivityCell *temp_cell in nib) {
                if (temp_cell.tag == 1) {
                    cell = temp_cell;
                }
            }
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        int temp_room_count, temp_complete_count, temp_synced_count, temp_error_count;
        UIColor *redColor, *greenColor, *yellowColor;
        redColor = [UIColor colorWithRed:255.0/255.0 green:199.0/255.0 blue:206.0/255.0 alpha:1];
        greenColor = [UIColor colorWithRed:198.0/255.0 green:239.0/255.0 blue:206.0/255.0 alpha:1];
        yellowColor = [UIColor colorWithRed:255.0/255.0 green:235.0/255.0 blue:156.0/255.0 alpha:1];
        
        if ([indexPath section] == 0) {
            cell.DateLocationLabel.text = [NSString stringWithFormat:@"%@        %@",database.current_date, database.current_location];
            cell.AllRoomsLabel.text = [NSString stringWithFormat:@"All Rooms (%@)", database.activity_room_count];
            cell.CompleteLabel.text = [NSString stringWithFormat:@"Complete (%@)", database.activity_complete_count];
            
            if ([database.activity_failfile_count intValue] > 0) {
                cell.SyncedLabel.text = [NSString stringWithFormat:@"Please sync again !"];
                cell.SyncedLabel.textColor = [UIColor redColor];
            }
            else {
                cell.SyncedLabel.text = [NSString stringWithFormat:@"Synced (%@)", database.activity_synced_count];
                cell.SyncedLabel.textColor = [UIColor blackColor];
            }
            temp_room_count = [database.activity_room_count intValue];
            temp_complete_count = [database.activity_complete_count intValue];
            temp_synced_count = [database.activity_synced_count intValue];
            temp_error_count = [database.activity_failfile_count intValue];
            
            NSString *temp_sq;
            if ([self.savedSQ length]> 0) {
                temp_sq = self.savedSQ;
            }
            else {
                temp_sq = @"N/A";
            }
            NSString *temp_so;
            if ([self.savedSO length] > 0) {
                temp_so = self.savedSO;
            }
            else {
                temp_so = @"N/A";
            }
            cell.activityLabel.text = [NSString stringWithFormat:@"Activity: %@", self.savedActivity];
            cell.sqLabel.text = [NSString stringWithFormat:@"Sales Quote: %@", temp_sq];
            cell.soLabel.text = [NSString stringWithFormat:@"Sales Order: %@", temp_so];
        }
        else {
            
            cell.DateLocationLabel.text = [NSString stringWithFormat:@"%@        %@",[self.savedDateList objectAtIndex:[indexPath row]], [self.savedLocationList objectAtIndex:[indexPath row]]];
            cell.AllRoomsLabel.text = [NSString stringWithFormat:@"All Rooms (%@)", [self.allRoomList objectAtIndex:[indexPath row]]];
            cell.CompleteLabel.text = [NSString stringWithFormat:@"Complete (%@)", [self.completeList objectAtIndex:[indexPath row]]];
          
            if ([[self.failFileList objectAtIndex:[indexPath row]] intValue] > 0) {
                cell.SyncedLabel.text = [NSString stringWithFormat:@"Please sync again !"];
                cell.SyncedLabel.textColor = [UIColor redColor];
            }
            else {
                cell.SyncedLabel.text = [NSString stringWithFormat:@"Synced (%@)", [self.syncedList objectAtIndex:[indexPath row]]];
                cell.SyncedLabel.textColor = [UIColor blackColor];
            }
            
            temp_room_count = [[self.allRoomList objectAtIndex:[indexPath row]] intValue];
            temp_complete_count = [[self.completeList objectAtIndex:[indexPath row]] intValue];
            temp_synced_count = [[self.syncedList objectAtIndex:[indexPath row]] intValue];
            temp_error_count = [[self.failFileList objectAtIndex:[indexPath row]] intValue];
            
            NSString *temp_sq;
            if ([[self.savedSQList objectAtIndex:[indexPath row]] length] > 0) {
                temp_sq = [self.savedSQList objectAtIndex:[indexPath row]];
            }
            else {
                temp_sq = @"N/A";
            }
            NSString *temp_so;
            if ([[self.savedSOList objectAtIndex:[indexPath row]] length] > 0) {
                temp_so = [self.savedSOList objectAtIndex:[indexPath row]];
            }
            else {
                temp_so = @"N/A";
            }
            cell.activityLabel.text = [NSString stringWithFormat:@"Activity: %@", [self.savedActivityList objectAtIndex:[indexPath row]]];
            cell.sqLabel.text = [NSString stringWithFormat:@"Sales Quote: %@", temp_sq];
            cell.soLabel.text = [NSString stringWithFormat:@"Sales Order: %@", temp_so];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
                
        if (temp_room_count == 0 ) {
            cell.backgroundColor = redColor;//[UIColor redColor];
        }
        else if(temp_complete_count < temp_room_count){
            cell.backgroundColor = redColor;//[UIColor redColor];
        }
        else if((temp_synced_count < temp_room_count)||(temp_error_count > 0)){
            cell.backgroundColor = yellowColor;//[UIColor orangeColor];
        }
        else {
            cell.backgroundColor = greenColor;//[UIColor greenColor];
        }
        cell.clipsToBounds = YES;
        return cell;
    }
        
    /*
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor blackColor];
     */
        
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tableviews2) {
        return 44;
    }
    else if (tableView == tableviews) {
        return 68;
    }    
    else {
        if ([indexPath section] == 0) {
            return [self.firstSectionHeight intValue];
        }
        else{
            return [[self.secondSectionHeightList objectAtIndex:[indexPath row]] intValue];
        }
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    
    if (tableView == tableviews2) 
    {       
        //isql *database = [isql initialize];
        //database.selected_date = [NSString stringWithFormat:@"%@", [self.dataList objectAtIndex: [indexPath row]]] ;
        [self loadActivities: [NSString stringWithFormat:@"%@", [self.dataList objectAtIndex: [indexPath row]]] ];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        /*
        [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor colorWithRed:53.0/255.0 green:71.0/255.0 blue:190.0/255.0 alpha:1];
         */
    }
    else if (tableView == tableviews) 
    {
        isql *database = [isql initialize];
        
        database.selected_location = [self.locationList objectAtIndex: [indexPath row]];
        
        database.selected_date = [self.datetimeList objectAtIndex: [indexPath row]];
        
        database.selected_activity_no = [self.ActivityList objectAtIndex: [indexPath row]];
        
        self.selectedActivity = [self.ActivityList objectAtIndex: [indexPath row]];
        
        self.selectedSQ = [self.SQList objectAtIndex: [indexPath row]];
        
        self.selectedSO = [self.SOList objectAtIndex: [indexPath row]];
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        /*
        [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor colorWithRed:53.0/255.0 green:71.0/255.0 blue:190.0/255.0 alpha:1];
        NSLog(@"select location");
         */
        
    }
    else {        
        if ([indexPath section] == 0) {
            /*
            self.firstDetailView3.title = @"Cover Sheet"; 
            
            isql *database = [isql initialize];
            database.selected_date = database.current_date;
            database.selected_location = database.current_location;
            
            [self.navigationController pushViewController:self.firstDetailView3 animated:YES];
             */
            self.firstSectionHeight = cellFullHeight;
            for (int i = 0; i < [self.secondSectionHeightList count]; i++) {
                [self.secondSectionHeightList replaceObjectAtIndex:i withObject:cellHeight];
            }
            [tableView beginUpdates];
            [tableView endUpdates];
        }
        else {
            isql *database = [isql initialize];
            int flag = 0;
            
            self.firstSectionHeight = cellHeight;
            for (int i = 0; i < [self.secondSectionHeightList count]; i++) {
                if ([[self.secondSectionHeightList objectAtIndex:i] isEqualToString: cellFullHeight]) {
                    flag = 1;
                }
                [self.secondSectionHeightList replaceObjectAtIndex:i withObject:cellHeight];
            }
            [self.secondSectionHeightList replaceObjectAtIndex:[indexPath row] withObject:cellFullHeight];
            [tableView beginUpdates];
            [tableView endUpdates];
            
            //fix UI bugs for "Open existing" btn
            if (database.current_activity_no == nil && flag == 0) {
                float temp_height = 121 + [tableviews3 contentSize].height;
                
                float height = (temp_height > 615)? temp_height: 615;
                if (temp_height > 580) {
                    [loadButton setFrame:CGRectMake(41, height + 20+52, 237, 49)];
                    
                    if (segmentControl.selectedSegmentIndex == 1) {
                        [scrollview setContentSize:CGSizeMake(703, height+90+52)];
                    }
                }
            }
            
            database.selected_date = [self.savedDateList objectAtIndex:[indexPath row]];
            database.selected_location = [self.savedLocationList objectAtIndex:[indexPath row]];
            database.selected_activity_no = [self.savedActivityList objectAtIndex:[indexPath row]];
        }
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //isql *database = [isql initialize];
    //if (tableView == tableviews2) 
    //{
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        /*
        [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor blackColor];        
         */
        
    //}
    //else if (tableView == tableviews) {
    //    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        /*
        [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor blackColor];
        */
    //}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    gestureRecognizer.cancelsTouchesInView = YES;
    int movementDistance;
    
    movementDistance = 350; // tweak as needed
    
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)enableSelection:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
