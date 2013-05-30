//
//  FirstDetailView3.m
//  MultipleDetailViews
//
//  Created by Helpdesk on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstDetailView3.h"
#import "isql.h"
#import "CustomerAgreement.h"
#import <QuartzCore/QuartzCore.h>
#import "sqlite3.h"
#import "UICustomSwitch.h"
#import "CompletePDFRenderer.h"
#import "LGViewHUD.h"

@implementation FirstDetailView3

@synthesize schoolNameOutlet;
@synthesize teqRepOutlet;
@synthesize activityNoOutlet;
@synthesize dateOutlet;
@synthesize SOOutlet;
@synthesize SQOutlet;
@synthesize purchasingAgentOutlet;
@synthesize addressOutlet;
@synthesize bpcodeOutlet;
@synthesize walkthroughOutlet;
@synthesize primarycontactOutlet;
@synthesize primarytitleOutlet;
@synthesize primaryPhoneOutlet;
@synthesize secondcontactOutlet;
@synthesize secondphoneOutlet;
@synthesize secondemailOutlet;
@synthesize engineerOutlet;
@synthesize engineertitleOutlet;
@synthesize engineerphoneOutlet;
@synthesize engineeremailOutlet;
@synthesize schoolhoursOutlet;
@synthesize elevatoravailableSwitch;
@synthesize loadingdockSwitch;
@synthesize roomsOutlet;
@synthesize specialinstructionsOutlet;
@synthesize hoursofinstallOutlet;
@synthesize installersneededOutlet;
@synthesize secondetitleOutlet;
@synthesize primaryemailOutlet;
@synthesize installationVansOutlet;
@synthesize existingEquipOutlet;
@synthesize jobnameOutlet;
@synthesize changeActivityNoBtn;
@synthesize changeSchoolNameBtn;

@synthesize lastActivity;
@synthesize customeragreement;
@synthesize scrollView;

@synthesize locationManager;

@synthesize  appointmentList, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [scrollView setFrame:CGRectMake(0, 320, 703, 748)];
    [scrollView setContentSize:CGSizeMake(703, 2155)];
    activityIndicator.hidesWhenStopped = YES;    
    
    schoolNameOutlet.delegate = self;
    teqRepOutlet.delegate = self;
    activityNoOutlet.delegate = self;
    dateOutlet.delegate = self;
    SOOutlet.delegate = self;
    SQOutlet.delegate = self;
    purchasingAgentOutlet.delegate = self;
    addressOutlet.delegate = self;
    bpcodeOutlet.delegate = self;
    walkthroughOutlet.delegate = self;
    primarycontactOutlet.delegate = self;
    primarytitleOutlet.delegate = self;
    primaryPhoneOutlet.delegate = self;
    primaryemailOutlet.delegate = self;
    secondcontactOutlet.delegate = self;
    secondemailOutlet.delegate = self;
    secondetitleOutlet.delegate = self;
    secondphoneOutlet.delegate = self;
    engineerOutlet.delegate = self;
    engineeremailOutlet.delegate = self;
    engineerphoneOutlet.delegate = self;
    engineertitleOutlet.delegate = self;
    schoolhoursOutlet.delegate = self;
    roomsOutlet.delegate = self;
    hoursofinstallOutlet.delegate = self;
    installersneededOutlet.delegate = self;
    installationVansOutlet.delegate = self;
    
    specialinstructionsOutlet.text = @"Please write your instructions here...";
    specialinstructionsOutlet.textColor = [UIColor lightGrayColor];    
    specialinstructionsOutlet.layer.borderWidth = 1;
    specialinstructionsOutlet.layer.borderColor = [[UIColor grayColor] CGColor];
    specialinstructionsOutlet.layer.cornerRadius = 7.0f;
      
     
        
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    
    elevatoravailableSwitch = [[UICustomSwitch alloc] initWithFrame: CGRectMake(251, 1470, 87, 23)];
    [elevatoravailableSwitch addTarget: self action: @selector(saveCurrentField:) forControlEvents:UIControlEventValueChanged];
    // Set the desired frame location of onoff here
    [self.scrollView addSubview: elevatoravailableSwitch];
    
    loadingdockSwitch = [[UICustomSwitch alloc] initWithFrame: CGRectMake(251, 1525, 87, 23)];
    [loadingdockSwitch addTarget: self action: @selector(saveCurrentField:) forControlEvents:UIControlEventValueChanged];
    // Set the desired frame location of onoff here
    [self.scrollView addSubview: loadingdockSwitch];

    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    isql *database = [isql initialize];
    
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 703, 748) animated:YES];
    
    //if ((![database.current_location isEqualToString: self.lastLocation] || ![database.current_date isEqualToString:self.lastDate]) && database.current_location != nil) {
    if (![database.current_activity_no isEqualToString:self.lastActivity] && database.current_activity_no != nil)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"resetAllTabs" object:self userInfo:nil];
        
        changeActivityNoBtn.userInteractionEnabled = NO;
        changeActivityNoBtn.hidden = YES;
        
        changeSchoolNameBtn.userInteractionEnabled = NO;
        changeSchoolNameBtn.hidden = YES;
        
        SOOutlet.userInteractionEnabled = NO;
        SOOutlet.textColor = [UIColor grayColor];
        
        SQOutlet.userInteractionEnabled = NO;
        SQOutlet.textColor = [UIColor grayColor];
        
        jobnameOutlet.userInteractionEnabled = NO;
        jobnameOutlet.textColor = [UIColor grayColor];
        
        purchasingAgentOutlet.userInteractionEnabled = NO;
        purchasingAgentOutlet.textColor = [UIColor grayColor];
        
        teqRepOutlet.textColor = [UIColor grayColor];
        dateOutlet.textColor = [UIColor grayColor];
        activityNoOutlet.textColor = [UIColor grayColor];
        schoolNameOutlet.textColor = [UIColor grayColor];
        
        [self clearFields];
        [self initializeActivityDetails]; 
        NSLog(@"reset firstDetialView3");
        /******** call saveVariableToLocalDest at the end of initializeActivityDetails *******/
    }
    
    if ([database.src_latitude length] > 0 && [database.src_longitude length] > 0) {
        if (([database.current_dest_latitude length] > 0 && [database.current_dest_longitude length] > 0)
            ||[database.current_address length] > 0){
            [self.mapBtn setEnabled:YES];
            [self.mapBtn setAlpha:1.0];
        }
        else {
            [self.mapBtn setEnabled:NO];
            [self.mapBtn setAlpha:0.5];
        }
    }
    else {
        [self.mapBtn setEnabled:NO];
        [self.mapBtn setAlpha:0.5];
    }
    
    [self.scrollView flashScrollIndicators];
    [super viewWillAppear:YES];
}


