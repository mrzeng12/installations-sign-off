//
//  ThirdDetailView.m
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThirdDetailView.h"
#import <QuartzCore/QuartzCore.h>
#import "isql.h"
#import "sqlite3.h"
#import "VanStock.h"
#import "Installer.h"
#import "RedLaserSDK.h"
#import "RedBoxOverlayController.h"
#import "scanHistory.h"

@implementation ThirdDetailView
@synthesize installerActionSheet;
@synthesize installersList;
@synthesize scanHistoryPopoverController;
@synthesize addBtnArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        @try {
    		NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                          NSUserDomainMask, YES) objectAtIndex:0];
			NSString *archivePath = [documentsDir stringByAppendingPathComponent:@"ScanHistoryArchive"];
			scanHistoryArray = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
		}
		@catch (...) 
		{
    	}
        if (!scanHistoryArray)
			scanHistoryArray = [[NSMutableArray alloc] init];
        // We create the BarcodePickerController here so that we can call prepareToScan before
		// the user actually requests a scan.
		pickerController = [[BarcodePickerController alloc] init];
		[pickerController setDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
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
    [super viewDidLoad];
    int sdkStatus = RL_CheckReadyStatus();
    NSString *sdkStatusString = nil;
	switch (sdkStatus)
	{
		case RLState_EvalModeReady: sdkStatusString = @"Eval Mode Ready"; break;
		case RLState_LicensedModeReady: sdkStatusString = @"Licensed Mode Ready"; break;
		case RLState_MissingOSLibraries: sdkStatusString = @"Missing OS Libs"; break;
		case RLState_NoCamera: sdkStatusString = @"No Camera"; break;
		case RLState_BadLicense: sdkStatusString = @"Bad License"; break;
		case RLState_ScanLimitReached: sdkStatusString = @"Scan Limit Reached"; break;
		default: sdkStatusString = @"Unknown"; break;
	}
	NSLog(@"%@", [NSString stringWithFormat:@"SDK Ready Status: %@", sdkStatusString]);
    [pickerController prepareToScan];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(reloadInstallers)
     name:@"reloadInstallers" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(reloadVanStock)
     name:@"reloadVanStock" object:nil];
    
    isql *database = [isql initialize];
    
    lastInputY = 308;
    addBtnCount = 0;
    addBtnArray = [NSMutableArray array];
    
    self.commentsOutlet.layer.borderWidth = 1;
    self.commentsOutlet.layer.borderColor = [[UIColor grayColor] CGColor];
    self.commentsOutlet.layer.cornerRadius = 7.0f;
    self.vanStockTextView.layer.borderWidth = 1;
    self.vanStockTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.vanStockTextView.layer.cornerRadius = 7.0f;
    self.vanStockTextView.textColor = [UIColor grayColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(restoreView) name:UIKeyboardWillHideNotification object:nil];
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.gestureRecognizer.cancelsTouchesInView = NO;
    self.gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.gestureRecognizer];
    self.installers.delegate = self;
    self.SerialSB.delegate = self;
    self.SerialPJ.delegate = self;
    self.SerialSK.delegate = self;
    self.commentsOutlet.delegate = self;
    self.installers.textColor = [UIColor grayColor];
    self.statusOutlet.textColor = [UIColor grayColor];
    
    self.skipSwitch = [[UICustomSwitch alloc] initWithFrame: CGRectMake(168, 704, 85, 27)];
    [self.skipSwitch addTarget: self action: @selector(skipSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.scrollview addSubview: self.skipSwitch];
    
    [self.scrollview setFrame:CGRectMake(0, 44, 703, 704)];
    if ([database.current_use_van_stock isEqualToString:@"Yes"]) {
        [self.scrollview setContentSize:CGSizeMake(703, 983)];
    }
    else {
        [self.scrollview setContentSize:CGSizeMake(703, 818)];
    }
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addSerial:)];
    [self.addBtnDesc addGestureRecognizer:tapGesture];
    [self checkComplete];
    
    [self reloadInstallers];
    [self reloadVanStock];
    
    NSData *data = [database.current_serial_no dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    for (NSMutableDictionary *dict in dictArray) {
        
        if ([[dict objectForKey:@"type"] isEqualToString:@"SB"]) {
            if ([self.SerialSB.text length] == 0) {
                self.SerialSB.text = [dict objectForKey:@"serial"];
            }
            else {
                [self createButton:@"(SB)" andAutoFill:[dict objectForKey:@"serial"]];
            }
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"PJ"]) {
            if ([self.SerialPJ.text length] == 0) {
                self.SerialPJ.text = [dict objectForKey:@"serial"];
            }
            else {
                [self createButton:@"(PJ)" andAutoFill:[dict objectForKey:@"serial"]];
            }
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"SK"]) {
            if ([self.SerialSK.text length] == 0) {
                self.SerialSK.text = [dict objectForKey:@"serial"];
            }
            else {
                [self createButton:@"(SK)" andAutoFill:[dict objectForKey:@"serial"]];
            }
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"Camera"]) {
            [self createButton:@"(CAM)" andAutoFill:[dict objectForKey:@"serial"]];
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"Other"]) {
            [self createButton:@"(Other)" andAutoFill:[dict objectForKey:@"serial"]];
        }
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewDidAppear:(BOOL)animated
{
     
}

