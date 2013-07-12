

#import "SecondDetailViewController.h"
#import "isql.h"
#import "sqlite3.h"
#import "RoomCell.h"
#import "LGViewHUD.h"
#import "FileSystem.h"
#import <objc/runtime.h>
const char MyConstantKey;

@implementation SecondDetailViewController

@synthesize navigationBar;
@synthesize myModalViewController;
@synthesize schoolNameOutlet;
@synthesize teqRepOutlet;
@synthesize activityNoOutlet;
@synthesize dateOutlet;
@synthesize existingEquipOutlet;
@synthesize roomNoInTextField;
@synthesize floorNoTextField;
@synthesize notesNoTextField;
@synthesize gradeNoTextField;
@synthesize tableviews;
@synthesize goBackToWhichPage;
@synthesize lastDate;
@synthesize scrollview;
@synthesize loadButton;

@synthesize lastLocation;
@synthesize activityIndicator;

#pragma mark -
#pragma mark View lifecycle

-(void) viewDidLoad {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(restoreView) name:UIKeyboardWillHideNotification object:nil];
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.gestureRecognizer.cancelsTouchesInView = NO;
    self.gestureRecognizer.delegate = self;
    
    //[self.tableviews addGestureRecognizer:self.gestureRecognizer];
    [self.view addGestureRecognizer:self.gestureRecognizer];
    
    [scrollview setFrame:CGRectMake(0, 44, 703, 704)];
    //[scrollview setContentSize:CGSizeMake(703, 1500)];
    roomNoInTextField.delegate = self;
    floorNoTextField.delegate = self;
    notesNoTextField.delegate = self;
    gradeNoTextField.delegate = self;
    [self.tableviews setBackgroundView:nil];
    [self.tableviews setBackgroundColor:nil];
    
    activityIndicator.hidesWhenStopped = YES;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(RefreshRoomList:)
     name:@"RefreshRoomList" object:nil];
    /*
    UIBarButtonItem *saveAndGoToNextPage = [[UIBarButtonItem alloc] initWithTitle:@"Next Step" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAndGoToNextPage)];
    self.navigationItem.rightBarButtonItem = saveAndGoToNextPage;
     */
    NSLog(@"load secondview");
}

-(void) viewWillAppear:(BOOL)animated{
    [scrollview scrollRectToVisible:CGRectMake(0, 0, 703, 704) animated:YES];
    [self.scrollview flashScrollIndicators];
    [super viewWillAppear:YES];
    [self checkIfPreviousPagesAreFinished];
    //[activityIndicator startAnimating];
    isql *database = [isql initialize];
    //if ((![database.current_location isEqualToString: self.lastLocation] || ![database.current_date isEqualToString:self.lastDate]) && database.current_location != nil) {
        //isql *database = [isql initialize];
        schoolNameOutlet.text = database.current_location;
        teqRepOutlet.text = database.current_teq_rep;
        activityNoOutlet.text = database.current_activity_no;
        dateOutlet.text = database.current_date;
    
        [self loadRoomFromDB];
    //}
}

- (void) viewWillDisappear:(BOOL)animated {
    isql *database = [isql initialize];
    self.lastLocation = database.current_location;
    self.lastDate = database.current_date;
    
    [super viewWillDisappear:NO];
    //[self.view endEditing:YES];
    [self hideKeyboard];
}

-(void) viewDidUnload {
    [self setSchoolNameOutlet:nil];
    [self setTeqRepOutlet:nil];
    [self setActivityNoOutlet:nil];
    [self setDateOutlet:nil];
    
    [self setRoomNoInTextField:nil];
    [self setFloorNoTextField:nil];
    [self setNotesNoTextField:nil];
    [self setGradeNoTextField:nil];

    [self setScrollview:nil];
    [self setLoadButton:nil];
    [self setActivityIndicator:nil];
	[super viewDidUnload];
	
	self.navigationBar = nil;
}

