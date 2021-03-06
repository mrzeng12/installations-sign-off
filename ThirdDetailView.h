//
//  ThirdDetailView.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomSwitch.h"
#import "RedLaserSDK.h"

@interface ThirdDetailView : UIViewController<BarcodePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>{
    float lastInputY;
    int addBtnCount;
    BarcodePickerController		*pickerController;
    NSMutableArray				*scanHistoryArray;
    UIPopoverController *scanHistoryPopoverController;
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureRecognizer;

- (IBAction)statusChanged:(id)sender;
- (IBAction)serialNoChanged:(id)sender;

@property (strong, nonatomic) NSMutableArray *addBtnArray;
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
@property (strong, nonatomic) IBOutlet UITextView *vanStockTextView;

@property (nonatomic, strong) UIPopoverController *scanHistoryPopoverController;
@property (nonatomic) int scanTag;

- (IBAction)addSerial:(id)sender;
- (IBAction)autoFill:(UIButton *)sender;
- (IBAction)pullInstallers:(UIButton *)sender;
- (IBAction)editVanStock:(id)sender;
- (IBAction)redLaser:(UIButton *)sender;

-(void)saveSerialNumber;
-(void)checkComplete;
- (void)reloadInstallers;

@end


