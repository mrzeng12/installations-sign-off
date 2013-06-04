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
@synthesize activityNoOutlet;
@synthesize dateOutlet;
@synthesize SOOutlet;
@synthesize primarycontactOutlet;
@synthesize existingEquipOutlet;
@synthesize reasonForVisit;
@synthesize teamOutlet;
@synthesize districtOutlet;
@synthesize jobStatusOutlet;
@synthesize arrivalTimeOutlet;
@synthesize departureTimeOutlet;
@synthesize lastActivity;
@synthesize customeragreement;
@synthesize scrollView;

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
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [scrollView setFrame:CGRectMake(0, 320, 703, 748)];
    [scrollView setContentSize:CGSizeMake(703, 1065)];
    activityIndicator.hidesWhenStopped = YES;    
    
    schoolNameOutlet.delegate = self;
    activityNoOutlet.delegate = self;
    dateOutlet.delegate = self;
    SOOutlet.delegate = self;
    primarycontactOutlet.delegate = self;
    teamOutlet.delegate = self;
    districtOutlet.delegate = self;
    jobStatusOutlet.delegate = self;
    arrivalTimeOutlet.delegate = self;
    departureTimeOutlet.delegate = self;
    reasonForVisit.delegate = self;
    
    reasonForVisit.text = @"Please type the reason for visit...";
    reasonForVisit.textColor = [UIColor lightGrayColor];    
    reasonForVisit.layer.borderWidth = 1;
    reasonForVisit.layer.borderColor = [[UIColor grayColor] CGColor];
    reasonForVisit.layer.cornerRadius = 7.0f;
    reasonForVisit.delegate = self;
                
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
        
        //SOOutlet.textColor = [UIColor grayColor];
        
        //dateOutlet.textColor = [UIColor grayColor];
        activityNoOutlet.textColor = [UIColor grayColor];
        //schoolNameOutlet.textColor = [UIColor grayColor];
        
        [self clearFields];
        [self initializeActivityDetails]; 
        NSLog(@"reset firstDetialView3");
        /******** call saveVariableToLocalDest at the end of initializeActivityDetails *******/
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
    [self hideKeyboard];
}