- (void) viewWillDisappear:(BOOL)animated {
    isql *database = [isql initialize];
    //self.lastLocation = database.current_location;
    //self.lastDate = database.current_date;
    self.lastActivity = database.current_activity_no;
    
    [super viewWillDisappear:YES];
    [self.view endEditing:YES];
}

- (void) viewDidDisappear:(BOOL)animated {
    
    //isql *database = [isql initialize];
    //[NSThread detachNewThreadSelector:@selector(myThreadMethodAfterExit:) toTarget:self withObject:nil];
    //[database updateLocalDestForCoverPage];
     
    //CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    //renderer.callBackFunction = @"saving";
     
    //[renderer loadVariablesForPDF];
    
     [super viewDidDisappear:YES];
}

- (void)myThreadMethodAfterExit:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Saving";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (void)viewDidUnload
{
    [self setSchoolNameOutlet:nil];
    [self setTeqRepOutlet:nil];
    [self setActivityNoOutlet:nil];
    [self setDateOutlet:nil];
    [self setSOOutlet:nil];
    [self setSQOutlet:nil];
    [self setScrollView:nil];
    [self setPurchasingAgentOutlet:nil];
    [self setAddressOutlet:nil];
    [self setBpcodeOutlet:nil];
    [self setWalkthroughOutlet:nil];
    [self setPrimarycontactOutlet:nil];
    [self setPrimarytitleOutlet:nil];
    [self setPrimaryPhoneOutlet:nil];
    [self setPrimaryemailOutlet:nil];
    [self setSecondcontactOutlet:nil];
    [self setSecondetitleOutlet:nil];
    [self setSecondphoneOutlet:nil];
    [self setSecondemailOutlet:nil];
    [self setEngineerOutlet:nil];
    [self setEngineertitleOutlet:nil];
    [self setEngineerphoneOutlet:nil];
    [self setEngineeremailOutlet:nil];
    [self setSchoolhoursOutlet:nil];
    [self setElevatoravailableSwitch:nil];
    [self setLoadingdockSwitch:nil];
    [self setRoomsOutlet:nil];
    [self setSpecialinstructionsOutlet:nil];
    [self setHoursofinstallOutlet:nil];
    [self setInstallersneededOutlet:nil];
    [self setInstallationVansOutlet:nil];
    [self setMapBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)GoToNextPage {
    self.customeragreement.title = @"Customer Agreement";
    [self.navigationController pushViewController:self.customeragreement animated:YES];
    /*** update coversheet info after click "next" button ***/
    //update: there is no need for save it now. because when page disappears, it saves and create pdf
}

- (IBAction)saveCurrentField:(id)sender
{
    isql *database = [isql initialize];
        
    if (sender == schoolNameOutlet) {
        database.current_location = schoolNameOutlet.text;
    }
    if (sender == SQOutlet) {
        database.current_sq =  SQOutlet.text;
    }
    if (sender == SOOutlet) {
        database.current_so =  SOOutlet.text;
    }
    if (sender == teqRepOutlet) {
        database.current_teq_rep =  teqRepOutlet.text;
    }
    if (sender == dateOutlet) {
        database.current_date =  dateOutlet.text;
    }
    if (sender == activityNoOutlet) {
        database.current_activity_no =  activityNoOutlet.text;
    }
    if (sender == purchasingAgentOutlet) {
        database.current_purchasing_agent = purchasingAgentOutlet.text;
    }
    if (sender == addressOutlet) {
        database.current_address =  addressOutlet.text;
    }
    if (sender == bpcodeOutlet) {
        database.current_bp_code =  bpcodeOutlet.text;
    }
    if (sender == walkthroughOutlet) {
        database.current_walk_through_with =  walkthroughOutlet.text;
    }
    if (sender == primarycontactOutlet) {
        database.current_primary_contact =  primarycontactOutlet.text;
    }
    if (sender == primarytitleOutlet) {
        database.current_primary_contact_title =  primarytitleOutlet.text;
    }
    if (sender == primaryPhoneOutlet) {
        database.current_primary_contact_phone =  primaryPhoneOutlet.text;
    }
    if (sender == primaryemailOutlet) {
        database.current_primary_contact_email =  primaryemailOutlet.text;
    }    
    if (sender == secondcontactOutlet) {
        database.current_second_contact =  secondcontactOutlet.text;
    }
    if (sender == secondetitleOutlet) {
        database.current_second_contact_title =  secondetitleOutlet.text;
    }
    if (sender == secondphoneOutlet) {
        database.current_second_contact_phone =  secondphoneOutlet.text;
    }
    if (sender == secondemailOutlet) {
        database.current_second_contact_email =  secondemailOutlet.text;
    }
    if (sender == engineerOutlet) {
        database.current_engineer_contact =  engineerOutlet.text;
    }
    if (sender == engineertitleOutlet) {
        database.current_engineer_contact_title =  engineertitleOutlet.text;
    }
    if (sender == engineerphoneOutlet) {
        database.current_engineer_contact_phone =  engineerphoneOutlet.text;
    }
    if (sender == engineeremailOutlet) {
        database.current_engineer_contact_email =  engineeremailOutlet.text;
    }
    if (sender == schoolhoursOutlet) {
        database.current_school_hours =  schoolhoursOutlet.text;
    }
    if (sender == elevatoravailableSwitch) {
        database.current_elevator_available = [NSString stringWithFormat:@"%@", (elevatoravailableSwitch.on?@"YES" : @"NO")];
    }
    if (sender == loadingdockSwitch) {
        database.current_loading_available =  [NSString stringWithFormat:@"%@", (loadingdockSwitch.on?@"YES" : @"NO")];
    }    
    if (sender == specialinstructionsOutlet) {
        database.current_special_instructions =  specialinstructionsOutlet.text;
    }
    if (sender == hoursofinstallOutlet) {
        database.current_hours_of_install =  hoursofinstallOutlet.text;
    }
    if (sender == installersneededOutlet) {
        database.current_installers_needed =  installersneededOutlet.text;
    }
    if (sender == installationVansOutlet) {
        database.current_installation_vans = installationVansOutlet.text;
    }
    if (sender == jobnameOutlet) {
        database.current_job_name = jobnameOutlet.text;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    isql *database = [isql initialize];
    
    database.src_latitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    database.src_longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
    if ([database.src_latitude length] > 0 && [database.src_longitude length] > 0) {
        if (([database.current_dest_latitude length] > 0 && [database.current_dest_longitude length] > 0)
            ||[database.current_address length] > 0){
            [self.mapBtn setEnabled:YES];
            [self.mapBtn setAlpha:1.0];
        }
        else {
            [self.mapBtn setEnabled:NO];
            [self.mapBtn setAlpha:0.5];
        }
    }
    else {
        [self.mapBtn setEnabled:NO];
        [self.mapBtn setAlpha:0.5];
    }
    //NSLog(@"%@", database.src_latitude);
    //degrees = newLocation.coordinate.longitude;
    //NSLog(@"get latitude and longitude");
}

- (IBAction)openGoogleMap:(id)sender {
    
    /*temp_googleMapView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [super.splitViewController presentModalViewController:temp_googleMapView animated:YES]; 
     */
    /*
    CLLocationCoordinate2D location;         
    if ([database.src_latitude length]>0) {
        location.latitude = [database.src_latitude floatValue];
    }    
    if ([database.src_longitude length]>0) {
        location.longitude = [database.src_longitude floatValue];
    }
    */
    isql *database = [isql initialize];
         
    NSString* versionNum = [[UIDevice currentDevice] systemVersion];
    NSString *nativeMapScheme = @"maps.apple.com";
    if ([versionNum compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending){
        nativeMapScheme = @"maps.google.com";
    }
    //NSString* url = [NSString stringWithFormat: @"http://%@/maps?saddr=%f,%f&daddr=%f,%f", nativeMapScheme startCoordinate.latitude, startCoordinate.longitude,
                     //endCoordinate.latitude, endCoordinate.longitude];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    NSString *url;
    
    if ([database.current_dest_latitude length] > 0 && [database.current_dest_longitude length] > 0) {
        url = [NSString stringWithFormat: @"http://%@/maps?saddr=%f,%f&daddr=%f,%f",nativeMapScheme,
               [database.src_latitude floatValue], [database.src_longitude floatValue],
               [database.current_dest_latitude floatValue], [database.current_dest_longitude floatValue]];
        NSLog(@"latitude, longitude");
        
    }
    else {
        url = [NSString stringWithFormat: @"http://%@/maps?saddr=%f,%f&daddr=%@",nativeMapScheme,
                         [database.src_latitude floatValue], [database.src_longitude floatValue],
                         [database.current_address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"address");
    }
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];

}

- (IBAction)changeActivityNo:(id)sender {
    isql *database = [isql initialize];
    UIAlertView *labelNameOther = [[UIAlertView alloc] initWithTitle:@"New Activity Number: " message:nil   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Change", nil];
    [labelNameOther setDelegate:self];
    [labelNameOther setTag:0];
    [labelNameOther setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[labelNameOther textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [labelNameOther textFieldAtIndex:0].text = database.current_activity_no;
    [labelNameOther show];
}

- (IBAction)changeSchoolName:(id)sender {
    isql *database = [isql initialize];
    UIAlertView *labelNameOther = [[UIAlertView alloc] initWithTitle:@"New School Name: " message:nil   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Change", nil];
    [labelNameOther setDelegate:self];
    [labelNameOther setTag:1];
    [labelNameOther setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[labelNameOther textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [labelNameOther textFieldAtIndex:0].text = database.current_location;
    [labelNameOther show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //tag 0: change activity number
    //tag 1: change school name
    //tag 2: change activity number even if it already exists in the schedule
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            return;
        }
        isql *database = [isql initialize];
        NSString *activity_no = [alertView textFieldAtIndex:0].text;
        
        NSScanner *scanner = [NSScanner scannerWithString:activity_no];
        BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
        if (!isNumeric || [activity_no intValue] < 100000) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Activity number must be numeric and contain at least 6 digits." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
            return;
        }
        
        if ([database checkActivityExistsInLocalDest:activity_no]) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Activity number is already being used." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
            return;
        }
        
        if ([database checkActivityExistsInLocalSrc:activity_no]) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Activity number %@ exists in your schedule. Are you sure to change to it?",activity_no] message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: @"Change", nil];
            customAlertActivity = activity_no;
            [message setDelegate:self];
            [message setTag:2];
            [message show];
            return;
        }
        
        database.current_activity_no = activity_no;
        [self updateCustomActivityCustomLocation];
        activityNoOutlet.text = database.current_activity_no;
        //[database updateLocalDestForCoverPage];
    }
    
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            return;
        }
        isql *database = [isql initialize];
        NSString *school_name = [alertView textFieldAtIndex:0].text;
                
        if ([school_name length] == 0) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Location name cannot be blank." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
            return;
        }
        
        database.current_location = school_name;
        [self updateCustomActivityCustomLocation];
        schoolNameOutlet.text = database.current_location;
        //[database updateLocalDestForCoverPage];
    }
    
    if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            return;
        }
        isql *database = [isql initialize];
        database.current_activity_no = customAlertActivity;
        [self updateCustomActivityCustomLocation];
        activityNoOutlet.text = database.current_activity_no;
    }
}