- (IBAction)addRoom {
    
    if (self.roomNoInTextField.text!=nil && [self.roomNoInTextField.text length]) {
        NSCharacterSet *illegalCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-_"] invertedSet];
        NSString *convertedStr = [[self.roomNoInTextField.text componentsSeparatedByCharactersInSet:illegalCharSet] componentsJoinedByString:@""];
        
        if ([convertedStr length] == 0) {
            //show alert if they type just &**() as room number
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Room number can only use   0-9, a-z, A-Z, _ , -" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];            
            return;
        }
        self.roomNoInTextField.text = convertedStr;
    }
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please input a room number." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
        
        return;
    }
            
    isql *database = [isql initialize];
    
    for (int i = 0; i< [database.classrooms_in_one_location count]; i++) {
        if ([[[database.classrooms_in_one_location objectAtIndex:i] objectAtIndex:0] isEqualToString: self.roomNoInTextField.text] ) {
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"This room already exists." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];            
            return;
        }
    }
    /*
    if ([database.classrooms_in_one_location count] == 24) {
        return;
    }
    */
    [database saveVariableToLocalDest];
    NSString *current_room_number;
    NSString *current_floor_number;    
    NSString *current_grade;
    NSString *current_notes;
    
    if (self.roomNoInTextField.text == nil ) {
        current_room_number = @"";
    }
    else {
        current_room_number = self.roomNoInTextField.text;
    }
    
    if (self.floorNoTextField.text == nil) {
        current_floor_number = @"";
    }
    else {
        current_floor_number = self.floorNoTextField.text;
    }
    
    if (self.gradeNoTextField.text == nil) {
        current_grade = @"";
    }
    else {
        current_grade = self.gradeNoTextField.text;
    }
    
    if (self.notesNoTextField.text == nil) {
        current_notes = @"";
    }
    else {
        current_notes = self.notesNoTextField.text;
    }
   
    //NSString *current_floor_number = [NSString stringWithFormat:@"%@", self.floorNoTextField.text];
    //NSString *current_notes = [NSString stringWithFormat:@"%@", self.notesNoTextField.text];
    
    if(database.classrooms_in_one_location == nil)
    database.classrooms_in_one_location = [NSMutableArray arrayWithObjects: nil];     
    
    NSMutableArray *newClassRoom = [NSMutableArray arrayWithObjects:nil];
    
    [newClassRoom addObject:current_room_number];
    [newClassRoom addObject:current_floor_number];    
    [newClassRoom addObject:current_grade];
    [newClassRoom addObject:current_notes];
    [newClassRoom addObject:@"notsync"];
    [newClassRoom addObject:@"incomplete"];
    [newClassRoom addObject:@""];
    [newClassRoom addObject:@"Incomplete"];
    
    [database.classrooms_in_one_location addObject: newClassRoom];
    
    database.current_classroom_number = current_room_number;
    database.current_classroom_floor = current_floor_number;
    database.current_classroom_grade = current_grade;
    database.current_classroom_notes = current_notes;
    //database.current_raceway_part_8 = @"notsync";
    database.current_raceway_part_9 = @"incomplete";
    database.current_raceway_part_10 = @"";
    database.current_status = @"Incomplete";
        
    [self.tableviews reloadData];
   
    self.titleRoom.hidden = NO;
    self.titleInstallation.hidden = NO;
    self.titleReport.hidden = NO;
    self.titleSync.hidden = NO;   
    
    float temp_height = 321 + [tableviews contentSize].height;
    
    float height = (temp_height > 615)? temp_height: 615;
    
    [loadButton setFrame:CGRectMake(267, height , 196, 42)];
    float scrollHeight = ((height+89) < 705)? 705: (height +89);
    [scrollview setContentSize:CGSizeMake(703, scrollHeight)];
    
    self.roomNoInTextField.text = @"";
    self.floorNoTextField.text = @"";
    self.gradeNoTextField.text = @"";
    self.notesNoTextField.text = @"";  
    
    int classroom_counter = [database.classrooms_in_one_location count];
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: (classroom_counter - 1) inSection:0]; // create a new index path 
       
    [tableviews selectRowAtIndexPath: indexPath animated: YES scrollPosition: UITableViewScrollPositionNone]; 
    //[tableviews cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    database.selected_room_index = [NSString stringWithFormat:@"%d", classroom_counter - 1];
    
    //[self.view endEditing:YES];
    [self hideKeyboard];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"resetAllTabsExceptRoom" object:self userInfo:nil]; 
    //UITableView *newTableView = self.tableviews; // create a pointer to a new table View
    //[self tableView:newTableView didSelectRowAtIndexPath:indexPath];
    /********** call didSelect function, which may call resetAllTabs function ***********/
    
}

