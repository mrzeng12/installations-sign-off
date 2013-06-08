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
#import "quickLookModal.h"
#import <QuickLook/QuickLook.h>

@implementation FirstDetailView3

@synthesize schoolNameOutlet;
@synthesize activityNoOutlet;
@synthesize dateOutlet;
@synthesize SOOutlet;
@synthesize primarycontactOutlet;
@synthesize existingEquipOutlet;
@synthesize reasonForVisit;
@synthesize jobSummary;
@synthesize teamOutlet;
@synthesize districtOutlet;
@synthesize jobStatusOutlet;
@synthesize arrivalTimeOutlet;
@synthesize departureTimeOutlet;
@synthesize typeofworkOutlet;
@synthesize lastActivity;
@synthesize customeragreement;
@synthesize scrollView;
@synthesize gestureRecognizer;

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
    gestureRecognizer.delegate = self;
    
    [scrollView setFrame:CGRectMake(0, 320, 703, 704)];
    [scrollView setContentSize:CGSizeMake(703, 1300)];
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
    jobSummary.delegate = self;
    
    reasonForVisit.text = @"Please type the reason for visit...";
    reasonForVisit.textColor = [UIColor lightGrayColor];
    reasonForVisit.layer.borderWidth = 1;
    reasonForVisit.layer.borderColor = [[UIColor grayColor] CGColor];
    reasonForVisit.layer.cornerRadius = 7.0f;
    reasonForVisit.delegate = self;
    
    jobSummary.text = @"Please type job summary here...";
    jobSummary.textColor = [UIColor lightGrayColor];
    jobSummary.layer.borderWidth = 1;
    jobSummary.layer.borderColor = [[UIColor grayColor] CGColor];
    jobSummary.layer.cornerRadius = 7.0f;
    jobSummary.delegate = self;
                
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    isql *database = [isql initialize];
            
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
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 703, 704) animated:YES];
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

- (void)myThreadMethodAfterExit:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Saving";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (void)myThreadMethodAfterOpen:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Downloading";
    
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
    
    if (sender == typeofworkOutlet) {
        database.current_type_of_work = typeofworkOutlet.text;
    }
    if (sender == schoolNameOutlet) {
        database.current_location = schoolNameOutlet.text;
    }
    if (sender == teamOutlet) {
        database.current_pod = teamOutlet.text;
    }
    if (sender == districtOutlet) {
        database.current_district = districtOutlet.text;
    }
    if (sender == SOOutlet) {
        database.current_so =  SOOutlet.text;
    }
    if (sender == primarycontactOutlet) {
        database.current_primary_contact =  primarycontactOutlet.text;
    }
    if (sender == jobStatusOutlet) {
        database.current_job_status = jobStatusOutlet.text;
    }
    if (sender == dateOutlet) {
        database.current_date =  dateOutlet.text;
    }
    if (sender == arrivalTimeOutlet) {
        database.current_arrival_time = arrivalTimeOutlet.text;
    }
    if (sender == departureTimeOutlet) {
        database.current_departure_time = departureTimeOutlet.text;
    }
}

- (void) clearFields
{
    
    isql *database = [isql initialize];
    
    database.current_type_of_work = typeofworkOutlet.text = nil;
    
    database.current_location = schoolNameOutlet.text = nil;
    
    database.current_pod = teamOutlet.text = nil;
    
    database.current_district = districtOutlet.text = nil;
        
    database.current_so =  SOOutlet.text = nil;
    
    activityNoOutlet.text = nil;  //database.current_activity_no don't reset to nil
    
    database.current_primary_contact =  primarycontactOutlet.text = nil;
    
    database.current_job_status = jobStatusOutlet.text = nil;
    
    database.current_date = dateOutlet.text = nil;
    
    database.current_arrival_time = arrivalTimeOutlet.text = nil;
    
    database.current_departure_time = departureTimeOutlet.text = nil;
    
    database.current_reason_for_visit = reasonForVisit.text = nil;
    
    self.pdfBtn1.userInteractionEnabled = NO;
    self.pdfBtn1.alpha = 0.5;
    
    self.pdfBtn2.userInteractionEnabled = NO;
    self.pdfBtn2.alpha = 0.5;
}

- (IBAction)changeTime:(id)sender {
    
    UIButton *btn = sender;
    NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"SelectADateKey", @"")]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (btn.tag == 1) {
        [actionSheet showFromRect:self.arrivalBtn.frame inView:self.scrollView animated:YES];
    }
    if (btn.tag == 2) {
        [actionSheet showFromRect:self.departureBtn.frame inView:self.scrollView animated:YES];
    }
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init] ;
    
    if (btn.tag == 1) {
        datePicker.tag = 1;
    }
    if (btn.tag == 2) {
        datePicker.tag = 2;
    }
    datePicker.datePickerMode = UIDatePickerModeTime;
    [datePicker addTarget:self  action:@selector(DateChange:)
         forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:datePicker];
    
    //like css, position: relative; right: 22px;
    CGRect pickerRect = datePicker.bounds;
    pickerRect.origin.x = 22;
    datePicker.bounds = pickerRect;
    
}