- (void) appBecameActive:(NSNotification *) notification
{
	[pickerController prepareToScan];
}

- (void) barcodePickerController:(BarcodePickerController*)picker returnResults:(NSSet *)results
{
    isql *database = [isql initialize];
    
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	
	// Restore main screen (and restore title bar for 3.0)
	//[self dismissModalViewControllerAnimated:TRUE];
    [self dismissViewControllerAnimated:true completion:nil];
	
	// If there's any results, save them in our scan history
	if (results && [results count])
	{
		NSMutableDictionary *scanSession = [[NSMutableDictionary alloc] init];
		[scanSession setObject:[NSDate date] forKey:@"Session End Time"];
		[scanSession setObject:[results allObjects] forKey:@"Scanned Items"];
		[scanHistoryArray insertObject:scanSession atIndex:0];
        // if history has more than 1 records, only include the last one
        if ([scanHistoryArray count] > 1) {
            scanHistoryArray = [[scanHistoryArray subarrayWithRange:NSMakeRange(0, 1)] mutableCopy];
        }
		// Save our new scans out to the archive file
		NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                      NSUserDomainMask, YES) objectAtIndex:0];
		NSString *archivePath = [documentsDir stringByAppendingPathComponent:@"ScanHistoryArchive"];
		[NSKeyedArchiver archiveRootObject:scanHistoryArray toFile:archivePath];
		
        if ([results count] == 1) {
            
            NSMutableDictionary *scanSession = [scanHistoryArray objectAtIndex:0];
            BarcodeResult *barcode = [[scanSession objectForKey:@"Scanned Items"] objectAtIndex:0];
            database.scanBarCode = barcode.barcodeString;
            
            if (self.scanTag == 0) {
                self.SerialSB.text = database.scanBarCode;
            }
            else if (self.scanTag == 1) {
                self.SerialPJ.text = database.scanBarCode;
            }
            else if (self.scanTag == 2) {
                self.SerialSK.text = database.scanBarCode;
            }
            else {
                NSMutableDictionary *dict = [self.addBtnArray objectAtIndex:(self.scanTag-3)];
                UITextField *textField = [dict objectForKey:@"textFieldRounded"];
                textField.text = database.scanBarCode;
            }
            [self saveSerialNumber];
            [self checkComplete];
        }
        else {
            // If it yields more than one result, open the history popover
            scanHistory *scanHistoryViewController =[[scanHistory alloc] initWithNibName:@"scanHistory" bundle:[NSBundle mainBundle]];
            scanHistoryViewController.thirdViewController = self;
            
            UIPopoverController *popover =
            [[UIPopoverController alloc] initWithContentViewController:scanHistoryViewController];
            
            popover.delegate = self;
            scanHistoryPopoverController = popover;
            
            //convert rect from self.scrollview's coordinate to self.view's coordinate
            CGRect popoverRect = CGRectMake(168, 178 + self.scanTag * 65, 383, 30);
            popoverRect = [self.scrollview convertRect:CGRectMake(168, 178 + self.scanTag * 65, 383, 30) toView:self.view];
            
            [scanHistoryPopoverController         presentPopoverFromRect:popoverRect
                                                                  inView:self.view
                                                permittedArrowDirections:UIPopoverArrowDirectionRight
                                                                animated:YES];
            
            [scanHistoryPopoverController setPopoverContentSize:CGSizeMake(300, 200) animated:NO];
            //[firstTimeView setHidden:TRUE];
        }
	}
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:
(UIPopoverController *)popoverController {
    
}

