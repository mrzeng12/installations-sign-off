#import "RootViewController.h"
#import "FirstDetailViewController.h"
#import "SecondDetailViewController.h"
#import "FirstDetailView3.h"
#import "ThirdDetailView.h"
#import "FifteenthDetailView.h"
//#import "PDFModal.h"
#import "loginModal.h"
#import "isql.h"
#import <sqlite3.h>
//#import "testModal.h"
#import "LGViewHUD.h"
#import "CompletePDFRenderer.h"
#import "quickLookModal.h"
#import <QuickLook/QuickLook.h>
#import "MainMenuCell.h"
#import "objc/runtime.h"
#import "FileSystem.h"

@implementation RootViewController

@synthesize popoverController, splitViewController, rootPopoverButtonItem, firstViewControllers, secondViewControllers, thirdViewControllers, fifteenthViewControllers, docController;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    isql *database = [isql initialize];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    //self.tableView.scrollEnabled = NO;
        
    database.menu_grey_out = [NSMutableArray arrayWithObjects:
                              [NSNumber numberWithBool:YES],
                              [NSNumber numberWithBool:YES],
                              [NSNumber numberWithBool:NO],
                              [NSNumber numberWithBool:NO],
                              nil];
    database.menu_complete = [NSMutableArray arrayWithObjects:
                              @"",
                              @"",
                              @"",
                              @"",
                              nil];
            
    self.contentSizeForViewInPopover = CGSizeMake(310.0, self.tableView.rowHeight*2.0);
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(moveOnToCertainMenuPage:)
     name:@"moveOnToCertainMenuPage" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(moveOnToCertainPage:)
     name:@"certainPage" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(greyOutMenu:)
     name:@"greyOutMenu" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(resetAllTabsExceptRoom:)
     name:@"resetAllTabsExceptRoom" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(resetAllTabs:)
     name:@"resetAllTabs" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(loadSavedViewsFromVariables:)
     name:@"loadSavedViewsFromVariables" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(alertDBError:)
     name:@"alertDBError" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(displaySaveTime:)
     name:@"displaySaveTime" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCompletePDF:) name:@"showCompletePDF" object:nil];
    
    /******ADD TOOLBAR ********/
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0,704,320, 44);
    menuButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Menu"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                   action:@selector(showMenu:)];
    logoutButton = [[UIBarButtonItem alloc] 
                                   initWithTitle:@"Log out"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(logout:)];
    summaryButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Save & Review"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(summary:)];
    debugButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Feedback"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(debug:)];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