- (void) viewDidDisappear:(BOOL)animated {
        
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
    [self setActivityNoOutlet:nil];
    [self setDateOutlet:nil];
    [self setSOOutlet:nil];
    [self setScrollView:nil];
    [self setPrimarycontactOutlet:nil];
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
    if (sender == SOOutlet) {
        database.current_so =  SOOutlet.text;
    }
    if (sender == dateOutlet) {
        database.current_date =  dateOutlet.text;
    }
    if (sender == activityNoOutlet) {
        database.current_activity_no =  activityNoOutlet.text;
    }
    if (sender == primarycontactOutlet) {
        database.current_primary_contact =  primarycontactOutlet.text;
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
        
    database.current_so =  SOOutlet.text = nil;
          
    database.current_date = dateOutlet.text = nil;
    
    activityNoOutlet.text = nil;  //database.current_activity_no don't reset to nil
    
    database.current_primary_contact =  primarycontactOutlet.text = nil;
               
    database.current_special_instructions =  nil;
        
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
                                        
                    database.current_activity_no = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]];
                    activityNoOutlet.text = database.current_activity_no;
                    
                    //database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]];              
                    //dateOutlet.text = database.current_date;
                    
                    database.current_bp_code = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]]; 
                    
                    database.current_address = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]]; 
                    
                    database.current_so = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];  
                    SOOutlet.text = database.current_so; 
                    
                    database.current_sq = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)]];
                    
                    database.current_walk_through_with = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)]];
                    
                    database.current_primary_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)]];
                    primarycontactOutlet.text = database.current_primary_contact;
                    
                    database.current_primary_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)]];                    
                    
                    database.current_primary_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)]];
                    
                    database.current_primary_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)]];
                    
                    database.current_second_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)]];
                    
                    database.current_second_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)]];                    
                    
                    database.current_second_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)]];
                    
                    database.current_second_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)]];
                    
                    database.current_engineer_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)]];
                    
                    database.current_engineer_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 15)]];                    
                    
                    database.current_engineer_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)]];
                    
                    database.current_engineer_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)]];
                    
                    database.current_school_hours = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 18)]];
                    
                    database.current_elevator_available = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 19)]];                    
                    
                    database.current_loading_available = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 20)]];                    
                    
                    database.current_special_instructions = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 21)]]; 
                    
                    database.current_hours_of_install = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 22)]]; 
                    
                    database.current_installers_needed = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 23)]]; 
                    
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
                    
                    database.current_job_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 39)]];
                                      
                    database.current_inventory_existing_equip = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 40)]];
                    if([database.current_inventory_existing_equip isEqualToString:@"1188"]){
                        existingEquipOutlet.text = @"(Inventory of existing equipment)";
                    }else {
                        existingEquipOutlet.text = @"";
                    }
                    
                    database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 41)]];
                    dateOutlet.text = [database.current_date substringToIndex:10];
                    
                    database.current_location = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 42)]];
                    schoolNameOutlet.text = database.current_location;
                    
                    database.current_onthefly_activity = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 43)]];
                    
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
                    
                    database.current_activity_no = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]];
                    activityNoOutlet.text = database.current_activity_no;
                    
                    database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]];              
                    dateOutlet.text = [database.current_date substringToIndex:10];
                    
                    database.current_so = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]];  
                    SOOutlet.text = database.current_so; 
                    
                    database.current_sq = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                    
                    database.current_primary_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)]];
                    
                    primarycontactOutlet.text = database.current_primary_contact;
                    
                    database.current_walk_through_with = database.current_primary_contact;
                    
                    database.current_primary_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)]];
                                        
                    database.current_address = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)]];
                    
                    database.current_bp_code = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)]];
                    
                    database.current_dest_latitude = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)]];
                    
                    database.current_dest_longitude = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)]];
                    
                    database.current_primary_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)]];
                    
                    database.current_primary_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)]];
                    
                    database.current_second_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)]];
                    
                    database.current_second_contact_phone = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)]];
                    
                    database.current_second_contact_title = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)]];
                    
                    database.current_second_contact_email = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 15)]];
                    
                    database.current_special_instructions = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)]];
                    
                    database.current_purchasing_agent = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)]];
                    
                    database.current_job_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 18)]];
                    
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
    
    activityNoOutlet.text = database.current_activity_no;
        
    dateOutlet.text = database.current_date = database.customDate;
    
    database.current_onthefly_activity = database.customOnthefly;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    gestureRecognizer.cancelsTouchesInView = YES;
    const float movementDuration = 0.3f;
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [scrollView setFrame:CGRectMake(0, 0, 703, 356)];
    [UIView commitAnimations];
    int movementDistance = [textField.superview.superview convertPoint:textField.frame.origin toView:self.view].y - 150;
    [scrollView scrollRectToVisible:CGRectMake(0, movementDistance, 703, 356) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  
}


- (BOOL) textViewShouldBeginEditing: (UITextView *)textView
{
    if ([textView.text isEqualToString: @"Please type the reason for visit..."]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    
    gestureRecognizer.cancelsTouchesInView = YES;
    const float movementDuration = 0.3f;
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [scrollView setFrame:CGRectMake(0, 0, 703, 356)];
    [UIView commitAnimations];
    int movementDistance = [textView.superview.superview convertPoint:textView.frame.origin toView:self.view].y - 150;
    [scrollView scrollRectToVisible:CGRectMake(0, movementDistance, 703, 356) animated:YES];
    
    return  YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"Please type the reason for visit...";
    }
}

-(void) textViewDidChange:(UITextView *)textView
{
    isql *database = [isql initialize];
    if (![textView.text isEqualToString: @"Please type the reason for visit..."]) {
        database.current_special_instructions = textView.text;
    }
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
    gestureRecognizer.cancelsTouchesInView = YES;
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [scrollView setFrame:CGRectMake(0, 0, 703, 704)];
    [UIView commitAnimations];
}
@end