- (void)reloadInstallers {
    isql *database = [isql initialize];
    NSMutableString *tempInstaller = [NSMutableString string];
    for (NSString *string in database.current_installer) {
        [tempInstaller appendString:[NSString stringWithFormat:@"%@; ", string]];
    }
    if ([tempInstaller length] > 1) {
        self.installers.text = [tempInstaller substringToIndex:[tempInstaller length] - 2];
    }
}

- (void)reloadVanStock {
    
    isql *database = [isql initialize];
    NSData *data = [database.current_van_stock dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    NSMutableString *string = [NSMutableString string];
    
    for (int i = 0; i< [dictArray count]; i++) {
        NSMutableDictionary *dict = [dictArray objectAtIndex:i];
        
        [string appendString: [dict objectForKey:@"installer"]];
        if ([[dict objectForKey:@"installer"] length] == 0) {
            [string appendString:@"Anonymous"];
        }
        [string appendString:@" - "];
        [string appendString: [dict objectForKey:@"material"]];
        [string appendString:@"\n"];
    }
    self.vanStockTextView.text = string;
}

-(void)checkComplete
{
    isql *database = [isql initialize];
    NSData *data = [database.current_serial_no dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    int sb_flag = 0;
    int pj_flag = 0;
    int sk_flag = 0;
    for (NSMutableDictionary *dict in dictArray) {
        if([[dict objectForKey:@"type"] isEqualToString:@"SB"]) sb_flag = 1;
        if([[dict objectForKey:@"type"] isEqualToString:@"PJ"]) pj_flag = 1;
        if([[dict objectForKey:@"type"] isEqualToString:@"SK"]) sk_flag = 1;
    }
    if ([database.current_installer count] > 0 && [database.current_status length]> 0 && sb_flag == 1 && pj_flag == 1 && sk_flag == 1) {
        NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
              
        [database.menu_complete replaceObjectAtIndex:2 withObject:@"Complete"];
        [database greyoutMenu:myDict andHightlight:2];
        [database.room_complete_status setObject:@"1" forKey:@"2"];
        [database checkRoomComplete];
    }
    else {
        NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
        [database.menu_complete replaceObjectAtIndex:2 withObject:@"Incomplete"];
        [database greyoutMenu:myDict andHightlight:2];
        [database.room_complete_status setObject:@"0" forKey:@"2"];
        [database checkRoomComplete];
    }
}


- (IBAction)pullInstallers:(UIButton *)sender {
    
    Installer *installerModal = [[Installer alloc] initWithNibName:@"Installer" bundle:[NSBundle mainBundle]];
    
    installerModal.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    installerModal.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:installerModal animated:YES completion:nil];
}

- (IBAction)statusChanged:(id)sender {
    isql *database = [isql initialize];
    database.current_status = self.statusOutlet.text;
    [self checkComplete];
}

- (IBAction)serialNoChanged:(id)sender {
    [self saveSerialNumber];
    [self checkComplete];
}

- (IBAction)editVanStock:(id)sender {
    
    VanStock *vanStockModal = [[VanStock alloc] initWithNibName:@"VanStock" bundle:[NSBundle mainBundle]];
    
    vanStockModal.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vanStockModal.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:vanStockModal animated:YES completion:nil];
}