/*    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, settingsButton,deleteButton,aboutButton, flexibleSpace, nil]];*/
    NSArray *items;
    if (database.debugMode == NO) {
        items = [NSArray arrayWithObjects: menuButton, flexibleSpace, summaryButton, flexibleSpace, logoutButton, nil];
    }
    if (database.debugMode == YES) {
        items = [NSArray arrayWithObjects: menuButton, flexibleSpace, summaryButton, flexibleSpace, debugButton, flexibleSpace, logoutButton, nil];
    }
    
    [toolbar setItems:items animated:NO];
    [self.navigationController.view addSubview:toolbar];
    
    saveTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,620,320, 44)];
    [saveTimeLabel setText:@""];
    [saveTimeLabel setTextColor:[UIColor darkGrayColor]];
    [saveTimeLabel setBackgroundColor:[UIColor clearColor]];
    [saveTimeLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 12.0f]];
    [self.tableView addSubview:saveTimeLabel];
        
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([database class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *propType = property_getAttributes(property);
        if(propName) {
            
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            NSString *propertyNSType;
            if ([[propertyName substringToIndex:8] isEqualToString:@"current_"]) {
                if ([propertyType rangeOfString:@"NSString"].location != NSNotFound)
                {
                    propertyNSType = @"NSString";
                }
                else if ([propertyType rangeOfString:@"NSMutableDictionary"].location != NSNotFound){
                    propertyNSType = @"NSMutableDictionary";
                }
                else if ([propertyType rangeOfString:@"NSMutableArray"].location != NSNotFound){
                    propertyNSType = @"NSMutableArray";
                }
                else {
                    propertyNSType = @"";
                }
                //3 = 1 + 2 = (NSKeyValueObservingOptionNew = 0x01) + (NSKeyValueObservingOptionOld = 0x02)
                [database addObserver:self forKeyPath:propertyName options:3 context:(__bridge void *)(propertyNSType)];
            }
        }
    }
    free(properties);
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    
    isql *database = [isql initialize];
    NSString *propertyNSType = [NSString stringWithFormat:@"%@", context];
    
    if (database.editing_flag == 1) {
        
        if ([propertyNSType isEqualToString:@"NSString"]) {
            NSString *oldString, *newString;
            int flag = 0;
            if ([change objectForKey:@"old"] != [NSNull null]) {
                oldString = [change objectForKey:@"old"];
                flag++;
            }
            if ([change objectForKey:@"new"] != [NSNull null]) {
                newString = [change objectForKey:@"new"];
                flag++;
            }
            if (flag == 1) {
                [saveTimeLabel setTextColor:[UIColor redColor]];
                [saveTimeLabel setText: @"Unsaved changes"];
                NSLog(@"NSString %@, old value is: %@ ---- new value is %@ -- flag is %d", keyPath, oldString, newString, flag);
            }
            else if (flag == 2 && ![oldString isEqualToString:newString]) {
                [saveTimeLabel setTextColor:[UIColor redColor]];
                [saveTimeLabel setText: @"Unsaved changes"];
                NSLog(@"NSString %@, old value is: %@ ---- new value is %@ -- flag is %d", keyPath, oldString, newString, flag);
            }
        }
        else if ([propertyNSType isEqualToString:@"NSMutableDictionary"]) {
            NSMutableDictionary *oldDict, *newDict;
            int flag = 0;
            if ([change objectForKey:@"old"] != [NSNull null]) {
                oldDict = [change objectForKey:@"old"];
                flag++;
            }
            if ([change objectForKey:@"new"] != [NSNull null]) {
                newDict = [change objectForKey:@"new"];
                flag++;
            }
            if (flag == 1) {
                [saveTimeLabel setTextColor:[UIColor redColor]];
                [saveTimeLabel setText: @"Unsaved changes"];
                NSLog(@"NSMutableDictionary %@, old value is: %@ ---- new value is %@ -- flag is %d", keyPath, oldDict, newDict, flag);
            }
            else if (flag == 2 && ![oldDict isEqualToDictionary:newDict]) {
                [saveTimeLabel setTextColor:[UIColor redColor]];
                [saveTimeLabel setText: @"Unsaved changes"];
                NSLog(@"NSMutableDictionary %@, old value is: %@ ---- new value is %@ -- flag is %d", keyPath, oldDict, newDict, flag);
            }
        }
        else if ([propertyNSType isEqualToString:@"NSMutableArray"]) {
            NSMutableArray *oldArray, *newArray;
            int flag = 0;
            if ([change objectForKey:@"old"] != [NSNull null]) {
                oldArray = [change objectForKey:@"old"];
                flag++;
            }
            if ([change objectForKey:@"new"] != [NSNull null]) {
                newArray = [change objectForKey:@"new"];
                flag++;
            }
            if (flag == 1) {
                [saveTimeLabel setTextColor:[UIColor redColor]];
                [saveTimeLabel setText: @"Unsaved changes"];
                NSLog(@"NSMutableArray %@, old value is: %@ ---- new value is %@ -- flag is %d", keyPath, oldArray, newArray, flag);
            }
            else if (flag == 2 && ![oldArray isEqualToArray:newArray]) {
                [saveTimeLabel setTextColor:[UIColor redColor]];
                [saveTimeLabel setText: @"Unsaved changes"];
                NSLog(@"NSMutableArray %@, old value is: %@ ---- new value is %@ -- flag is %d", keyPath, oldArray, newArray, flag);
            }
        }
        else {
            
        }
    }
}

-(void) viewDidUnload {
	[super viewDidUnload];
	
	self.splitViewController = nil;
    
	self.rootPopoverButtonItem = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    
    isql *database = [isql initialize];
    
    if (database.first_time_load == 1) {
        NSDictionary *dict= [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"index"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
        database.first_time_load = 0;
    }
    
    [super viewDidAppear:YES];
    
}
/*
-(void) viewWillLayoutSubviews {
    //move the code below into this function, so that it won't show a flip scene when it loads.
    isql *database = [isql initialize];
    if (database.editing_flag == 1) {
        if (self.view.frame.origin.y != -110) {
            [self.view setFrame:CGRectMake(0, -110, self.view.frame.size.width, self.view.frame.size.height+110)];
        }
    }
    else {
        if (self.view.frame.origin.y != 0) {
            [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 814)];
        }
    }
    
}
 */
#pragma mark -
#pragma mark Rotation support

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //NSLog(@"rotate");
    
}
/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    //NSLog(@"did rotate");
    
    isql *database = [isql initialize];
    if (database.editing_flag == 1) {
        [self.view setFrame:CGRectMake(0, -110, self.view.frame.size.width, self.view.frame.size.height+110)];
    }
    else {
        [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
}
*/
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	return 1;
}

/*---------------------------------------------------------------------------
 *
 *--------------------------------------------------------------------------*/
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	// Break the path into it's components (filename and extension)
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    
    NSString * pdfFileName = [renderer getPDFFileName];
        
	return [NSURL fileURLWithPath:pdfFileName];
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    isql *database = [isql initialize];
    
    //add justHighLight attribute so that it does not saveVariable each time a button is clicked
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:database.selectedMenu] forKey:@"index"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"justHighLight"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    // Two sections, one for each detail view controller.
    if (section == 0) {
        return 2;
    }
    else{
        return 2;
    }
}


- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RootViewControllerCellIdentifier";
    
    MainMenuCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"MainMenuCell" owner:nil options:nil];
        
        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]])
            {
                cell = (MainMenuCell*)view;
            }
        }
    }
    
    isql *database = [isql initialize];    
       
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.checkCompleteLabel.text = @"School";
            cell.userInteractionEnabled = [[database.menu_grey_out objectAtIndex:0] boolValue];
            if ([[database.menu_grey_out objectAtIndex:0] boolValue]) {
                cell.checkCompleteLabel.textColor = [UIColor blackColor];
            }else{
                cell.checkCompleteLabel.textColor = [UIColor grayColor];
            }
            
        }
        else if (indexPath.row == 1) {
            cell.checkCompleteLabel.text = @"Room";
            cell.userInteractionEnabled = [[database.menu_grey_out objectAtIndex:1] boolValue];
            if ([[database.menu_grey_out objectAtIndex:1] boolValue]) {
                cell.checkCompleteLabel.textColor = [UIColor blackColor];
            }else{
                cell.checkCompleteLabel.textColor = [UIColor grayColor];
            }
        }
    }
    else {
        if (indexPath.row == 0){
            cell.checkCompleteLabel.text = @"Room Installation Data";
            cell.userInteractionEnabled = [[database.menu_grey_out objectAtIndex:2] boolValue];
            if ([[database.menu_grey_out objectAtIndex:2] boolValue]) {
                cell.checkCompleteLabel.textColor = [UIColor blackColor];
            }else{
                cell.checkCompleteLabel.textColor = [UIColor grayColor];
            }
            if ([[database.menu_complete objectAtIndex:2] isEqualToString:@"Incomplete"]) {
                cell.checkCompleteLabelTwo.textColor = [UIColor redColor];
            }
            if ([[database.menu_complete objectAtIndex:2] isEqualToString:@"Complete"]) {
                cell.checkCompleteLabelTwo.textColor = [UIColor colorWithRed:41.0/255.0 green:125.0/255.0 blue:47.0/255.0 alpha:1];
            }
            cell.checkCompleteLabelTwo.text = [database.menu_complete objectAtIndex:2];
        }        
        else if (indexPath.row == 1){
            cell.checkCompleteLabel.text = @"Final Installation Photo";
            cell.userInteractionEnabled = [[database.menu_grey_out objectAtIndex:3] boolValue];
            if ([[database.menu_grey_out objectAtIndex:3] boolValue]) {
                cell.checkCompleteLabel.textColor = [UIColor blackColor];
            }else{
                cell.checkCompleteLabel.textColor = [UIColor grayColor];
            }
            if ([[database.menu_complete objectAtIndex:3] isEqualToString:@"Incomplete"]) {
                cell.checkCompleteLabelTwo.textColor = [UIColor redColor];
            }
            if ([[database.menu_complete objectAtIndex:3] isEqualToString:@"Complete"]) {
                cell.checkCompleteLabelTwo.textColor = [UIColor colorWithRed:41.0/255.0 green:125.0/255.0 blue:47.0/255.0 alpha:1];
            }
            cell.checkCompleteLabelTwo.text = [database.menu_complete objectAtIndex:3];
        }
    }
        
    return cell;
}