- (IBAction)loadRoom {
    isql *database = [isql initialize];
    
    if ([[tableviews indexPathsForSelectedRows] count] > 0) {
        
        database.classroom_index = database.selected_room_index;
        
        int room_index = [database.selected_room_index intValue];
        
        database.current_classroom_number = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:0];
        database.current_classroom_floor = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:1];
        database.current_classroom_grade = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:2];
        database.current_classroom_notes = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:3];
        //database.current_raceway_part_8 = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:4];
        database.current_raceway_part_9 = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:5];
        database.current_raceway_part_10 = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:6];
        database.current_status = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:7];
        
        [NSThread detachNewThreadSelector:@selector(myThreadMethod:) toTarget:self withObject:nil];
        
        FileSystem *fs = [[FileSystem alloc] init];
        NSArray *fileNames = [fs generateFileNames:database.current_teq_rep withActivity:database.current_activity_no andRoomNumber:database.current_classroom_number andDateTime:database.current_date];
        [fs copyOldFiles:fileNames];
        
        [database loadVariablesFromLocalDest:YES];
    }    
    
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please pick a room." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
    }
}

- (void)myThreadMethod:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Loading";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (IBAction)deleteRoom {
    
    [self hideKeyboard];
    if ([[tableviews indexPathsForSelectedRows] count] == 0) {
        UIAlertView *labelNameOther = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please select a room."   delegate:self cancelButtonTitle:nil otherButtonTitles: @"Ok", nil];
        [labelNameOther setDelegate:self];
        [labelNameOther show];
    }
    else {
        UIAlertView *labelNameOther = [[UIAlertView alloc] initWithTitle:@"Are you sure to delete the room?" message:nil   delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
        [labelNameOther setTag: 2];
        [labelNameOther setDelegate:self];
        [labelNameOther show];
    }
}

- (IBAction)renameRoom:(id)sender {
    
    [self hideKeyboard];
    isql *database = [isql initialize];
    
    if ([[tableviews indexPathsForSelectedRows] count] > 0) {
        
        NSString *index = database.selected_room_index;
        
        int room_index = [index intValue];
        
        NSString *current_classroom_number = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:0];
        UIAlertView *labelNameOther = [[UIAlertView alloc] initWithTitle:@"New Room Number: " message:nil   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Change", nil];
        [labelNameOther setDelegate:self];
        [labelNameOther setTag:3];        
        objc_setAssociatedObject(labelNameOther, &MyConstantKey, current_classroom_number, OBJC_ASSOCIATION_RETAIN);
        //[labelNameOther setValue:current_classroom_number forKey:];
        [labelNameOther setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[labelNameOther textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [labelNameOther textFieldAtIndex:0].text = current_classroom_number;
        [labelNameOther show];
    }
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please pick a room." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
    }    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.gestureRecognizer.cancelsTouchesInView = YES;
    const float movementDuration = 0.3f;
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [self.scrollview setFrame:CGRectMake(0, 0, 703, 356)];
    [UIView commitAnimations];
    [self.scrollview scrollRectToVisible:CGRectMake(0, 195, 703, 356) animated:YES];
    [tableviews setFrame:CGRectMake(0, 355, 703, 20000)];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
 
}
- (void)enableSelection:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    //self.gestureRecognizer.cancelsTouchesInView = NO;
}