-(void)updateCustomActivityCustomLocation {
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    
    //save date time
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSString *queryString = [NSString stringWithFormat:@"UPDATE local_dest SET [Activity_no] = '%@', [Location] = '%@', [Save_time] = '%@' WHERE [Date] = '%@' AND [Teq_rep] like '%%%@%%'", database.current_activity_no, database.current_location, [formatter stringFromDate: today], database.current_date, database.current_teq_rep];
    
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
    }
}

- (void) clearFields
{
    
    isql *database = [isql initialize];
    
    database.current_location = schoolNameOutlet.text = nil;
    
    database.current_sq =  SQOutlet.text = nil;    
    
    database.current_so =  SOOutlet.text = nil;
        
    teqRepOutlet.text = nil;    //database.teqRepOutlet don't reset to nil
        
    database.current_date = dateOutlet.text = nil;
    
    activityNoOutlet.text = nil;  //database.current_activity_no don't reset to nil
    
    database.current_purchasing_agent = purchasingAgentOutlet.text = nil;
    
    database.current_address =  addressOutlet.text = nil;
    
    database.current_bp_code =  bpcodeOutlet.text = nil;
    
    database.current_walk_through_with =  walkthroughOutlet.text = nil;
    
    database.current_primary_contact =  primarycontactOutlet.text = nil;
    
    database.current_primary_contact_title =  primarytitleOutlet.text = nil;
    
    database.current_primary_contact_phone =  primaryPhoneOutlet.text = nil;
    
    database.current_primary_contact_email =  primaryemailOutlet.text = nil;
    
    database.current_second_contact =  secondcontactOutlet.text = nil;
    
    database.current_second_contact_title =  secondetitleOutlet.text = nil;
    
    database.current_second_contact_phone =  secondphoneOutlet.text = nil;
    
    database.current_second_contact_email =  secondemailOutlet.text = nil;
    
    database.current_engineer_contact =  engineerOutlet.text = nil;
    
    database.current_engineer_contact_title =  engineertitleOutlet.text = nil;
    
    database.current_engineer_contact_phone =  engineerphoneOutlet.text = nil;
    
    database.current_engineer_contact_email =  engineeremailOutlet.text = nil;
    
    database.current_school_hours =  schoolhoursOutlet.text = nil;
    
    elevatoravailableSwitch.on = FALSE;
    
    database.current_elevator_available = [NSString stringWithFormat:@"%@", (elevatoravailableSwitch.on?@"YES" : @"NO")];
    
    loadingdockSwitch.on = FALSE;
    database.current_loading_available =  [NSString stringWithFormat:@"%@", (loadingdockSwitch.on?@"YES" : @"NO")];
           
    database.current_special_instructions =  nil;
    
    specialinstructionsOutlet.text = @"Please write your instructions here...";
    
    database.current_hours_of_install =  hoursofinstallOutlet.text = nil;
    
    database.current_installers_needed =  installersneededOutlet.text = nil;
    
    database.current_installation_vans = installationVansOutlet.text = nil;
    
    database.current_job_name = jobnameOutlet.text = nil;
    
    database.current_inventory_existing_equip = existingEquipOutlet.text = nil;
    
    database.current_onthefly_activity = nil;
}