#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //save it locally when switch tabs
    isql *database = [isql initialize];
    //only update cover page if school tab or room tab is clicked, otherwise save all variables, to avoid unnecessary function call to savevariables, which refresh room status to "ready"
    if ([indexPath section] == 0) {
        [database updateLocalDestForCoverPage];
    }
        /*
     Create and configure a new detail view controller appropriate for the selection.
     */
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    
    /************* store current selected menu  *************/
    //first section has 2 rows, so multiply section by 2
    database.selectedMenu = section * 2 + row;
    //UIViewController  *detailViewController = nil;
    if ([indexPath section]==0) {
        if (row == 0) {
            
            if(firstViewControllers == nil){
                
                FirstDetailViewController *tempDetailViewController = [[FirstDetailViewController alloc] initWithNibName:@"FirstDetailView" bundle:nil];
                tempDetailViewController.title = @"School";
                UIViewController *detailViewController = tempDetailViewController;
                // Update the split view controller's view controllers array.
                
                UINavigationController *DetailNav = [[UINavigationController alloc]initWithRootViewController:detailViewController];
                firstViewControllers = [[NSArray alloc] initWithObjects:self.navigationController, DetailNav, nil];
                
            }
            splitViewController.viewControllers = firstViewControllers;
            
            //pop to the root view controller when click "Cover" in main menu
            UINavigationController *tempController = [firstViewControllers objectAtIndex:1];
            
            NSArray *popedViewController = [tempController popToRootViewControllerAnimated:NO];
            //if not in the welcome page originally, go to the cover sheet page
            if ([popedViewController count] > 0) {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"autoLoadCurrentActivity" object:self];
            }
            
        }
        
        if (row == 1) {
            
            if(secondViewControllers == nil){
                
                SecondDetailViewController *tempDetailViewController = [[SecondDetailViewController alloc] initWithNibName:@"SecondDetailView" bundle:nil];
                
                tempDetailViewController.title = @"Room";
                UIViewController *detailViewController = tempDetailViewController;
                // Update the split view controller's view controllers array.
                
                UINavigationController *DetailNav = [[UINavigationController alloc]initWithRootViewController:detailViewController];
                secondViewControllers = [[NSArray alloc] initWithObjects:self.navigationController, DetailNav, nil];
                
            }
            splitViewController.viewControllers = secondViewControllers;
            
        }
    }
    else {
        if (row == 0) {
            
            if(thirdViewControllers == nil){
                
                ThirdDetailView *tempDetailViewController = [[ThirdDetailView alloc] initWithNibName:@"ThirdDetailView" bundle:nil];
                tempDetailViewController.title = @"Room Installation Data";
                
                UIViewController *detailViewController = tempDetailViewController;
                // Update the split view controller's view controllers array.
                
                UINavigationController *DetailNav = [[UINavigationController alloc]initWithRootViewController:detailViewController];
                thirdViewControllers = [[NSArray alloc] initWithObjects:self.navigationController, DetailNav, nil];
                
            }
            splitViewController.viewControllers = thirdViewControllers;
        }
                
        if (row == 1) {
            
            
            if(fifteenthViewControllers == nil){
                
                FifteenthDetailView *tempDetailViewController = [[FifteenthDetailView alloc] initWithNibName:@"FifteenthDetailView" bundle:nil];
                tempDetailViewController.title = @"Final Installation Photo";
                
                UIViewController *detailViewController = tempDetailViewController;
                // Update the split view controller's view controllers array.
                
                UINavigationController *DetailNav = [[UINavigationController alloc]initWithRootViewController:detailViewController];        
                fifteenthViewControllers = [[NSArray alloc] initWithObjects:self.navigationController, DetailNav, nil];
                
            }
            splitViewController.viewControllers = fifteenthViewControllers;
        }
        
    }
    
        //[detailViewController release];
}

-(void)moveOnToCertainMenuPage:(NSNotification*)notifications {
             
    // Highlight the new Row
    //int nextSelection = selection.row +1; // grab the int value of the row (cuz it actually has both the section and the row {section, row}) and add 1
    NSIndexPath *indexSet;
    
    int nextSelection = [[[notifications userInfo] valueForKey:@"index"] intValue];
    
    int justHighLight = [[[notifications userInfo] valueForKey:@"justHighLight"] intValue];
    
    if (nextSelection < 2) {
        //int nextSelection = 0;
        NSUInteger indexArr[] = {0,nextSelection}; // now throw this back into the integer set
        indexSet = [NSIndexPath indexPathWithIndexes:indexArr length:2]; // create a new index path
    }
    else{
        //int nextSelection = 0;
        NSUInteger indexArr[] = {1,nextSelection-2}; // now throw this back into the integer set
        indexSet = [NSIndexPath indexPathWithIndexes:indexArr length:2]; // create a new index path
    }
     
    [self.tableView selectRowAtIndexPath:indexSet animated:YES scrollPosition:UITableViewScrollPositionNone]; // tell the table to highlight the new row
    
    
    // Move to the new View
    UITableView *newTableView = self.tableView; // create a pointer to a new table View
    if (justHighLight == 0) {
        [self tableView:newTableView didSelectRowAtIndexPath:indexSet]; // call the didSelectRowAtIndexPath function
    }
    
    //[newTableView autorelease];  //let the new tableView go.  ok.  this crashes it, so no releasing for now.    
    
}

-(void)moveOnToCertainPage:(NSNotification*)notifications {
    
    UIViewController *detailViewController = nil;
        
    NSString *nibName = [[notifications userInfo] valueForKey:@"index"];
   //FirstDetailView3
        FirstDetailView3 *newDetailViewController = [[FirstDetailView3 alloc] initWithNibName:nibName bundle:nil];
        detailViewController = newDetailViewController;
    
    
    
    // Update the split view controller's view controllers array.
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, detailViewController, nil];
    splitViewController.viewControllers = viewControllers;
    
}


-(void)greyOutMenu:(NSNotification*)notifications{
    
    [self.tableView reloadData];
}

-(void)resetAllTabsWhenExitingRoom {
    
    /******** Call this function when it exiting a room *******/
    [saveTimeLabel setText: @""];
    
    thirdViewControllers = nil;
    fifteenthViewControllers = nil;
    
    /********* reset all values ********/
    isql *database = [isql initialize];
    [database resetVariables];
    database.current_classroom_number = nil;
    database.current_classroom_floor = nil;
    database.current_classroom_grade = nil;
    database.current_classroom_notes = nil;
    database.current_raceway_part_9 = nil;
    database.current_raceway_part_10 = nil;
    
    NSLog(@"ResetAllTabsWhenExitingRoom");
}

