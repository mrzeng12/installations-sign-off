//
//  FirstDetailView4.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstDetailView4 : UIViewController <UIPopoverControllerDelegate,  UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)triggerPopover:(id)sender;

- (IBAction)changePrimaryContact;


@property (nonatomic, strong) UIPopoverController *popoverController; 

@property (strong, nonatomic) IBOutlet UIButton *teqReqSign;

@property (strong, nonatomic) IBOutlet UIButton *custodialSign;

@property (strong, nonatomic) IBOutlet UIButton *primaryContactSign;

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;

- (IBAction)printName_1;
- (IBAction)printName_2;
- (IBAction)printName_3;
@property (strong, nonatomic) IBOutlet UITextField *printNameTextField_1;
@property (strong, nonatomic) IBOutlet UITextField *printNameTextField_2;
@property (strong, nonatomic) IBOutlet UITextField *printNameTextField_3;

@property (strong, nonatomic) IBOutlet UILabel *primaryContactLabel;

@property (strong, nonatomic) NSString *lastLocation;

@property (strong, nonatomic) NSString *lastDate;

- (IBAction)loadDefaultTeqRep;

- (IBAction)saveDefaultTeqRep;
- (IBAction)viewUpdatedReport:(id)sender;


@end