- (void)initializeActivityDetails {
    
    found_in_local_dest = 0;
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        //NSString *tempLocation = [database.current_location stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {       
            
            NSString *selectSQL = [NSString stringWithFormat: @"select distinct [Activity_no], [Bp_code], [Address], [Sales_Order], [Sales_Quote], [Walk_through_with], [Primary_contact], [Primary_contact_title], [Primary_contact_phone], [Primary_contact_email], [Second_contact], [Second_contact_title], [Second_contact_phone], [Second_contact_email], [Engineer_contact], [Engineer_contact_title], [Engineer_contact_phone], [Engineer_contact_email], [School_hours], [Elevator_available], [Loading_available], [Special_instructions], [Hours_of_install], [Installers_needed], [Signature_file_directory_1], [Signature_file_directory_2], [Signature_file_directory_3],  [Print_name_1], [Print_name_2], [Print_name_3],  [Title_of_signature_1], [Agreement_1], [Agreement_2], [PDF_file_name], [Comlete_PDF_file_name], [Installation_vans], [Latitude], [Longitude], [Reserved 1], [Reserved 2], [Reserved 3], [Date], [Location], [Reserved 4] from local_dest where [Activity_no]='%@' AND [Teq_rep] like '%%%@%%' limit 0, 1;", database.current_activity_no, database.current_teq_rep ];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {                     
                    found_in_local_dest = 1;
                    //NSLog(@"sql ok");
                    //schoolNameOutlet.text = database.current_location;
                    
                    teqRepOutlet.text = database.current_teq_rep;
                    
                    database.current_activity_no = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]];
                    activityNoOutlet.text = database.current_activity_no;
                    
                    //database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]];              
                    //dateOutlet.text = database.current_date;
                    
                    database.current_bp_code = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]]; 
                    bpcodeOutlet.text = database.current_bp_code;
                    
                    database.current_address = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]]; 
                    addressOutlet.text = database.current_address;
                    
                    database.current_so = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];  
                    SOOutlet.text = database.current_so; 
                    
                    database.current_sq = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)]];
                    SQOutlet.text = database.current_sq;
                    
                    database.current_walk_through_with = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)]];
                    walkthroughOutlet.text = database.current_walk_through_with;
                    
                    database.current_primary_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)]];
                    primarycontactOutlet.text = database.current_primary_contact;
                    
                    database.current_primary_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)]];                    
                    primarytitleOutlet.text = database.current_primary_contact_title;
                                       
                    database.current_primary_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)]];
                    primaryPhoneOutlet.text = database.current_primary_contact_phone;
                                        
                    database.current_primary_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)]];
                    primaryemailOutlet.text = database.current_primary_contact_email;
                    
                    database.current_second_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)]];
                    secondcontactOutlet.text = database.current_second_contact;
                    
                    database.current_second_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)]];                    
                    secondetitleOutlet.text = database.current_second_contact_title;
                    
                    database.current_second_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)]];
                    secondphoneOutlet.text = database.current_second_contact_phone;                    
                    
                    database.current_second_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)]];
                    secondemailOutlet.text = database.current_second_contact_email;
                    
                    database.current_engineer_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)]];
                    engineerOutlet.text = database.current_engineer_contact;
                    
                    database.current_engineer_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 15)]];                    
                    engineertitleOutlet.text = database.current_engineer_contact_title;
                    
                    database.current_engineer_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)]];
                    engineerphoneOutlet.text = database.current_engineer_contact_phone;                    
                    
                    database.current_engineer_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)]];
                    engineeremailOutlet.text = database.current_engineer_contact_email;
                    
                    database.current_school_hours = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 18)]];
                    schoolhoursOutlet.text = database.current_school_hours;
                    
                    database.current_elevator_available = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 19)]];                    
                    if ([database.current_elevator_available isEqualToString:@"YES"]) {
                        elevatoravailableSwitch.on = YES;
                    }
                    else {
                        elevatoravailableSwitch.on = NO;
                    }
                    
                    database.current_loading_available = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 20)]];                    
                    if ([database.current_loading_available isEqualToString:@"YES"]) {
                        loadingdockSwitch.on = YES;
                    }
                    else {
                        loadingdockSwitch.on = NO;
                    }
                    
                    database.current_special_instructions = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 21)]]; 
                    specialinstructionsOutlet.text = database.current_special_instructions;
                    
                    database.current_hours_of_install = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 22)]]; 
                    hoursofinstallOutlet.text = database.current_hours_of_install;
                    
                    database.current_installers_needed = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 23)]]; 
                    installersneededOutlet.text = database.current_installers_needed;
                    
                    database.current_signature_file_directory_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 24)]];
                    
                    database.current_signature_file_directory_2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 25)]];
                    
                    database.current_signature_file_directory_3 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 26)]];
                    
                    database.current_print_name_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 27)]];
                    //installersneededOutlet.text = database.current_installers_needed;
                    
                    database.current_print_name_2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 28)]];
                    
                    database.current_print_name_3 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 29)]];
                    
                    database.current_title_of_signature_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 30)]];
                    //database.current_agreement_1 = @"haha";
                    
                    database.current_agreement_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 31)]];
                    
                    database.current_agreement_2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 32)]];
                    
                    database.current_pdf_file_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 33)]];
                    
                    database.current_comlete_pdf_file_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 34)]];
                    
                    database.current_installation_vans = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 35)]];
                    
                    database.current_dest_latitude = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 36)]];
                    
                    database.current_dest_longitude = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 37)]];
                    
                    database.current_purchasing_agent = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 38)]];
                    purchasingAgentOutlet.text = database.current_purchasing_agent;
                    
                    database.current_job_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 39)]];
                    jobnameOutlet.text = database.current_job_name;
                    
                    database.current_inventory_existing_equip = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 40)]];
                    if([database.current_inventory_existing_equip isEqualToString:@"1188"]){
                        existingEquipOutlet.text = @"(Inventory of existing equipment)";
                    }else {
                        existingEquipOutlet.text = @"";
                    }
                    
                    database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 41)]];
                    dateOutlet.text = database.current_date;
                    
                    database.current_location = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 42)]];
                    schoolNameOutlet.text = database.current_location;
                    
                    database.current_onthefly_activity = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 43)]];
                    /*
                    [firstDetailView4 view];
                    
                    database.current_print_name_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 27)]]; 
                    firstDetailView4.printNameTextField_1.text = database.current_print_name_1;
                    //NSLog(@"%@", database.current_print_name_1);
                    
                    database.current_print_name_2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 28)]]; 
                    firstDetailView4.printNameTextField_2.text = database.current_print_name_2;
                    //NSLog(@"%@", database.current_print_name_2);
                    
                    database.current_print_name_3 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 29)]]; 
                    firstDetailView4.printNameTextField_3.text = database.current_print_name_3;
                    //NSLog(@"%@", database.current_print_name_3);
                    
                    database.current_title_of_signature_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 30)]]; 
                    firstDetailView4.primaryContactLabel.text = [NSString stringWithFormat:@"%@:", database.current_title_of_signature_1];
                    */
                    // [Signature_file_directory_1], [Signature_file_directory_2], [Signature_file_directory_3],  [Print_name_1], [Print_name_2], [Print_name_3],  [Title_of_signature_1]
                } 
                
                sqlite3_finalize(statement);
            } 
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
                NSLog(@"%@", selectSQL);
            }
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {        
        sqlite3_close(db);
        if ([database.current_onthefly_activity isEqualToString:@"Yes"]) {
            
            changeActivityNoBtn.userInteractionEnabled = YES;
            changeActivityNoBtn.hidden = NO;
            
            changeSchoolNameBtn.userInteractionEnabled = YES;
            changeSchoolNameBtn.hidden = NO;
            
            SOOutlet.userInteractionEnabled = YES;
            SOOutlet.textColor = [UIColor blackColor];
            
            SQOutlet.userInteractionEnabled = YES;
            SQOutlet.textColor = [UIColor blackColor];
            
            jobnameOutlet.userInteractionEnabled = YES;
            jobnameOutlet.textColor = [UIColor blackColor];
            
            purchasingAgentOutlet.userInteractionEnabled = YES;
            purchasingAgentOutlet.textColor = [UIColor blackColor];
        }
        if (found_in_local_dest == 0) {
            [self initializeActivityDetailsStepTwo];
        }
    }    
    
}