-(void)resetAllTabsExceptRoom:(NSNotification*)notifications{
    
    /* call this function when a new room is added */
    
    thirdViewControllers = nil;
    fifteenthViewControllers = nil;
    
    /********* reset all values ********/
    isql *database = [isql initialize];
    [database resetVariables];
    
    NSLog(@"reset room");
    
    /***************** save variable ****************/
    [database saveVariableToLocalDest];
    [database addNumberToAppIcon];
    /********* reset menu grey out ********/
}

-(void)resetAllTabs:(NSNotification*)notifications{
    
    /* call this function when a new date or location is picked */
    
    secondViewControllers = nil;
    thirdViewControllers = nil;
    fifteenthViewControllers = nil;
    
    /********* reset all values ********/
    isql *database = [isql initialize];
    
    [database resetVariables];
    
    database.classrooms_in_one_location = nil;
    
    database.current_classroom_number = nil;
    
    database.current_classroom_floor = nil;
    
    database.current_classroom_notes = nil;
    
    database.current_classroom_grade = nil;
    
    database.classroom_index = nil;
    
    database.current_signature_file_directory_1 = nil;
        
    database.current_signature_file_directory_3 = nil;
    
    database.current_print_name_1 = nil;
    
    database.current_print_name_3 = nil;
    
    database.current_agreement_1 = nil;
    
    database.current_agreement_2 = nil;
    
    database.current_customer_notes = nil;
    
    database.current_comlete_pdf_file_name = nil;
    
}


-(IBAction)showMenu:(id)sender{
    
    isql *database = [isql initialize];
    
    if (menuActionSheet == nil) {
        if(database.editing_flag == 1){
            menuActionSheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Sync" otherButtonTitles: @"Save", @"Exit", nil];
        }
        else {
            menuActionSheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Sync" otherButtonTitles: @"Save", nil];
        }
    }
    
    [menuActionSheet showFromBarButtonItem:menuButton animated:YES];
}

- (IBAction) logout:(id)sender {
    
    logoutAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure to log out?" message:nil delegate:self
                                 cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
    [logoutAlert show];
    
}

- (IBAction) summary:(id)sender {
    
    isql *database = [isql initialize];
    
    if (database.editing_flag == 1) {
        FileSystem *fs = [[FileSystem alloc] init];
        NSArray *fileNames = [fs generateFileNames:database.current_teq_rep withActivity:database.current_activity_no andRoomNumber:database.current_classroom_number andDateTime:database.current_date];
        [fs removeOldFiles:fileNames];
        [fs copyOldFiles:fileNames];
    }
    
    if ([database.current_activity_no length] == 0 ) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"Please start or load an installation to view the summary." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
        return;
    }
    [NSThread detachNewThreadSelector:@selector(myThreadMethodAfterClickingSummary:) toTarget:self withObject:nil];
    
    [database saveVariableToLocalDest];
    
    //do not update the whole activity for PDF
    //[database updateLocalDestForSummary];
        
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    renderer.callBackFunction = @"preview";

    [renderer loadVariablesForPDF];
}

