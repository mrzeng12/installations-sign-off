//
//  Modal.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loginModal : UIViewController <UITextFieldDelegate> {

    
}

@property (strong, nonatomic) IBOutlet UIButton *verifyUserBtn;

@property (strong, nonatomic) IBOutlet UILabel *resultLabel;

@property (strong, nonatomic) IBOutlet UITextField *username_input;

@property (strong, nonatomic) IBOutlet UITextField *password_input;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UILabel *checkNewUserTag;

@property (strong, nonatomic) IBOutlet UIButton *updateUserListBtn;

@property (strong, nonatomic) IBOutlet UILabel *updateVersionLogs;


- (IBAction)updateUserListAction:(id)sender;

-(IBAction)dismissMyModalView;

-(IBAction) verifyUser;

@property (strong, nonatomic) IBOutlet UIButton *testPDF;

@end