- (void)initializeActivityDetailsStepTwo {
    
    int found_in_local_src = 0;
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        //NSString *tempLocation = [database.current_location stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {       
            
            NSString *selectSQL = [NSString stringWithFormat: @"select distinct [Activity_Number], [StartDateTime], coalesce([SO],''), coalesce([SQ],''), coalesce([Contact_Person],''), coalesce([Tel],''), coalesce([Address],''), coalesce([BP_Code],''), [Latitude], [Longitude], coalesce([Title],''), coalesce([Email],''), coalesce([Contact_2],''), coalesce([BP2_Phone],''), coalesce([BP2_Title],''), coalesce([BP2_Email],''), coalesce([Special_Instructions],''), coalesce([Purchasing_Agent],''), coalesce([Reserved 1],''), coalesce([Reserved 2],''), coalesce([BP_Name],'') from local_src where [Activity_Number] = '%@' AND [Assigned_Name]='%@';", database.current_activity_no, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    found_in_local_src = 1;
                    //NSLog(@"sql ok");
                    //schoolNameOutlet.text = database.current_location;
                    
                    teqRepOutlet.text = database.current_teq_rep;
                    
                    database.current_activity_no = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]];
                    activityNoOutlet.text = database.current_activity_no;
                    
                    database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]];              
                    dateOutlet.text = database.current_date;
                    
                    database.current_so = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]];  
                    SOOutlet.text = database.current_so; 
                    
                    database.current_sq = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                    SQOutlet.text = database.current_sq;
                    
                    database.current_primary_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)]];
                    
                    primarycontactOutlet.text = database.current_primary_contact;
                    
                    walkthroughOutlet.text = database.current_primary_contact;
                    
                    database.current_walk_through_with = database.current_primary_contact;
                    
                    database.current_primary_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)]];
                    primaryPhoneOutlet.text = database.current_primary_contact_phone;
                    
                    database.current_address = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)]];
                    addressOutlet.text = database.current_address;
                    
                    database.current_bp_code = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)]];
                    bpcodeOutlet.text = database.current_bp_code;
                    
                    database.current_dest_latitude = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)]];
                    
                    database.current_dest_longitude = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)]];
                    
                    database.current_primary_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)]];
                    primarytitleOutlet.text = database.current_primary_contact_title;
                    
                    database.current_primary_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)]];
                    primaryemailOutlet.text = database.current_primary_contact_email;
                    
                    database.current_second_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)]];
                    secondcontactOutlet.text = database.current_second_contact;
                    
                    database.current_second_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)]];
                    secondphoneOutlet.text = database.current_second_contact_phone;
                    
                    database.current_second_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)]];
                    secondetitleOutlet.text = database.current_second_contact_title;
                    
                    database.current_second_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 15)]];
                    secondemailOutlet.text = database.current_second_contact_email;
                    
                    database.current_special_instructions = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)]];
                    specialinstructionsOutlet.text = database.current_special_instructions;
                    
                    database.current_purchasing_agent = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)]];
                    purchasingAgentOutlet.text = database.current_purchasing_agent;
                    
                    database.current_job_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 18)]];
                    jobnameOutlet.text = database.current_job_name;
                    
                    database.current_inventory_existing_equip = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 19)]];
                    if([database.current_inventory_existing_equip isEqualToString:@"1188"]){
                        existingEquipOutlet.text = @"(Inventory of existing equipment)";
                    }else {
                        existingEquipOutlet.text = @"";
                    }
                    
                    database.current_location = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 20)]];
                    schoolNameOutlet.text = database.current_location;
                    
                } 
                
                sqlite3_finalize(statement);
            } 
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
                NSLog(@"%@", selectSQL);
            }
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {        
        sqlite3_close(db);
        if (found_in_local_src == 1) {
            [database saveVariableToLocalDest];
        }
        else {
            [self initializeActivityDetailsStepThree];
        }
    } 

}