-(void)showCompletePDF:(NSNotification *)notifications {
        
    QLPreviewController *temp = [[QLPreviewController alloc] init];
    
    [temp setDelegate:self];
	// Set data source
	[temp setDataSource:self];
    [temp setCurrentPreviewItemIndex:0];
    
    temp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    temp.modalPresentationStyle = UIModalPresentationFullScreen;
    // ANIMATED TRANSITION WILL RESULT IN ERROR
    //[splitViewController presentModalViewController:temp animated: NO];
    [splitViewController presentViewController:temp animated:NO completion:nil];
    
   
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    isql *database = [isql initialize];
    switch (buttonIndex) {
        
        case 0:
            [self sync];
            break;
        case 1:
            if (database.editing_flag == 1) {
                FileSystem *fs = [[FileSystem alloc] init];
                NSArray *fileNames = [fs generateFileNames:database.current_teq_rep withActivity:database.current_activity_no andRoomNumber:database.current_classroom_number andDateTime:database.current_date];
                [fs removeOldFiles:fileNames];
                [fs copyOldFiles:fileNames];
            }
            [database saveVariableToLocalDest];
            //[self saveValuesAndPDF];
            break;
        /*case 2:
            [self finishEditing];
            break;*/
        case 2:
            /*existWithoutSavingAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure to exit to the main menu without saving?" message:nil delegate:self
                                                       cancelButtonTitle: @"No" otherButtonTitles: @"Yes", nil];*/
            if ([saveTimeLabel.text isEqualToString: @"Unsaved changes"]) {
                existWithoutSavingAlert = [[UIAlertView alloc] initWithTitle:@"Do you want to save the changes you made? " message:nil delegate:self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Save", @"Don't Save", nil];
                [existWithoutSavingAlert show];
            }
            else {
                [self exitWithoutSaving];
            }
            break;
            /*case 3:
             [self viewReport];
             break;
             */
        default:
            break;
    }
    menuActionSheet = nil;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView == existWithoutSavingAlert) {
        if (buttonIndex == 1) {
            [self finishEditing];
        }
        else if (buttonIndex == 2) {
            [self exitWithoutSaving];
        }
    }
    if (alertView == logoutAlert) {
        /******* log out alert ******/
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                
                /********* click yes on log out alert ********/
                isql *database = [isql initialize];
                database.moveSpiral = YES;
                [self saveValuesAndPDF];
                /********* before log out, go to first page, to not get into trouble with other pages' entry check ********/
                
                /* call this function when user log out */
                NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt: 0] forKey:@"index"]; 
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
                
                
                firstViewControllers = nil;
                secondViewControllers = nil;
                thirdViewControllers = nil;
                fifteenthViewControllers = nil;
                
                /********* reset all values ********/
                
                database.editing_flag = 0;
                [database.menu_grey_out replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
                [database.menu_grey_out replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:YES]];
                [database.menu_grey_out replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
                [database.menu_grey_out replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
                
                database.menu_complete = [NSMutableArray arrayWithObjects:
                                          @"",
                                          @"",
                                          @"",
                                          @"",
                                          nil];
                
                [self.tableView reloadData];
                
                self.navigationItem.title = @"INSTALLATIONS SIGN OFF";
                
                [database resetVariables];
                
                database.current_username =  nil;
                
                database.signature_filename = nil;
                
                database.selected_date = nil;
                
                database.current_location = nil;
                
                database.selected_location = nil;
                
                database.current_teq_rep = nil;
                
                database.current_activity_no = nil;
                
                database.current_date = nil;
                
                database.current_so = nil;
                                                                
                database.current_bp_code = nil;
                
                database.current_district = nil;
                
                database.current_pod = nil;
                
                database.current_pdf1 = nil;
                
                database.current_pdf2 = nil;
                
                database.current_type_of_work = nil;
                
                database.current_job_status = nil;
                
                database.current_arrival_time = nil;
                
                database.current_departure_time = nil;
                
                database.current_reason_for_visit = nil;
                
                database.current_job_summary = nil;
                
                database.current_change_order = nil;
                
                database.current_change_approved_by_print_name = nil;
                
                database.current_change_approved_by_signature = nil;
                                
                database.current_primary_contact = nil;
                                
                database.classrooms_in_one_location = nil;
                
                database.current_classroom_number = nil;
                
                database.current_classroom_floor = nil;
                
                database.current_classroom_notes = nil;
                
                database.current_classroom_grade = nil;
                
                database.classroom_index = nil;
                
                database.current_signature_file_directory_1 = nil;
                           
                database.current_signature_file_directory_3 = nil;
                
                database.current_print_name_1 = nil;
                                
                database.current_print_name_3 = nil;
                
                database.current_customer_notes = nil;

                database.current_agreement_1 = nil;
                
                database.current_agreement_2 = nil;
                                          
                database.current_comlete_pdf_file_name = nil;
                                
                database.src_latitude = nil;
                
                database.src_longitude = nil;
                                
          
                
                loginModal *temp = [[loginModal alloc] initWithNibName:@"loginModal" bundle:[NSBundle mainBundle]];
                
                temp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                //[splitViewController presentModalViewController:temp animated: YES];
                [splitViewController presentViewController:temp animated:YES completion:nil];
                break;
            }
            default:
                break;
        } 
        
    }
    
}

