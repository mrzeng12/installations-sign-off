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
#import "Signature.h"

@implementation FirstDetailView3

@synthesize schoolNameOutlet;
@synthesize addressOutlet;
@synthesize address2Outlet;
@synthesize activityNoOutlet;
@synthesize dateOutlet;
@synthesize SOOutlet;
@synthesize POOutlet;
@synthesize primarycontactOutlet;
@synthesize existingEquipOutlet;
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
@synthesize changeOrder;
@synthesize changeApprovedByPrintName;
@synthesize popoverController;
@synthesize signatureBtn;

@synthesize appointmentList, activityIndicator;

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
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(coverPageCancelPopover)
     name:@"coverPageCancelPopover" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(coverPageCustomizedDismissPopover)
     name:@"coverPageCustomizedDismissPopover" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(restoreView) name:UIKeyboardWillHideNotification object:nil];
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.delegate = self;
    
    [scrollView setFrame:CGRectMake(0, 320, 703, 704)];
    [scrollView setContentSize:CGSizeMake(703, 1698)];
    [self.view addSubview:scrollView];
    
    activityIndicator.hidesWhenStopped = YES;    
    
    schoolNameOutlet.delegate = self;
    
    activityNoOutlet.delegate = self;
    addressOutlet.delegate = self;
    address2Outlet.delegate = self;
    dateOutlet.delegate = self;
    SOOutlet.delegate = self;
    POOutlet.delegate = self;
    primarycontactOutlet.delegate = self;
    teamOutlet.delegate = self;
    districtOutlet.delegate = self;
    jobStatusOutlet.delegate = self;
    arrivalTimeOutlet.delegate = self;
    departureTimeOutlet.delegate = self;
    jobSummary.delegate = self;
    changeApprovedByPrintName.delegate = self;
        
    //jobSummary.text = @"Please type job summary here...";
    jobSummary.textColor = [UIColor blackColor];
    jobSummary.layer.borderWidth = 1;
    jobSummary.layer.borderColor = [[UIColor grayColor] CGColor];
    jobSummary.layer.cornerRadius = 7.0f;
    jobSummary.delegate = self;
    
    changeOrder.textColor = [UIColor blackColor];
    changeOrder.layer.borderWidth = 1;
    changeOrder.layer.borderColor = [[UIColor grayColor] CGColor];
    changeOrder.layer.cornerRadius = 7.0f;
    changeOrder.delegate = self;
    
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
        
        typeofworkOutlet.textColor = [UIColor grayColor];
        activityNoOutlet.textColor = [UIColor grayColor];
        jobStatusOutlet.textColor = [UIColor grayColor];
        
        self.address2Outlet.enabled = NO;
        self.duplicateAddress.enabled = NO;
        self.address2Label.enabled = NO;
                
        [self clearFields];
        
        [self initializeActivityDetails];
        NSLog(@"reset firstDetialView3");
        /******** call saveVariableToLocalDest at the end of initializeActivityDetails *******/
    }
    [self fillOutjobStatus];
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
    [self setPOOutlet:nil];
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
    if (sender == addressOutlet) {
        database.current_address = addressOutlet.text;
    }
    if (sender == address2Outlet) {
        database.current_address_2 = address2Outlet.text;
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
    if (sender == POOutlet) {
        database.current_po =  POOutlet.text;
    }
    if (sender == primarycontactOutlet) {
        database.current_primary_contact =  primarycontactOutlet.text;
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
    if (sender == changeApprovedByPrintName) {
        database.current_change_approved_by_print_name = changeApprovedByPrintName.text;
    }
}

- (void) clearFields
{
    
    isql *database = [isql initialize];
    
    database.current_type_of_work = typeofworkOutlet.text = nil;
    
    database.current_location = schoolNameOutlet.text = nil;
    
    database.current_address = addressOutlet.text = nil;
    
    database.current_address_2 = address2Outlet.text = nil;
    
    database.current_pod = teamOutlet.text = nil;
    
    database.current_district = districtOutlet.text = nil;
        
    database.current_so =  SOOutlet.text = nil;
    
    database.current_po = POOutlet.text = nil;
    
    activityNoOutlet.text = nil;  //database.current_activity_no don't reset to nil
    
    database.current_primary_contact =  primarycontactOutlet.text = nil;
    
    //jobStatusOutlet.text = @"Incomplete"; //database.current_job_status is deprecated
    
    database.current_date = dateOutlet.text = nil;
    
    database.current_arrival_time = arrivalTimeOutlet.text = nil;
    
    database.current_departure_time = departureTimeOutlet.text = nil;
    
    database.current_job_summary = jobSummary.text = nil;
    
    database.current_change_order = changeOrder.text = nil;
    
    database.current_customer_signature_available = nil;
        
    self.pdfBtn1.userInteractionEnabled = NO;
    self.pdfBtn1.alpha = 0.5;
    
    self.pdfBtn2.userInteractionEnabled = NO;
    self.pdfBtn2.alpha = 0.5;
    
    [signatureBtn setImage:nil forState:UIControlStateNormal];
    [signatureBtn.layer setCornerRadius:10.0f];
    [signatureBtn.layer setMasksToBounds:YES];
    [signatureBtn.layer setBorderWidth:1.0f];
    [signatureBtn.layer setBorderColor:[UIColor grayColor].CGColor];
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
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
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
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Installation", @"Uninstall", @"Reinstall", @"Uninstall / Reinstall", @"Field Service", nil];
        actionSheet.tag = 1;
        [actionSheet showFromRect:self.typeofworkBtn.frame inView:self.scrollView animated:YES];
    }    
}