- (void)initializeActivityDetailsStepThree {
    
    isql *database = [isql initialize];
    
    schoolNameOutlet.text = database.current_location = database.customLocation;
    
    teqRepOutlet.text = database.current_teq_rep;
    
    activityNoOutlet.text = database.current_activity_no;
        
    dateOutlet.text = database.current_date = database.customDate;
    
    database.current_onthefly_activity = database.customOnthefly;
    
    changeActivityNoBtn.userInteractionEnabled = YES;
    changeActivityNoBtn.hidden = NO;
    
    changeSchoolNameBtn.userInteractionEnabled = YES;
    changeSchoolNameBtn.hidden = NO;
    
    SOOutlet.userInteractionEnabled = YES;
    SOOutlet.textColor = [UIColor blackColor];
    
    SQOutlet.userInteractionEnabled = YES;
    SQOutlet.textColor = [UIColor blackColor];
    
    jobnameOutlet.userInteractionEnabled = YES;
    jobnameOutlet.textColor = [UIColor blackColor];
    
    purchasingAgentOutlet.userInteractionEnabled = YES;
    purchasingAgentOutlet.textColor = [UIColor blackColor];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [scrollView setContentSize:CGSizeMake(703, 2505)];
    //[self animateTextField: textField up: YES];
    float movementDistance = [textField.superview.superview convertPoint:textField.frame.origin toView:self.view].y - 150;
    [scrollView scrollRectToVisible:CGRectMake(0, movementDistance, 703, 748) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [scrollView setContentSize:CGSizeMake(703, 2155)];
}


- (BOOL) textViewShouldBeginEditing: (UITextView *)textView
{
    [scrollView setContentSize:CGSizeMake(703, 2505)];
    if ([textView.text isEqualToString: @"Please write your instructions here..."]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    
    float movementDistance = [textView.superview.superview convertPoint:textView.frame.origin toView:self.view].y - 100;
    [scrollView scrollRectToVisible:CGRectMake(0, movementDistance, 703, 748) animated:YES];
    
    return YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    [scrollView setContentSize:CGSizeMake(703, 2155)];
    if (textView.text.length == 0) {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"Please write your instructions here...";
        [textView resignFirstResponder];
    }
    
}

-(void) textViewDidChange:(UITextView *)textView
{
    isql *database = [isql initialize];
    if (![textView.text isEqualToString: @"Please write your instructions here..."]) {        
        database.current_special_instructions = textView.text;
    }
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}
@end
