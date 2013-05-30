//
//  FirstDetailView3.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UICustomSwitch.h"
@class CustomerAgreement;


@interface FirstDetailView3 : UIViewController <UITextFieldDelegate,CLLocationManagerDelegate> {
    int found_in_local_dest;
    NSString *customAlertActivity;
}

@property (nonatomic, strong) NSMutableArray *appointmentList;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@property (strong, nonatomic) IBOutlet UITextField *schoolNameOutlet;

@property (strong, nonatomic) IBOutlet UITextField *teqRepOutlet;

@property (strong, nonatomic) IBOutlet UITextField *activityNoOutlet;

@property (strong, nonatomic) IBOutlet UITextField *dateOutlet;

@property (strong, nonatomic) IBOutlet UITextField *SOOutlet;

@property (strong, nonatomic) IBOutlet UITextField *SQOutlet;

@property (strong, nonatomic) IBOutlet UITextField *purchasingAgentOutlet;

@property (strong, nonatomic) IBOutlet UITextField *addressOutlet;

@property (strong, nonatomic) IBOutlet UITextField *bpcodeOutlet;

@property (strong, nonatomic) IBOutlet UITextField *walkthroughOutlet;

@property (strong, nonatomic) IBOutlet UITextField *primarycontactOutlet;

@property (strong, nonatomic) IBOutlet UITextField *primarytitleOutlet;

@property (strong, nonatomic) IBOutlet UITextField *primaryPhoneOutlet;

@property (strong, nonatomic) IBOutlet UITextField *primaryemailOutlet;

@property (strong, nonatomic) IBOutlet UITextField *secondcontactOutlet;

@property (strong, nonatomic) IBOutlet UITextField *secondphoneOutlet;

@property (strong, nonatomic) IBOutlet UITextField *secondemailOutlet;

@property (strong, nonatomic) IBOutlet UITextField *secondetitleOutlet;

@property (strong, nonatomic) IBOutlet UITextField *engineerOutlet;

@property (strong, nonatomic) IBOutlet UITextField *engineertitleOutlet;

@property (strong, nonatomic) IBOutlet UITextField *engineerphoneOutlet;

@property (strong, nonatomic) IBOutlet UITextField *engineeremailOutlet;

@property (strong, nonatomic) IBOutlet UITextField *schoolhoursOutlet;

@property (strong, nonatomic) IBOutlet UILabel *existingEquipOutlet;

@property (strong, nonatomic) IBOutlet UITextField *jobnameOutlet;

@property (strong, nonatomic) UICustomSwitch *elevatoravailableSwitch;

@property (strong, nonatomic) UICustomSwitch *loadingdockSwitch;

@property (strong, nonatomic) IBOutlet UITextField *roomsOutlet;

@property (strong, nonatomic) IBOutlet UITextView *specialinstructionsOutlet;

@property (strong, nonatomic) IBOutlet UITextField *hoursofinstallOutlet;

@property (strong, nonatomic) IBOutlet UITextField *installersneededOutlet;

@property (strong, nonatomic) IBOutlet UITextField *installationVansOutlet;

//@property (strong, nonatomic) NSString *lastLocation;

//@property (strong, nonatomic) NSString *lastDate;

@property (strong, nonatomic) NSString *lastActivity;

@property (strong, nonatomic) IBOutlet CustomerAgreement *customeragreement;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UIButton *mapBtn;

@property (strong, nonatomic) IBOutlet UIButton *changeActivityNoBtn;

@property (strong, nonatomic) IBOutlet UIButton *changeSchoolNameBtn;

- (IBAction)GoToNextPage;

- (IBAction)saveCurrentField:(id)sender;
- (IBAction)openGoogleMap:(id)sender;
- (IBAction)changeActivityNo:(id)sender;
- (IBAction)changeSchoolName:(id)sender;


-(void) initializeActivityDetails;

- (void)initializeActivityDetailsStepTwo;

-(void) clearFields;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

@end