- (IBAction)openPDF:(UIButton *)sender {
    
    [NSThread detachNewThreadSelector:@selector(myThreadMethodAfterOpen:) toTarget:self withObject:nil];
    
    isql *database = [isql initialize];
    NSString *stringURL;
    if (sender.tag == 1) {
        stringURL = database.current_pdf1;
    }
    if (sender.tag == 2) {
        stringURL = database.current_pdf2;
    }    
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filename = [stringURL stringByReplacingOccurrencesOfString:@"http://scheduler.teq.com/downloads/" withString:@""];
    filename = [NSString stringWithFormat:@"reference-%@", filename];
    
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
    
    //NSError *error = nil;
    //[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    if ( urlData )
    {        
        [urlData writeToFile:filePath atomically:YES];
    }
    
    QLPreviewController *temp = [[QLPreviewController alloc] init];
    [temp setDelegate:self];
	[temp setDataSource:self];
    [temp setCurrentPreviewItemIndex:0];
    [temp setTitle:filename];
    
    temp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    temp.modalPresentationStyle = UIModalPresentationFullScreen;
    [super presentViewController:temp animated:YES completion:nil];
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
}

- (IBAction)autoFill:(UIButton *)sender {
    if (sender.tag == 1) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Installation", @"Uninstall", nil];
        actionSheet.tag = 1;
        [actionSheet showFromRect:self.typeofworkBtn.frame inView:self.scrollView animated:YES];
    }
    if (sender.tag == 2) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Complete", @"Incomplete", nil];
        actionSheet.tag = 2;
        [actionSheet showFromRect:self.jobstatusBtn.frame inView:self.scrollView animated:YES];
    }
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, controller.title];
    
    return [NSURL fileURLWithPath:filePath];
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    isql *database = [isql initialize];
    
    //add justHighLight attribute so that it does not saveVariable each time a button is clicked
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:database.selectedMenu] forKey:@"index"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"justHighLight"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];   
    
}

