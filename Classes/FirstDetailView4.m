//
//  FirstDetailView4.m
//  MultipleDetailViews
//
//  Created by Helpdesk on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstDetailView4.h"
#import <QuartzCore/QuartzCore.h>
#import "isql.h"
#import "Signature.h"
//#import "UpdatedPDFModal.h"
#import "LGViewHUD.h"
#import "CompletePDFRenderer.h"
#import "quickLookModal.h"
#import <QuickLook/QuickLook.h>

@interface FirstDetailView4 ()

@end

@implementation FirstDetailView4
@synthesize printNameTextField_1;
@synthesize printNameTextField_3;
@synthesize primaryContactSign;
@synthesize scrollView;
@synthesize popoverController;
@synthesize teqReqSign;

@synthesize lastLocation;
@synthesize lastDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.primaryContactSign addGestureRecognizer:gestureRecognizer];
    [self.teqReqSign addGestureRecognizer:gestureRecognizer];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    UIBarButtonItem *saveAndGoToNextPage = [[UIBarButtonItem alloc] initWithTitle:@"Next Step" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAndGoToNextPage)];
    self.navigationItem.rightBarButtonItem = saveAndGoToNextPage;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(customizedDismissPopover)
     name:@"customizedDismissPopover" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(cancelPopover)
     name:@"cancelPopover" object:nil];
    
    [scrollView setContentSize:CGSizeMake(703, 1200)];
    [scrollView setFrame:CGRectMake(0, 320, 703, 748)];
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 703, 748) animated:YES];
    
    self.printNameTextField_1.delegate = self;
    self.printNameTextField_3.delegate = self;
    
    self.customerNotes.layer.borderWidth = 1;
    self.customerNotes.layer.borderColor = [[UIColor grayColor] CGColor];
    self.customerNotes.layer.cornerRadius = 7.0f;    
    self.customerNotes.text = @"Please type customer notes here...";
    self.customerNotes.textColor = [UIColor lightGrayColor];
    self.customerNotes.delegate = self;
    
    self.skipSwitch = [[UICustomSwitch alloc] initWithFrame: CGRectMake(326, 21, 85, 27)];
    [self.skipSwitch addTarget: self action: @selector(skipSwitch:) forControlEvents:UIControlEventValueChanged];
    self.skipSwitch.on = YES;
    [scrollView addSubview: self.skipSwitch];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setTeqReqSign:nil];
    [self setPrimaryContactSign:nil];
    [self setPrintNameTextField_1:nil];
    [self setPrintNameTextField_3:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    isql *database = [isql initialize];
    
    //if ((![database.current_location isEqualToString: self.lastLocation] || ![database.current_date isEqualToString:self.lastDate]) && database.current_location != nil) {
    
    /********When pre-populate print name, save it to db********/
    if (database.current_print_name_1 == nil) {
        self.printNameTextField_1.text = database.current_primary_contact;
        database.current_print_name_1 = printNameTextField_1.text;
    }
    else if ([database.current_print_name_1 length] == 0) {
        self.printNameTextField_1.text = database.current_primary_contact;
        database.current_print_name_1 = printNameTextField_1.text;
    }
    else {
        self.printNameTextField_1.text = database.current_print_name_1;
    }
        
    if (database.current_print_name_3 == nil) {
        self.printNameTextField_3.text = database.current_teq_rep;
        database.current_print_name_3 = printNameTextField_3.text;
    }
    else if ([database.current_print_name_3 length] == 0) {
        self.printNameTextField_3.text = database.current_teq_rep;
        database.current_print_name_3 = printNameTextField_3.text;
    }
    else {
        self.printNameTextField_3.text = database.current_print_name_3;
    }
    
    self.customerNotes.text = database.current_customer_notes;
    if (self.customerNotes.text.length == 0) {
        self.customerNotes.textColor = [UIColor lightGrayColor];
        self.customerNotes.text = @"Please type customer notes here...";
    }
    else {
        self.customerNotes.textColor = [UIColor blackColor];
    }
    if ([database.current_customer_signature_available isEqualToString:@"Yes"]) {
        [self.primaryContactSign setTitle:@"Signature" forState:UIControlStateNormal];
        self.primaryContactSign.enabled = YES;
        self.skipSwitch.on = YES;        
    }
    else {
        [self.primaryContactSign setTitle:@"Signature not available" forState:UIControlStateNormal];
        self.primaryContactSign.enabled = NO;
        [self.primaryContactSign setImage:nil forState:UIControlStateNormal];
        self.skipSwitch.on = NO;
        database.current_signature_file_directory_1 = nil;
    }
    //}
    
    /************* set button background images, wrap it inside round rect box ************/
    NSString *imageString1 = database.current_signature_file_directory_1;
    imageString1 = [database sanitizeFile:imageString1];
    UIImage *backgroundImage1 = [self loadImage: imageString1 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    [primaryContactSign setImage:backgroundImage1 forState:UIControlStateNormal];
    [primaryContactSign.layer setCornerRadius:10.0f];
    [primaryContactSign.layer setMasksToBounds:YES];
    [primaryContactSign.layer setBorderWidth:1.0f];
    [primaryContactSign.layer setBorderColor:[UIColor grayColor].CGColor];
            
    NSString *imageString3 = database.current_signature_file_directory_3;
    imageString3 = [database sanitizeFile:imageString3];
    UIImage *backgroundImage3 = [self loadImage: imageString3 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    [teqReqSign setImage:backgroundImage3 forState:UIControlStateNormal];
    [teqReqSign.layer setCornerRadius:10.0f];
    [teqReqSign.layer setMasksToBounds:YES];
    [teqReqSign.layer setBorderWidth:1.0f];
    [teqReqSign.layer setBorderColor:[UIColor grayColor].CGColor];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    isql *database = [isql initialize];
    self.lastLocation = database.current_location;
    self.lastDate = database.current_date;
    [super viewWillDisappear:NO];
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{        
    [super viewDidDisappear:YES];
}

- (void)myThreadMethodAfterExit:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Loading";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(void)saveAndGoToNextPage{
    
    //DATA PERSISTENCE
    isql *database = [isql initialize];
    
    if ([database.current_location length] == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please select your appointment" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
        
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"index"]; 
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
    
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
    int movementDistance;
    if (textField == self.printNameTextField_1) {
        movementDistance = 0;
    }
    else {
        movementDistance = 200; // tweak as needed
    }     
    float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL) textViewShouldBeginEditing: (UITextView *)textView
{   
    if ([textView.text isEqualToString: @"Please type customer notes here..."]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    
    [scrollView scrollRectToVisible:CGRectMake(0, 213, 703, 748) animated:YES];
    
    return YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 703, 748) animated:YES];
    if (textView.text.length == 0) {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"Please type customer notes here...";
        [textView resignFirstResponder];
    }
    
}

-(void) textViewDidChange:(UITextView *)textView
{
    isql *database = [isql initialize];
    if (![textView.text isEqualToString: @"Please type customer notes here..."]) {
        database.current_customer_notes = textView.text;
    }
}

- (IBAction)triggerPopover:(id)sender {
    
    Signature *movies = 
    [[Signature alloc] 
     initWithNibName:@"Signature" 
     bundle:[NSBundle mainBundle]]; 
    
    popoverController = 
    [[UIPopoverController alloc] initWithContentViewController:movies];     
    popoverController.delegate = self;
    isql *database = [isql initialize];
    UIButton *button = sender;
    
    switch (button.tag) {
        case 1:
            database.signature_filename = @"Primary_Contact";
            [scrollView scrollRectToVisible:CGRectMake(0, 69, 703, 748) animated:YES];
            break;
        case 3:
            database.signature_filename = @"Teq_Representative";
            [scrollView scrollRectToVisible:CGRectMake(0, 415, 703, 748) animated:YES];
            break;
            
        default:
            break;
    }
    
    CGRect popoverRect = CGRectMake(51, 60, 463, 144);
    
    //popoverRect.size.width = MIN(popoverRect.size.width, 100); 
    [self.popoverController 
     presentPopoverFromRect:popoverRect 
     inView:self.view 
     permittedArrowDirections:UIPopoverArrowDirectionUp
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

- (void) customizedDismissPopover
{
    [self.popoverController dismissPopoverAnimated:NO];
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 703, 748) animated:YES];
    isql *database = [isql initialize];
        
    /************* set button background images, wrap it inside round rect box ************/
    
    if ([database.signature_filename isEqualToString:@"Primary_Contact"]) {
        
        NSString *imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature1", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
        imageString = [database sanitizeFile:imageString];
        UIImage *backgroundImage = [self loadImage: imageString ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        
        [primaryContactSign setImage:backgroundImage forState:UIControlStateNormal];
        [primaryContactSign.layer setCornerRadius:10.0f];
        [primaryContactSign.layer setMasksToBounds:YES];
        [primaryContactSign.layer setBorderWidth:1.0f];
        [primaryContactSign.layer setBorderColor:[UIColor grayColor].CGColor];
    }
    
    if ([database.signature_filename isEqualToString:@"Teq_Representative"]) {
        
        NSString *imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature3", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
        imageString = [database sanitizeFile:imageString];
        UIImage *backgroundImage = [self loadImage: imageString ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        
        [teqReqSign setImage:backgroundImage forState:UIControlStateNormal];
        [teqReqSign.layer setCornerRadius:10.0f];
        [teqReqSign.layer setMasksToBounds:YES];
        [teqReqSign.layer setBorderWidth:1.0f];
        [teqReqSign.layer setBorderColor:[UIColor grayColor].CGColor];
    }
    
}

- (void) cancelPopover
{
    [self.popoverController dismissPopoverAnimated:NO];
    [scrollView scrollRectToVisible:CGRectMake(0, 0, 703, 748) animated:YES];
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]);
    return result;
}

- (IBAction)printName_1 {
    isql *database = [isql initialize];
    database.current_print_name_1 = printNameTextField_1.text;
}

- (IBAction)printName_3 {
    isql *database = [isql initialize];
    database.current_print_name_3 = printNameTextField_3.text;
}

-(BOOL) checkIfFileExists:(NSString *)fileName ofType:(NSString *)extension inDirectoryPath:(NSString *)directoryPath {
    bool result;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, extension]]]) {
        result = TRUE;
        NSLog(@"true");
    } else {
        result = FALSE;
        NSLog(@"false");
    }
    
    return result;
}