-(void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([alertView tag] == 1) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.goBackToWhichPage] forKey:@"index"]; 
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
    }    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2 && buttonIndex == 1) {
        isql *database = [isql initialize];
        
        sqlite3 *db;
        sqlite3_stmt    *statement;
        
        @try {
            
            const char *dbpath = [database.dbpathString UTF8String];
            
            if (sqlite3_open(dbpath, &db) == SQLITE_OK)
            {
                int room_index = [database.selected_room_index intValue];
                
                NSString *selectedRoomNumber = [[database.classrooms_in_one_location objectAtIndex:room_index] objectAtIndex:0];
                
                NSString *selectSQL = [NSString stringWithFormat:@"delete from local_dest where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' and [Room_Number] = '%@';", database.current_activity_no, database.current_teq_rep, selectedRoomNumber];
                
                const char *select_stmt = [selectSQL UTF8String];
                
                if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                    
                    
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        
                    } else {
                        NSLog(@"delete failed: %s", sqlite3_errmsg(db));
                    }
                    
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
            NSLog(@"delete room successful");
            
            database.current_classroom_number = nil;
            database.current_classroom_floor = nil;
            database.current_classroom_grade = nil;
            database.current_classroom_notes = nil;
            
            database.classroom_index = nil;
            database.selected_room_index = nil;
            
            database.selected_current_classroom_number = nil;
            database.selected_current_classroom_floor = nil;
            database.selected_current_classroom_grade = nil;
            database.selected_current_classroom_notes = nil;
            
            //database.current_raceway_part_8 = nil;
            database.current_raceway_part_9 = nil;
            database.current_raceway_part_10 = nil;
            database.current_status = nil;
            
            [self loadRoomFromDB];
        }
    }
    
    if (alertView.tag == 3 && buttonIndex == 1) {
        
        isql *database = [isql initialize];
        NSString *newRoom = [alertView textFieldAtIndex:0].text;
        
        if ([newRoom length] > 0) {
            NSCharacterSet *illegalCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-_"] invertedSet];
            NSString *convertedStr = [[newRoom componentsSeparatedByCharactersInSet:illegalCharSet] componentsJoinedByString:@""];
            
            if ([convertedStr length] == 0) {
                //show alert if they type just &**() as room number
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Room number can only use   0-9, a-z, A-Z, _ , -" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [message show];
                return;
            }
            newRoom = convertedStr;
        }
        else {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please input a room number." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
            
            return;
        }
        
        for (int i = 0; i< [database.classrooms_in_one_location count]; i++) {
            if ([[[database.classrooms_in_one_location objectAtIndex:i] objectAtIndex:0] isEqualToString: newRoom] ) {
                
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"This room already exists." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [message show];
                return;
            }
        }
        
        sqlite3 *db;
        sqlite3_stmt    *statement;
        
        //save date time
        NSDate *today = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        
        NSString *oldRoom = objc_getAssociatedObject(alertView, &MyConstantKey);
        
        NSString *queryString = [NSString stringWithFormat:@"UPDATE local_dest SET [Room_Number] = '%@', [Save_time] = '%@' WHERE [Activity_no] = '%@' AND [Teq_rep] like '%%%@%%' AND [Room_Number] = '%@'", newRoom, [formatter stringFromDate: today], database.current_activity_no, database.current_teq_rep, oldRoom];
        
        @try {
            
            const char *dbpath = [database.dbpathString UTF8String];
            
            if (sqlite3_open(dbpath, &db) == SQLITE_OK)
            {
                const char *insert_stmt = [queryString UTF8String];
                
                if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                    
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        NSLog(@"updateCustomActivityCustomLocation success");
                    } else {
                        NSLog(@"update failed: %s", sqlite3_errmsg(db));
                        
                    }
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
            [self loadRoomFromDB];
        }
    }
}