- (IBAction)duplicateAddress:(id)sender {
    isql *database = [isql initialize];
    address2Outlet.text = addressOutlet.text;
    database.current_address_2 = database.current_address;
}

- (IBAction)triggerPopover:(id)sender {
    
    isql *database = [isql initialize];
    database.signature_filename = @"Change_Approved_By";
    Signature *movies = [[Signature alloc] initWithNibName:@"Signature" bundle:[NSBundle mainBundle]];
    
    popoverController = [[UIPopoverController alloc] initWithContentViewController:movies];
    popoverController.delegate = self;
    
    UIButton *button = sender;
    
    [self.popoverController
     presentPopoverFromRect:[self.scrollView convertRect:button.frame toView:self.view]
     inView:self.view
     permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown
     animated:YES];
    
    [self.popoverController setPopoverContentSize:CGSizeMake(1000, 400) animated:YES];
}

//---called when the user clicks outside the popover view---
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    
    NSLog(@"popover about to be dismissed");
    return NO;
}

//---called when the popover view is dismissed---
- (void)popoverControllerDidDismissPopover:
(UIPopoverController *)popoverController {
    
    NSLog(@"popover dismissed");
}

- (void) coverPageCancelPopover
{
    [self.popoverController dismissPopoverAnimated:NO];
}

- (void) coverPageCustomizedDismissPopover
{
    [self.popoverController dismissPopoverAnimated:NO];
    isql *database = [isql initialize];
    
    /************* set button background images, wrap it inside round rect box ************/
    NSString *imageString = [database sanitizeFile:database.current_change_approved_by_signature];
    UIImage *backgroundImage = [self loadImage: imageString ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    [signatureBtn setImage:backgroundImage forState:UIControlStateNormal];
    [signatureBtn.layer setCornerRadius:10.0f];
    [signatureBtn.layer setMasksToBounds:YES];
    [signatureBtn.layer setBorderWidth:1.0f];
    [signatureBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]);
    return result;
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
    NSLog(@"%@", filePath);
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
        if (buttonIndex == 2) {
            database.current_type_of_work = self.typeofworkOutlet.text = @"Reinstall";
        }
        if (buttonIndex == 3) {
            database.current_type_of_work = self.typeofworkOutlet.text = @"Uninstall / Reinstall";
        }
        if (buttonIndex == 4) {
            database.current_type_of_work = self.typeofworkOutlet.text = @"Field Service";
        }
        if (buttonIndex == 3) {
            self.address2Outlet.enabled = YES;
            self.duplicateAddress.enabled = YES;
            self.address2Label.enabled = YES;
        }
        if (buttonIndex == 0 || buttonIndex == 1 || buttonIndex == 2 || buttonIndex == 4) {
            self.address2Outlet.text = @"";
            database.current_address_2 = @"";
            self.address2Outlet.enabled = NO;
            self.duplicateAddress.enabled = NO;
            self.address2Label.enabled = NO;
        }
        
    }
}