- (IBAction)loadDefaultTeqRep {
    
    isql *database = [isql initialize];
    
    NSString *imageString = [NSString stringWithFormat:@"SS - default_teq_rep_signature - %@", (database.current_teq_rep == nil)? @"":database.current_teq_rep]; 
    imageString = [database sanitizeFile:imageString];
    UIImage *backgroundImage = [self loadImage: imageString ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    [teqReqSign setImage:backgroundImage forState:UIControlStateNormal];
    [teqReqSign.layer setCornerRadius:10.0f];
    [teqReqSign.layer setMasksToBounds:YES];
    [teqReqSign.layer setBorderWidth:1.0f];
    [teqReqSign.layer setBorderColor:[UIColor grayColor].CGColor];
    
    NSData *imgData = UIImageJPEGRepresentation(backgroundImage, 0.75);
    
    NSString *imageString2 = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature3", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
    imageString2 = [database sanitizeFile:imageString2];
    database.current_signature_file_directory_3 = imageString2;
    
    NSString *targetPath2 = [NSString stringWithFormat:@"%@/%@.%@", [self writablePath], imageString2, @"jpg" ];
    //NSLog(@"%@", targetPath);
    
    [imgData writeToFile:targetPath2 atomically:YES]; 
}

- (IBAction)saveDefaultTeqRep {
    
    isql *database = [isql initialize];
    
    //UIImage *image = [teqReqSign backgroundImageForState:UIControlStateNormal];
    //UIImage *image = self.teqReqSign.currentBackgroundImage;
    NSString *imageString = database.current_signature_file_directory_3; 
    
    UIImage *image = [self loadImage: imageString ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    //NSLog(@"%f", image.size.width);
    NSData *imgData = UIImageJPEGRepresentation(image, 0.75);
    //UIImagePNGRepresentation(image);
       
    NSString *imageString2 = [NSString stringWithFormat:@"SS - default_teq_rep_signature - %@", (database.current_teq_rep == nil)? @"":database.current_teq_rep];       
    imageString2 = [database sanitizeFile:imageString2];
    NSString* targetPath = [NSString stringWithFormat:@"%@/%@.%@", [self writablePath], imageString2, @"jpg" ];
    //NSLog(@"%@", targetPath);
    
    [imgData writeToFile:targetPath atomically:YES]; 
}

- (IBAction)viewUpdatedReport:(id)sender {
    
    isql *database = [isql initialize];
    
    [NSThread detachNewThreadSelector:@selector(myThreadMethodAfterExit:) toTarget:self withObject:nil];
    
    [database saveVariableToLocalDest];
    
    //do not update the whole activity for PDF
    //[database updateLocalDestForSummary];
    
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    renderer.callBackFunction = @"preview";
    
    [renderer loadVariablesForPDF];
}


-(NSString*) writablePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)skipSwitch:(UISwitch *)sender {
    isql *database = [isql initialize];
    if (sender.on == YES) {
        database.current_customer_signature_available = @"Yes";
        [self.primaryContactSign setTitle:@"Signature" forState:UIControlStateNormal];
        self.primaryContactSign.enabled = YES;
    }
    else {
        database.current_customer_signature_available = @"No";
        [self.primaryContactSign setTitle:@"Signature not available" forState:UIControlStateNormal];
        [self.primaryContactSign setImage:nil forState:UIControlStateNormal];
        self.primaryContactSign.enabled = NO;
        database.current_signature_file_directory_1 = nil;
    }
}

@end
