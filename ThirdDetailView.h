//
//  ThirdDetailView.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomSwitch.h"


@interface ThirdDetailView : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>{
    float lastInputY;
    int addBtnCount;
    NSMutableArray *addBtnArray;
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureRecognizer;

- (IBAction)installersChanged:(id)sender;
- (IBAction)statusChanged:(id)sender;
- (IBAction)serialNoChanged:(id)sender;


@property (strong, nonatomic) IBOutlet UITextField *installers;
@property (strong, nonatomic) IBOutlet UIButton *statusBtn;
@property (strong, nonatomic) IBOutlet UITextField *statusOutlet;
@property (strong, nonatomic) IBOutlet UITextField *SerialSB;
@property (strong, nonatomic) IBOutlet UITextField *SerialPJ;
@property (strong, nonatomic) IBOutlet UITextField *SerialSK;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) IBOutlet UILabel *addBtnDesc;
@property (strong, nonatomic) IBOutlet UILabel *commentsTag;
@property (strong, nonatomic) IBOutlet UITextView *commentsOutlet;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) UICustomSwitch *skipSwitch;
@property (strong, nonatomic) IBOutlet UILabel *vanStockOutlet;
@property (strong, nonatomic) UIActionSheet *installerActionSheet;
@property (nonatomic, strong) NSMutableArray *installersList;
@property (strong, nonatomic) IBOutlet UIButton *editVanStock;

- (IBAction)addSerial:(id)sender;
- (IBAction)autoFill:(UIButton *)sender;
- (IBAction)pullInstallers:(UIButton *)sender;
- (IBAction)editVanStock:(id)sender;
-(void)checkComplete;

@end