- (void) sync{
    
    isql *database = [isql initialize];
    
    if (database.editing_flag == 1) {
        FileSystem *fs = [[FileSystem alloc] init];
        NSArray *fileNames = [fs generateFileNames:database.current_teq_rep withActivity:database.current_activity_no andRoomNumber:database.current_classroom_number andDateTime:database.current_date];
        [fs removeOldFiles:fileNames];
    }
    
    [NSThread detachNewThreadSelector:@selector(myThreadMethodAfterSync:) toTarget:self withObject:nil];
    
    //save first, because move to room menu does not call save function
    [database saveVariableToLocalDest];
    [database.menu_grey_out replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
    [database.menu_grey_out replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:YES]];
    [database.menu_grey_out replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
    [database.menu_grey_out replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
    
    database.menu_complete = [NSMutableArray arrayWithObjects:
                              @"",
                              @"",
                              @"",
                              @"",
                              nil];
    
    [self.tableView reloadData];
    /*
    [UIView beginAnimations:@"menuOffset" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
    */
    database.editing_flag = 0;
    self.navigationItem.title = @"INSTALLATIONS SIGN OFF";
    
    [self resetAllTabsWhenExitingRoom];
    
    NSDictionary *dict;
    if (database.selectedMenu == 0) {
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"index"];
    }else {
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"index"];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
    
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    renderer.callBackFunction = @"sync";
    
    [renderer loadVariablesForPDF];
        
}

- (void) exitWithoutSaving {
    isql *database = [isql initialize];
    
    FileSystem *fs = [[FileSystem alloc] init];
    NSArray *fileNames = [fs generateFileNames:database.current_teq_rep withActivity:database.current_activity_no andRoomNumber:database.current_classroom_number andDateTime:database.current_date];
    [fs removeNewFiles:fileNames];
    [fs renameOldFiles:fileNames];
  
    [database.menu_grey_out replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
    [database.menu_grey_out replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:YES]];
    [database.menu_grey_out replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
    [database.menu_grey_out replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
    
    database.menu_complete = [NSMutableArray arrayWithObjects:
                              @"",
                              @"",
                              @"",
                              @"",
                              nil];
    
    [self.tableView reloadData];
    /*
    [UIView beginAnimations:@"menuOffset" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
    */
    database.editing_flag = 0;
    self.navigationItem.title = @"INSTALLATIONS SIGN OFF";
    
    [self resetAllTabsWhenExitingRoom];
    
    NSDictionary *dict;
    if (database.selectedMenu == 0) {
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"index"];
    }else {
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"index"];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
    /*
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    renderer.callBackFunction = @"finishEditing";
    
    [renderer loadVariablesForPDF];
     */
}

- (void) finishEditing {
    
    isql *database = [isql initialize];
    
    FileSystem *fs = [[FileSystem alloc] init];
    NSArray *fileNames = [fs generateFileNames:database.current_teq_rep withActivity:database.current_activity_no andRoomNumber:database.current_classroom_number andDateTime:database.current_date];
    [fs removeOldFiles:fileNames];
    
    //[NSThread detachNewThreadSelector:@selector(myThreadMethodAfterFinishEditing:) toTarget:self withObject:nil];
    
    //save first, because move to room menu does not call save function
    [database saveVariableToLocalDest];
    [database.menu_grey_out replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
    [database.menu_grey_out replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:YES]];
    [database.menu_grey_out replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
    [database.menu_grey_out replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
    
    database.menu_complete = [NSMutableArray arrayWithObjects:
                              @"",
                              @"",
                              @"",
                              @"",
                              nil];
    
    [self.tableView reloadData];
    /*
    [UIView beginAnimations:@"menuOffset" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
    */
    database.editing_flag = 0;
    self.navigationItem.title = @"INSTALLATIONS SIGN OFF";
    
    [self resetAllTabsWhenExitingRoom];
    
    NSDictionary *dict;
    if (database.selectedMenu == 0) {
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"index"];
    }else {
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"index"];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict]; 
    /*
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    renderer.callBackFunction = @"finishEditing";
    
    [renderer loadVariablesForPDF];
     */
}

- (void)saveValuesAndPDF {
    
    [NSThread detachNewThreadSelector:@selector(myThreadMethodAfterFinishSaving:) toTarget:self withObject:nil];
    
    isql *database = [isql initialize];
    
    [database saveVariableToLocalDest];
    
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    
    renderer.callBackFunction = @"saving";
    
    [renderer loadVariablesForPDF];
}

- (void)myThreadMethodAfterFinishSaving:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Saving";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (void)myThreadMethodAfterFinishEditing:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Saving";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (void)myThreadMethodAfterSync:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Synchronizing";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (void)myThreadMethodAfterClickingSummary:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Loading";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (void) alertDBError:(NSNotification*)notifications {
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    NSString *tempMessage = [[notifications userInfo] valueForKey:@"index"];
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:tempMessage message:nil delegate:self cancelButtonTitle:nil              otherButtonTitles: @"Yes", nil];
    [alert show];
}

- (void) loadSavedViewsFromVariables:(NSNotification*)notifications {
    
    isql *database = [isql initialize];
    database.loadingViews = 1;
    
    database.cable_rca_video = nil;
    database.cable_rca_audio = nil;
    database.cable_cat5e = nil;
    database.cable_vgamf = nil;
    database.cable_hdmisplitter = nil;
    database.cable_usbxt = nil;
   
    NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
    [myDict setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:0]];
    [myDict setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:1]];
    [myDict setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:2]];
    [myDict setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:3]];
    
    database.menu_complete = [NSMutableArray arrayWithObjects:
                              @"",
                              @"",
                              @"Incomplete",
                              @"Incomplete",
                              nil];
    
    [database greyoutMenu:myDict andHightlight:2];
    
    {
        /******** Peripherals ********/
        ThirdDetailView *tempDetailViewController = [[ThirdDetailView alloc] initWithNibName:@"ThirdDetailView" bundle:nil];
        tempDetailViewController.title = @"Room Installation Data";
        
        UIViewController *detailViewController = tempDetailViewController;
        
        UINavigationController *DetailNav = [[UINavigationController alloc]initWithRootViewController:detailViewController];
        thirdViewControllers = [[NSArray alloc] initWithObjects:self.navigationController, DetailNav, nil];
        
        /******* access the property will load the view controller ********/
        [tempDetailViewController view];
        
        //tempDetailViewController.installers.text = database.current_installer;
        tempDetailViewController.statusOutlet.text = database.current_status;
        tempDetailViewController.commentsOutlet.text = database.current_general_notes;        
        if ([database.current_use_van_stock isEqualToString:@"Yes"])
        {
            tempDetailViewController.skipSwitch.on = YES;
            tempDetailViewController.editVanStock.hidden = NO;
            tempDetailViewController.vanStockTextView.hidden = NO;
            //tempDetailViewController.vanStockInputField.hidden = NO;
        }
        else {
            tempDetailViewController.skipSwitch.on = NO;
            tempDetailViewController.editVanStock.hidden = YES;
            tempDetailViewController.vanStockTextView.hidden = YES;
            //tempDetailViewController.vanStockInputField.hidden = YES;
        }
        //tempDetailViewController.vanStockInputField.text = database.current_van_stock;
    }
    
    {
        /******** Take Picture ********/
        FifteenthDetailView *tempDetailViewController = [[FifteenthDetailView alloc] initWithNibName:@"FifteenthDetailView" bundle:nil];
        tempDetailViewController.title = @"Final Installation Photo";
        
        UIViewController *detailViewController = tempDetailViewController;
        
        UINavigationController *DetailNav = [[UINavigationController alloc]initWithRootViewController:detailViewController];        
        fifteenthViewControllers = [[NSArray alloc] initWithObjects:self.navigationController, DetailNav, nil];
        
        /******* access the property will load the view controller ********/
        [tempDetailViewController view];
                
        if ([database.current_photo_file_directory_1 length] > 10 ) {
            UIImage *temp_photo = [self loadImage: database.current_photo_file_directory_1 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [tempDetailViewController loadImageWithImage:temp_photo atIndex:1];
        }
        if ([database.current_photo_file_directory_2 length] > 10 ) {
            UIImage *temp_photo = [self loadImage: database.current_photo_file_directory_2 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [tempDetailViewController loadImageWithImage:temp_photo atIndex:2];
        }
        if ([database.current_photo_file_directory_3 length] > 10 ) {
            UIImage *temp_photo = [self loadImage: database.current_photo_file_directory_3 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [tempDetailViewController loadImageWithImage:temp_photo atIndex:3];
        }
        if ([database.current_photo_file_directory_4 length] > 10 ) {
            UIImage *temp_photo = [self loadImage: database.current_photo_file_directory_4 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [tempDetailViewController loadImageWithImage:temp_photo atIndex:4];
        }
        if ([database.current_photo_file_directory_5 length] > 10 ) {
            UIImage *temp_photo = [self loadImage: database.current_photo_file_directory_5 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [tempDetailViewController loadImageWithImage:temp_photo atIndex:5];
        }
        if ([database.current_photo_file_directory_6 length] > 10 ) {
            UIImage *temp_photo = [self loadImage: database.current_photo_file_directory_6 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [tempDetailViewController loadImageWithImage:temp_photo atIndex:6];
        }
        if ([database.current_photo_file_directory_7 length] > 10 ) {
            UIImage *temp_photo = [self loadImage: database.current_photo_file_directory_7 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [tempDetailViewController loadImageWithImage:temp_photo atIndex:7];
        }
        if ([database.current_photo_file_directory_8 length] > 10 ) {
            UIImage *temp_photo = [self loadImage: database.current_photo_file_directory_8 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [tempDetailViewController loadImageWithImage:temp_photo atIndex:8];
        }
        
    }    
    
    
    NSString *temp_title;
    if ([database.current_location length] <= 15) {
        temp_title = database.current_location;
    }else {
        temp_title = [database.current_location substringToIndex:15];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - RM %@",temp_title, database.current_classroom_number];
    
    //change saveTimeLabel
    //[saveTimeLabel setText: @"The room has not been saved since it is opened."];
    [saveTimeLabel setText: @""];
    /*
    [UIView beginAnimations:@"menuOffset" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(0, -110, self.view.frame.size.width, self.tableView.frame.size.height+110)];
    [UIView commitAnimations];
     */
    database.editing_flag = 1;
    
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"index"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict]; 
    
    NSLog(@"loadSavedViewsFromVariables");
    
    database.loadingViews = 0;
    
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]);
    return result;
}

-(void)displaySaveTime:(NSNotification*)notifications{
    
    NSString *saveTimeString = [NSString stringWithFormat:@"%@", [[notifications userInfo] valueForKey:@"datetime"]];
    if ([saveTimeString isEqualToString:@"Saved all changes"]) {
        [saveTimeLabel setTextColor:[UIColor colorWithRed:41.0/255.0 green:125.0/255.0 blue:47.0/255.0 alpha:1]];
        [saveTimeLabel setText: saveTimeString];
    }
    if ([saveTimeString isEqualToString:@"Unsaved changes"]) {
        [saveTimeLabel setTextColor:[UIColor redColor]];
        [saveTimeLabel setText: saveTimeString];
    }
}
#pragma mark -
#pragma mark Memory management


@end