- (void)DateChange:(id)sender
{
    isql *database = [isql initialize];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    UIDatePicker *picker = sender;
    if (picker.tag == 1) {
        database.current_arrival_time = arrivalTimeOutlet.text = [dateFormatter stringFromDate:[sender date]];
    }
    if (picker.tag == 2) {
        database.current_departure_time = departureTimeOutlet.text = [dateFormatter stringFromDate:[sender date]];
    }    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    isql *database = [isql initialize];
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            database.current_type_of_work = self.typeofworkOutlet.text = @"Installation";
        }
        if (buttonIndex == 1) {
            database.current_type_of_work = self.typeofworkOutlet.text = @"Uninstall";
        }
    }
    if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            database.current_job_status = self.jobStatusOutlet.text = @"Complete";
        }
        if (buttonIndex == 1) {
            database.current_job_status = self.jobStatusOutlet.text = @"Incomplete";
        }
    }
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
            
            NSString *selectSQL = [NSString stringWithFormat: @"select distinct [Bp_code], [Location], [District], [Primary_contact], [Pod], [Sales_Order], [Date], [File1], [File2], [Type_of_work], [Job_status], [Arrival_time], [Departure_time], [Reason_for_visit], [Agreement_1], [Agreement_2],  [Print_name_1], [Print_name_3], [Signature_file_directory_1], [Signature_file_directory_3], [Comlete_PDF_file_name], [Reserved 1] from local_dest where [Activity_no]='%@' AND [Teq_rep] like '%%%@%%' limit 0, 1;", database.current_activity_no, database.current_teq_rep ];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {                     
                    found_in_local_dest = 1;
                    
                    activityNoOutlet.text = database.current_activity_no;
                                        
                    database.current_bp_code = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]];
                    
                    database.current_location = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]];
                    schoolNameOutlet.text = database.current_location;
                    
                    database.current_district = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]];
                    districtOutlet.text = database.current_district;
                    
                    database.current_primary_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                    primarycontactOutlet.text = database.current_primary_contact;
                    
                    database.current_pod = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)]];
                    teamOutlet.text = database.current_pod;
                    
                    database.current_so = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)]];
                    SOOutlet.text = database.current_so; 
                                        
                    database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)]];
                    dateOutlet.text = database.current_date;
                    
                    database.current_pdf1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)]];
                    if ([database.current_pdf1 length] > 0) {
                        self.pdfBtn1.userInteractionEnabled = YES;
                        self.pdfBtn1.alpha = 1.0;
                    }

                    database.current_pdf2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)]];
                    if ([database.current_pdf2 length] > 0) {
                        self.pdfBtn2.userInteractionEnabled = YES;
                        self.pdfBtn2.alpha = 1.0;
                    }
                    
                    database.current_type_of_work = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)]];
                    typeofworkOutlet.text = database.current_type_of_work;
                    
                    database.current_job_status = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)]];
                    jobStatusOutlet.text = database.current_job_status;
                    
                    database.current_arrival_time = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)]];
                    arrivalTimeOutlet.text = database.current_arrival_time;
                    
                    database.current_departure_time = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)]];
                    departureTimeOutlet.text = database.current_departure_time;
                    
                    database.current_reason_for_visit = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)]];
                    reasonForVisit.text = database.current_reason_for_visit;
                    
                    if (reasonForVisit.text.length == 0) {
                        reasonForVisit.textColor = [UIColor lightGrayColor];
                        reasonForVisit.text = @"Please type the reason for visit...";
                    }
                    else {
                        reasonForVisit.textColor = [UIColor blackColor];
                    }
                    
                    database.current_agreement_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)]];
                    
                    database.current_agreement_2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 15)]];
                    
                    database.current_print_name_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)]];
                    
                    database.current_print_name_3 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)]];
                    
                    database.current_signature_file_directory_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 18)]];
                                        
                    database.current_signature_file_directory_3 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 19)]];
                    
                    database.current_comlete_pdf_file_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 20)]];
                    
                    database.current_job_summary = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 21)]];
                    jobSummary.text = database.current_job_summary;
                    
                    if (jobSummary.text.length == 0) {
                        jobSummary.textColor = [UIColor lightGrayColor];
                        jobSummary.text = @"Please type job summary here...";
                    }
                    else {
                        jobSummary.textColor = [UIColor blackColor];
                    }
                                        
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
            
            NSString *selectSQL = [NSString stringWithFormat: @"select distinct [Activity_Number],  coalesce([BP_Code],''), coalesce([BP_Name],''), coalesce([District],''), coalesce([Contact_Person],''), coalesce([POD],''), coalesce([SO],''), [StartDateTime], coalesce([File1],''), coalesce([File2],'') from local_src where [Activity_Number] = '%@' AND [Assigned_Name]='%@';", database.current_activity_no, database.current_teq_rep];
            
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
                    
                    database.current_bp_code = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]];
                    
                    database.current_location = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]];
                    schoolNameOutlet.text = database.current_location;
                    
                    database.current_district = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                    districtOutlet.text = database.current_district;
                    
                    database.current_primary_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)]];                    
                    primarycontactOutlet.text = database.current_primary_contact;
                    
                    database.current_pod = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)]];
                    teamOutlet.text = database.current_pod;
                    
                    database.current_so = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)]];
                    SOOutlet.text = database.current_so;
                    
                    database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)]];
                    dateOutlet.text = database.current_date = [database.current_date substringToIndex:10];
                    
                    database.current_pdf1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)]];
                    //schoolNameOutlet.text = pdf1;
                    if ([database.current_pdf1 length] > 0) {
                        self.pdfBtn1.userInteractionEnabled = YES;
                        self.pdfBtn1.alpha = 1.0;
                    }
                    
                    database.current_pdf2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)]];
                    //schoolNameOutlet.text = database.current_location;
                    if ([database.current_pdf2 length] > 0) {
                        self.pdfBtn2.userInteractionEnabled = YES;
                        self.pdfBtn2.alpha = 1.0;
                    }                    
                    reasonForVisit.textColor = [UIColor lightGrayColor];
                    reasonForVisit.text = @"Please type the reason for visit...";
                    
                    jobSummary.textColor = [UIColor lightGrayColor];
                    jobSummary.text = @"Please type job summary here...";
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
    if ([textView.text isEqualToString: @"Please type job summary here..."]) {
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
    
    return YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView.tag == 1) {
        if (textView.text.length == 0) {
            textView.textColor = [UIColor lightGrayColor];
            textView.text = @"Please type the reason for visit...";
        }
    }
    if (textView.tag == 2) {
        if (textView.text.length == 0) {
            textView.textColor = [UIColor lightGrayColor];
            textView.text = @"Please type job summary here...";
        }
    }
}

-(void) textViewDidChange:(UITextView *)textView
{
    isql *database = [isql initialize];
    if (textView.tag == 1) {
        if (![textView.text isEqualToString: @"Please type the reason for visit..."]) {
            database.current_reason_for_visit = textView.text;
        }
    }
    if (textView.tag == 2) {
        if (![textView.text isEqualToString: @"Please type job summary here..."]) {
            database.current_job_summary = textView.text;
        }
    }
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
    //gestureRecognizer.cancelsTouchesInView = YES;
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [scrollView setFrame:CGRectMake(0, 0, 703, 704)];
    [UIView commitAnimations];
}

- (void)enableSelection:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    gestureRecognizer.cancelsTouchesInView = NO;
}

@end