- (void)checkIfPreviousPagesAreFinished
{
    isql *database = [isql initialize];
    
     if ([database.current_activity_no length] == 0 ) {
         
         self.goBackToWhichPage = 0;
         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please pick a school first." message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
         [message setTag:1];
         [message show];
     
     }
     
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    isql *database = [isql initialize];
    return [database.classrooms_in_one_location count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    isql *database = [isql initialize];
    /*
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    */
    static NSString *CellIdentifier = @"RoomCell";
    RoomCell *cell = (RoomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSMutableString *room_info = [NSMutableString string];
    
    [room_info appendString: @"Room: "];
    [room_info appendString:[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:0]];
    if ([[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:1] length] > 0) {
        [room_info appendString:@", Floor: "];
        [room_info appendString:[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:1]];
    }
    if ([[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:2] length] > 0) {
        [room_info appendString:@", Grade: "];
        [room_info appendString:[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:2]];
    }
    if ([[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:3] length] > 0) {
        [room_info appendString:@", Notes: "];
        [room_info appendString:[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:3]];
    }
    
    if ([[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:5] isEqualToString:@"complete"]) {
        if ([[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:4] isEqualToString:@"notsync"]) {
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RoomCell" owner:self options:nil];
                for(RoomCell *temp_cell in nib) {
                    if (temp_cell.tag == 2) {
                        cell = temp_cell;
                    }
                }
            }
            cell.roomNumber2.text = room_info;            
            if ([[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:7] isEqualToString:@"Complete"]) {
                cell.complete2.textColor = [UIColor colorWithRed:62.0/255.0 green:166/255.0 blue:0 alpha:1];
                cell.complete2.text = @"Complete";
            }
            else {
                cell.complete2.textColor = [UIColor redColor];
                cell.complete2.text = @"Incomplete";
            }            
            if (![[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:6] isEqualToString:@"onhold"]) {
                //string is "ready" or ""(default), show "ready"
                cell.readyBtn.selected = NO;
            }
            else {
                cell.readyBtn.selected = YES;
            }
            
            cell.readyBtn.tag = [indexPath row];
            [cell.readyBtn addTarget:self action:@selector(readyBtnAction:) forControlEvents:UIControlEventTouchDown];
        }
        else {
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RoomCell" owner:self options:nil];
                for(RoomCell *temp_cell in nib) {
                    if (temp_cell.tag == 3) {
                        cell = temp_cell;
                    }
                }
            }
            cell.roomNumber3.text = room_info;
            if ([[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:7] isEqualToString:@"Complete"]) {
                cell.complete3.textColor = [UIColor colorWithRed:62.0/255.0 green:166/255.0 blue:0 alpha:1];
                cell.complete3.text = @"Complete";
            }
            else {
                cell.complete3.textColor = [UIColor redColor];
                cell.complete3.text = @"Incomplete";
            }
        }
        
    }
    else {
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RoomCell" owner:self options:nil];
            for(RoomCell *temp_cell in nib) {
                if (temp_cell.tag == 1) {
                    cell = temp_cell;
                }
            }
        }
        cell.roomNumber1.text = room_info;
        if ([[[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:7] isEqualToString:@"Complete"]) {
            cell.complete1.textColor = [UIColor colorWithRed:62.0/255.0 green:166/255.0 blue:0 alpha:1];
            cell.complete1.text = @"Complete";
        }
        else {
            cell.complete1.textColor = [UIColor redColor];
            cell.complete1.text = @"Incomplete";
        }
    }
    
   /*
    cell.roomFloorNumber.text = [NSString stringWithFormat:@"Floor: %@", [[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:1] ];
    cell.roomGradeNumber.text = [NSString stringWithFormat:@"Grade: %@", [[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:2] ];
    cell.roomNotes.text = [NSString stringWithFormat:@"Notes: %@", [[database.classrooms_in_one_location objectAtIndex:[indexPath row]] objectAtIndex:3] ];
     */   
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"call didselectrowfunction at room page");
    isql *database = [isql initialize];
    
    /****** change selected room index here, then when loading room, load room number, ... *****/
    //fix a bug of highlight the cell not purposely.
    database.selected_room_index = [NSString stringWithFormat:@"%d", [indexPath row]];
    if ([tableView cellForRowAtIndexPath:indexPath].tag == 2) {
        RoomCell *cell = (RoomCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.readyBtn.highlighted = NO;
    }
    if ([tableView cellForRowAtIndexPath:indexPath].tag == 3) {
        RoomCell *cell = (RoomCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.checkmarkBtn.highlighted = NO;
    }
    
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)saveAndGoToNextPage { 
    
    isql *database = [isql initialize];
    
    if ( database.current_classroom_number == nil) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please enter your room number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
        
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"index"]; 
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];    
    
    
}