- (IBAction)redLaser:(UIButton *)sender {
    
    RedBoxOverlayController *overlayController = [[RedBoxOverlayController alloc] init];
    self.scanTag = sender.tag;
	[pickerController setOverlay:overlayController];
    pickerController.orientation = UIImageOrientationUp;
    // hide the status bar and show the scanner view
    pickerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    pickerController.modalPresentationStyle = UIModalPresentationFormSheet;
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)saveSerialNumber {
    isql *database = [isql initialize];
    NSMutableArray *temp_serial_no = [NSMutableArray array];
    if ([self.SerialSB.text length] > 0) {
        NSMutableDictionary *output = [NSMutableDictionary dictionary]; 
        [output setObject:@"SB" forKey:@"type"];
        [output setObject:self.SerialSB.text forKey:@"serial"];
        [temp_serial_no addObject:output];
    }
    if ([self.SerialPJ.text length] > 0) {
        NSMutableDictionary *output = [NSMutableDictionary dictionary];
        [output setObject:@"PJ" forKey:@"type"];
        [output setObject:self.SerialPJ.text forKey:@"serial"];
        [temp_serial_no addObject:output];
    }
    if ([self.SerialSK.text length] > 0) {
        NSMutableDictionary *output = [NSMutableDictionary dictionary];
        [output setObject:@"SK" forKey:@"type"];
        [output setObject:self.SerialSK.text forKey:@"serial"];
        [temp_serial_no addObject:output];
    }
    for (NSMutableDictionary *dict in addBtnArray) {
        UITextField *textField = [dict objectForKey:@"textFieldRounded"];
        if ([textField.text length] > 0) {
            NSString *type;
            if ([textField.placeholder isEqualToString:@"(SB)"]) {
                type = @"SB";
            }
            if ([textField.placeholder isEqualToString:@"(PJ)"]) {
                type = @"PJ";
            }
            if ([textField.placeholder isEqualToString:@"(SK)"]) {
                type = @"SK";
            }
            if ([textField.placeholder isEqualToString:@"(CAM)"]) {
                type = @"Camera";
            }
            if ([textField.placeholder isEqualToString:@"(Other)"]) {
                type = @"Other";
            }
            NSMutableDictionary *output = [NSMutableDictionary dictionary];
            [output setObject:type forKey:@"type"];
            [output setObject:textField.text forKey:@"serial"];
            [temp_serial_no addObject:output];
        }
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp_serial_no options:NSJSONWritingPrettyPrinted error:&error];
    database.current_serial_no = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
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
    int movementDistance = [textField.superview.superview convertPoint:textField.frame.origin toView:self.view].y - 150;
    [self.scrollview scrollRectToVisible:CGRectMake(0, movementDistance, 703, 356) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL) textViewShouldBeginEditing: (UITextView *)textView
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
    int movementDistance = [textView.superview.superview convertPoint:textView.frame.origin toView:self.view].y - 50;
    [self.scrollview scrollRectToVisible:CGRectMake(0, movementDistance, 703, 356) animated:YES];
    
    return  YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    
}

-(void) textViewDidChange:(UITextView *)textView
{
    isql *database = [isql initialize];
    database.current_general_notes = self.commentsOutlet.text;
    [self checkComplete];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (void) restoreView {
    NSLog(@"restore view");
    self.gestureRecognizer.cancelsTouchesInView = YES;
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [self.scrollview setFrame:CGRectMake(0, 0, 703, 704)];
    [UIView commitAnimations];
}

- (void)enableSelection:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    self.gestureRecognizer.cancelsTouchesInView = NO;
}

- (IBAction)addSerial:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: @"SMARTBoard", @"Projector", @"Speaker", @"Camera", @"Other", nil];
    [actionSheet setTag:1];
    [actionSheet showFromRect:self.addBtn.frame inView:self.scrollview animated:YES];   
    
}

- (IBAction)autoFill:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: @"Complete", @"Incomplete", nil];
    [actionSheet setTag:sender.tag];
    [actionSheet showFromRect:sender.frame inView:self.scrollview animated:YES];
}
/*
- (IBAction)vanStockChanged:(id)sender {
    isql *database = [isql initialize];
    database.current_van_stock = self.vanStockInputField.text;
}
*/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == -1) {
        return;
    }
    if (actionSheet.tag == 1) {
        NSString *text;
        switch (buttonIndex) {
            case 0:
                text = @"(SB)";
                break;
            case 1:
                text = @"(PJ)";
                break;
            case 2:
                text = @"(SK)";
                break;
            case 3:
                text = @"(CAM)";
                break;
            case 4:
                text = @"(Other)";
                break;
            default:
                break;
        }
        [self createButton:text andAutoFill:@""];
    }
    if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            self.statusOutlet.text = @"Complete";
        }
        if (buttonIndex == 1) {
            self.statusOutlet.text = @"Incomplete";
        }
        isql *database = [isql initialize];
        database.current_status = self.statusOutlet.text;
        [self checkComplete];
    }
    /*if (actionSheet.tag == 3) {
        if (buttonIndex < [installersList count]) {
            if ([self.installers.text length] == 0) {
                self.installers.text = [installersList objectAtIndex:buttonIndex];
            }
            else {
                self.installers.text = [NSString stringWithFormat:@"%@; %@", self.installers.text, [installersList objectAtIndex:buttonIndex]];
            }
        }
        isql *database = [isql initialize];
        database.current_installer = self.installers.text;
        [self checkComplete];
    }*/
}

