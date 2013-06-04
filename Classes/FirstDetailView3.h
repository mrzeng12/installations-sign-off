//
//  FirstDetailView3.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomSwitch.h"
@class CustomerAgreement;


@interface FirstDetailView3 : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    int found_in_local_dest;
    NSString *customAlertActivity;
    UITapGestureRecognizer *gestureRecognizer;
}

@property (nonatomic, strong) NSMutableArray *appointmentList;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@property (strong, nonatomic) IBOutlet UITextField *schoolNameOutlet;

@property (strong, nonatomic) IBOutlet UITextField *activityNoOutlet;

@property (strong, nonatomic) IBOutlet UITextField *dateOutlet;

@property (strong, nonatomic) IBOutlet UITextField *SOOutlet;

@property (strong, nonatomic) IBOutlet UITextField *primarycontactOutlet;

@property (strong, nonatomic) IBOutlet UILabel *existingEquipOutlet;

@property (strong, nonatomic) NSString *lastActivity;

@property (strong, nonatomic) IBOutlet CustomerAgreement *customeragreement;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *teamOutlet;

@property (strong, nonatomic) IBOutlet UITextField *districtOutlet;

@property (strong, nonatomic) IBOutlet UITextField *jobStatusOutlet;

@property (strong, nonatomic) IBOutlet UITextField *arrivalTimeOutlet;

@property (strong, nonatomic) IBOutlet UITextField *departureTimeOutlet;



@property (strong, nonatomic) IBOutlet UITextView *reasonForVisit;

- (IBAction)GoToNextPage;

- (IBAction)saveCurrentField:(id)sender;

-(void) initializeActivityDetails;

- (void)initializeActivityDetailsStepTwo;

-(void) clearFields;

@end