-(void)loadRoomFromDB {
    
    //load schoolName, teqRep, activityNo, date from variable
    isql *database = [isql initialize];    
    [database addNumberToAppIcon];
    //if(database.classrooms_in_one_location == nil)
    database.classrooms_in_one_location = [NSMutableArray arrayWithObjects: nil];  
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
            
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat:@"select Room_Number, Room_Floor_Number, Classroom_grade, Room_Notes, (Case When Save_time > Sync_time Then 'notsync' Else 'sync' End), Raceway_part_9, Raceway_part_10, Status from local_dest where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' order by CASE WHEN cast(Room_Number as int) = 0 THEN 9999999999 ELSE cast(Room_Number as int) END, Room_Number;", database.current_activity_no, database.current_teq_rep];
        
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                                
                                
                while (sqlite3_step(statement) == SQLITE_ROW)
                { 
                    NSMutableArray *newClassRoom = [NSMutableArray arrayWithObjects:nil];
                    
                    [newClassRoom addObject:[[NSString alloc] 
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 0)]];
                    [newClassRoom addObject:[[NSString alloc] 
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 1)]];    
                    [newClassRoom addObject:[[NSString alloc] 
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 2)]];
                    [newClassRoom addObject:[[NSString alloc]
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 3)]];
                    [newClassRoom addObject:[[NSString alloc]
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 4)]];
                    [newClassRoom addObject:[[NSString alloc]
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 5)]];
                    [newClassRoom addObject:[[NSString alloc]
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 6)]];
                    [newClassRoom addObject:[[NSString alloc]
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 7)]];
                    [database.classrooms_in_one_location addObject: newClassRoom];
                } 
                NSLog(@"loadRoomsFromDB success");
                
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
        [self.tableviews reloadData];        
        float temp_height = 321 + [tableviews contentSize].height;
        
        float height = (temp_height > 615)? temp_height: 615;
        
        [loadButton setFrame:CGRectMake(267, height , 196, 42)];
        float scrollHeight = ((height+89) < 705)? 705: (height +89);
        [scrollview setContentSize:CGSizeMake(703, scrollHeight)];
        
        if ([database.classrooms_in_one_location count] == 0) {
            self.titleRoom.hidden = YES;
            self.titleInstallation.hidden = YES;
            self.titleReport.hidden = YES;
            self.titleSync.hidden = YES;
        }
        else {
            self.titleRoom.hidden = NO;
            self.titleInstallation.hidden = NO;
            self.titleReport.hidden = NO;
            self.titleSync.hidden = NO;
        }
    }  

    /*
    self.roomNoInTextField.text = [[database.classrooms_in_one_location objectAtIndex:[database.classroom_index intValue]] objectAtIndex:0]; 
    self.floorNoTextField.text = [[database.classrooms_in_one_location objectAtIndex:[database.classroom_index intValue]] objectAtIndex:1]; 
    self.notesNoTextField.text = [[database.classrooms_in_one_location objectAtIndex:[database.classroom_index intValue]] objectAtIndex:2];     
     */
}

- (IBAction) readyBtnAction:(UIButton *)sender {
    //NSLog(@"%d", sender.tag);
    isql *database = [isql initialize];
    //sender.selected = !sender.selected;
    
    NSString *readyBtnStatus, *roomNumber;
    
    if (sender.isSelected == YES) {
        sender.selected = NO;
        [[database.classrooms_in_one_location objectAtIndex:sender.tag] setObject:@"ready" atIndex:6];
        readyBtnStatus = @"ready";
        database.current_raceway_part_10 = @"ready";
    }
    else {
        sender.selected = YES;
        [[database.classrooms_in_one_location objectAtIndex:sender.tag] setObject:@"onhold" atIndex:6];
        readyBtnStatus = @"onhold";
        database.current_raceway_part_10 = @"onhold";
    }
    
    roomNumber = [[database.classrooms_in_one_location objectAtIndex:sender.tag] objectAtIndex:0];
    
    NSString *queryString =
    [NSString stringWithFormat: @"update local_dest set [Raceway_part_10]='%@' where [Username] = '%@' and [Activity_no] ='%@' and [Room_Number] = '%@' ;",
     
    readyBtnStatus,
     
    (database.current_username==nil)?@"":[database.current_username stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_activity_no==nil)?@"":[database.current_activity_no stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     roomNumber];
    
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {const char *insert_stmt = [queryString UTF8String];
            
            if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"update ready btn status success");
                } else {
                    NSLog(@"update failed: %s", sqlite3_errmsg(db));
                    
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                NSLog(@"%@", queryString);
            }
            NSLog(@"%@", queryString);
            
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {        
        sqlite3_close(db);
    }
}

#pragma mark -
#pragma mark Memory management

-(void)RefreshRoomList:(NSNotification*)notifications {
    [self loadRoomFromDB];
}
- (void) hideKeyboard {
    [self.view endEditing:YES];    
}

- (void) restoreView {
    self.gestureRecognizer.cancelsTouchesInView = NO;
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [self.scrollview setFrame:CGRectMake(0, 0, 703, 704)];
    //[self.scrollview scrollRectToVisible:CGRectMake(0, 0, 703, 704) animated:YES];
    [UIView commitAnimations];
}

@end