- (void)fillOutjobStatus {
        
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    NSString *status = @"n/a";
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat: @"select Status from local_dest where [Activity_no]='%@' AND [Teq_rep] like '%%%@%%';", database.current_activity_no, database.current_teq_rep ];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            
            if ( sqlite3_prepare_v2(db, select_stmt, -1, &statement, NULL) == SQLITE_OK) {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *temp_status = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]];
                    if ([status isEqualToString:@"n/a"] || ![temp_status isEqualToString:@"Complete"]) {
                        status = temp_status;
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
        if ([status isEqualToString:@"Complete"]) {
            self.jobStatusOutlet.text = @"Complete";
        }
        else {
            self.jobStatusOutlet.text = @"Incomplete";
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
            
            NSString *selectSQL = [NSString stringWithFormat: @"select distinct [Bp_code], [Location], [District], [Primary_contact], [Pod], [Sales_Order], [Reserved 7], [Date], [File1], [File2], [Type_of_work], [Arrival_time], [Departure_time], [Agreement_1], [Agreement_2],  [Print_name_1], [Print_name_3], [Signature_file_directory_1], [Signature_file_directory_3], [Comlete_PDF_file_name], [Reserved 1], [Customer_notes], [Reserved 2], [Reserved 3], [Reserved 6], [Reserved 8], [Reserved 9], [Reserved 10] from local_dest where [Activity_no]='%@' AND [Teq_rep] like '%%%@%%' limit 0, 1;", database.current_activity_no, database.current_teq_rep ];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    int i = 0;
                    found_in_local_dest = 1;
                    
                    activityNoOutlet.text = database.current_activity_no;
                                        
                    database.current_bp_code = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    
                    database.current_location = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    schoolNameOutlet.text = database.current_location;
                    
                    database.current_district = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    districtOutlet.text = database.current_district;
                    
                    database.current_primary_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    primarycontactOutlet.text = database.current_primary_contact;
                    
                    database.current_pod = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    teamOutlet.text = database.current_pod;
                    
                    database.current_so = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    SOOutlet.text = database.current_so; 
                    
                    database.current_po = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    POOutlet.text = database.current_po;

                    database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    dateOutlet.text = database.current_date;
                    
                    database.current_pdf1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    if ([database.current_pdf1 length] > 0) {
                        self.pdfBtn1.userInteractionEnabled = YES;
                        self.pdfBtn1.alpha = 1.0;
                    }

                    database.current_pdf2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    if ([database.current_pdf2 length] > 0) {
                        self.pdfBtn2.userInteractionEnabled = YES;
                        self.pdfBtn2.alpha = 1.0;
                    }
                    
                    database.current_type_of_work = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    typeofworkOutlet.text = database.current_type_of_work;
                    if ([typeofworkOutlet.text isEqualToString:@"Uninstall / Reinstall"]) {
                        self.address2Outlet.enabled = YES;
                        self.duplicateAddress.enabled = YES;
                        self.address2Label.enabled = YES;
                    }
                                        
                    database.current_arrival_time = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    arrivalTimeOutlet.text = database.current_arrival_time;
                    
                    database.current_departure_time = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    departureTimeOutlet.text = database.current_departure_time;
                                                            
                    database.current_agreement_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    
                    database.current_agreement_2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    
                    database.current_print_name_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    
                    database.current_print_name_3 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    
                    database.current_signature_file_directory_1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                                        
                    database.current_signature_file_directory_3 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    
                    database.current_comlete_pdf_file_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    
                    database.current_job_summary = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    jobSummary.text = database.current_job_summary;
                    
                    database.current_customer_notes = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    database.current_address = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    addressOutlet.text = database.current_address;
                    database.current_address_2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    address2Outlet.text = database.current_address_2;
                    database.current_customer_signature_available = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    database.current_change_order = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    changeOrder.text = database.current_change_order;
                    
                    database.current_change_approved_by_print_name = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    changeApprovedByPrintName.text = database.current_change_approved_by_print_name;
                    
                    database.current_change_approved_by_signature = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    /************* set button background images, wrap it inside round rect box ************/
                    NSString *imageString = [database sanitizeFile:database.current_change_approved_by_signature];
                    UIImage *backgroundImage = [self loadImage: imageString ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
                    
                    [signatureBtn setImage:backgroundImage forState:UIControlStateNormal];
                    [signatureBtn.layer setCornerRadius:10.0f];
                    [signatureBtn.layer setMasksToBounds:YES];
                    [signatureBtn.layer setBorderWidth:1.0f];
                    [signatureBtn.layer setBorderColor:[UIColor grayColor].CGColor];
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
            
            NSString *selectSQL = [NSString stringWithFormat: @"select distinct [Activity_Number],  coalesce([BP_Code],''), coalesce([BP_Name],''), coalesce([District],''), coalesce([Contact_Person],''), coalesce([POD],''), coalesce([SO],''), coalesce([Reserved 2],''), [StartDateTime], coalesce([File1],''), coalesce([File2],''), coalesce([Reserved 1],'') from local_src where [Activity_Number] = '%@' AND [Assigned_Name]='%@';", database.current_activity_no, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    found_in_local_src = 1;
                    //NSLog(@"sql ok");
                    //schoolNameOutlet.text = database.current_location;
                    int i = 0;
                    database.current_activity_no = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    activityNoOutlet.text = database.current_activity_no;
                    
                    database.current_bp_code = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    
                    database.current_location = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    schoolNameOutlet.text = database.current_location;
                    
                    database.current_district = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    districtOutlet.text = database.current_district;
                    
                    database.current_primary_contact = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];                    
                    primarycontactOutlet.text = database.current_primary_contact;
                    
                    database.current_pod = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    teamOutlet.text = database.current_pod;
                    
                    database.current_so = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    SOOutlet.text = database.current_so;
                    
                    database.current_po = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    POOutlet.text = database.current_po;
                    
                    database.current_date = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    dateOutlet.text = database.current_date = [database.current_date substringToIndex:10];
                    
                    database.current_pdf1 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    //schoolNameOutlet.text = pdf1;
                    if ([database.current_pdf1 length] > 0) {
                        self.pdfBtn1.userInteractionEnabled = YES;
                        self.pdfBtn1.alpha = 1.0;
                    }
                    
                    database.current_pdf2 = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    //schoolNameOutlet.text = database.current_location;
                    if ([database.current_pdf2 length] > 0) {
                        self.pdfBtn2.userInteractionEnabled = YES;
                        self.pdfBtn2.alpha = 1.0;
                    }
                    
                    database.current_address = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i++)]];
                    addressOutlet.text = database.current_address;
                    
                    database.current_customer_signature_available = @"Yes"; //default to be yes
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
    gestureRecognizer.cancelsTouchesInView = YES;
    const float movementDuration = 0.3f;
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [scrollView setFrame:CGRectMake(0, 0, 703, 356)];
    [UIView commitAnimations];
    int movementDistance = [textView.superview.superview convertPoint:textView.frame.origin toView:self.view].y - 70;
    [scrollView scrollRectToVisible:CGRectMake(0, movementDistance, 703, 356) animated:YES];
    
    return YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{    
    if (textView.tag == 2) {
        
    }
}

-(void) textViewDidChange:(UITextView *)textView
{
    isql *database = [isql initialize];    
    if (textView.tag == 2) {
        database.current_job_summary = textView.text;
    }
    if (textView.tag == 1) {
        database.current_change_order = textView.text;
    }
}

- (void) hideKeyboard {
    [self.view endEditing:YES];    
}

- (void) restoreView {
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