- (void)createButton: (NSString *) text andAutoFill: (NSString *) serial {
    isql *database = [isql initialize];
    
    UITextField *textFieldRounded = [[UITextField alloc] initWithFrame:CGRectMake(168, lastInputY + 65, 383, 30)];
    textFieldRounded.borderStyle = UITextBorderStyleRoundedRect;
    textFieldRounded.textColor = [UIColor blackColor];
    textFieldRounded.font = [UIFont systemFontOfSize:17.0];
    textFieldRounded.placeholder = text;
    textFieldRounded.backgroundColor = [UIColor whiteColor];
    textFieldRounded.autocorrectionType = UITextAutocorrectionTypeNo;
    textFieldRounded.keyboardType = UIKeyboardTypeDefault;
    //textFieldRounded.returnKeyType = UIReturnKeyDone;
    //textFieldRounded.clearButtonMode = UITextFieldViewModeWhileEditing;
    textFieldRounded.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    textFieldRounded.text = serial;
    [textFieldRounded addTarget:self action:@selector(serialNoChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.scrollview addSubview:textFieldRounded];
    textFieldRounded.delegate = self;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(576, lastInputY + 69, 50, 21)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17.0];
    label.text = text;
    label.adjustsFontSizeToFitWidth = YES;
    
    [self.scrollview addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTag:addBtnCount];
    [button addTarget:self
               action:@selector(removeButtonClicked:)
     forControlEvents:UIControlEventTouchDown];    
    button.frame = CGRectMake(120, lastInputY + 67, 26, 25);
    [button setImage:[UIImage imageNamed:@"onebit_33.png"] forState:UIControlStateNormal];    
    
    [self.scrollview addSubview:button];
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanButton setTag:addBtnCount+3];
    [scanButton addTarget:self
                   action:@selector(redLaser:)
         forControlEvents:UIControlEventTouchDown];
    scanButton.frame = CGRectMake(629, lastInputY + 62, 36, 36);
    [scanButton setImage:[UIImage imageNamed:@"camera-button.png"] forState:UIControlStateNormal];
    
    [self.scrollview addSubview:scanButton];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:textFieldRounded forKey:@"textFieldRounded"];
    [dict setObject:label forKey:@"label"];
    [dict setObject:button forKey:@"button"];
    [dict setObject:scanButton forKey:@"scanButton"];
    [addBtnArray addObject:dict];
    
    [self.addBtn setFrame:CGRectMake(165, lastInputY + 115, 29, 29)];
    [self.addBtnDesc setFrame:CGRectMake(199, lastInputY + 118, 191, 21)];
    [self.commentsTag setFrame:CGRectMake(65, lastInputY + 177, 89, 21)];
    [self.commentsOutlet setFrame:CGRectMake(168, lastInputY + 177, 383, 248)];
    [self.vanStockOutlet setFrame:CGRectMake(65, lastInputY + 464, 89, 21)];
    [self.skipSwitch setFrame:CGRectMake(168, lastInputY + 464, 85, 27)];
    [self.editVanStock setFrame:CGRectMake(285, lastInputY + 463, 28, 28)];
    [self.vanStockTextView setFrame:CGRectMake(168, lastInputY + 513, 383, 170)];
    if ([database.current_use_van_stock isEqualToString:@"Yes"]) {
        [self.scrollview setContentSize:CGSizeMake(703, lastInputY + 730)];
    }
    else {
        [self.scrollview setContentSize:CGSizeMake(703, lastInputY + 565)];
    }
    
    addBtnCount++;
    lastInputY += 65;
}

- (void)removeButtonClicked:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you want to remove the item?" message:nil   delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
    [alert setTag: sender.tag];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self removeButton: alertView.tag];
        [self saveSerialNumber];
    }
}

-(void)removeButton:(int)index {
    
    isql *database = [isql initialize];
    
    NSMutableDictionary *dict = [addBtnArray objectAtIndex:index];
    [[dict objectForKey:@"textFieldRounded"] removeFromSuperview];
    [[dict objectForKey:@"label"] removeFromSuperview];
    [[dict objectForKey:@"button"] removeFromSuperview];
    [[dict objectForKey:@"scanButton"] removeFromSuperview];
    [addBtnArray removeObjectAtIndex:index];
    addBtnCount--;
    lastInputY -= 65;
    
    //reshuffle the ones under the deleted item
    for (int i = index; i< [addBtnArray count]; i++) {
        NSMutableDictionary *dict = [addBtnArray objectAtIndex:i];
        float y = [[dict objectForKey:@"textFieldRounded"] frame].origin.y;
        [[dict objectForKey:@"textFieldRounded"] setFrame: CGRectMake(168, y - 65, 383, 30)];
        y = [[dict objectForKey:@"label"] frame].origin.y;
        [[dict objectForKey:@"label"] setFrame: CGRectMake(576, y - 65, 50, 21)];
        y = [[dict objectForKey:@"button"] frame].origin.y;
        [[dict objectForKey:@"button"] setFrame: CGRectMake(120, y - 65, 26, 25)];
        
        [[dict objectForKey:@"button"] removeTarget:self
                                             action:@selector(removeButtonClicked:)
                                   forControlEvents:UIControlEventTouchDown];
        [[dict objectForKey:@"button"] setTag:i];
        [[dict objectForKey:@"button"] addTarget:self
                                          action:@selector(removeButtonClicked:)
                                forControlEvents:UIControlEventTouchDown];
        y = [[dict objectForKey:@"scanButton"] frame].origin.y;
        [[dict objectForKey:@"scanButton"] setFrame: CGRectMake(629, y - 65, 36, 36)];
        
        [[dict objectForKey:@"scanButton"] removeTarget:self
                                                 action:@selector(redLaser:)
                                       forControlEvents:UIControlEventTouchDown];
        [[dict objectForKey:@"scanButton"] setTag:i+3];
        [[dict objectForKey:@"scanButton"] addTarget:self
                                              action:@selector(redLaser:)
                                    forControlEvents:UIControlEventTouchDown];
    }
    
    [self.addBtn setFrame:CGRectMake(165, lastInputY + 50, 29, 29)];
    [self.addBtnDesc setFrame:CGRectMake(199, lastInputY + 53, 191, 21)];
    [self.commentsTag setFrame:CGRectMake(65, lastInputY + 112, 89, 21)];
    [self.commentsOutlet setFrame:CGRectMake(168, lastInputY + 112, 383, 248)];
    [self.vanStockOutlet setFrame:CGRectMake(65, lastInputY + 399, 89, 21)];
    [self.skipSwitch setFrame:CGRectMake(168, lastInputY + 399, 85, 27)];
    [self.editVanStock setFrame:CGRectMake(285, lastInputY + 398, 28, 28)];
    [self.vanStockTextView setFrame:CGRectMake(168, lastInputY + 448, 383, 170)];
    
    if ([database.current_use_van_stock isEqualToString:@"Yes"]) {
        [self.scrollview setContentSize:CGSizeMake(703, lastInputY + 665)];
    }
    else {
        [self.scrollview setContentSize:CGSizeMake(703, lastInputY + 500)];
    }
}
- (IBAction)skipSwitch:(UISwitch *)sender {
    isql *database = [isql initialize];
    if (sender.on == YES) {
        self.editVanStock.hidden = NO;
        self.vanStockTextView.hidden = NO;
        database.current_use_van_stock = @"Yes";
        [self.scrollview setContentSize:CGSizeMake(703, lastInputY + 665)];
    }
    else {
        self.editVanStock.hidden = YES;
        self.vanStockTextView.hidden = YES;
        database.current_use_van_stock = @"No";
        [self.scrollview setContentSize:CGSizeMake(703, lastInputY + 500)];
    }
}

@end
