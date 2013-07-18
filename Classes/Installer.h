//
//  Installer.h
//  Installation
//
//  Created by Chao Zeng on 7/15/13.
//
//

#import <UIKit/UIKit.h>

@interface Installer : UIViewController<UIActionSheetDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>{

}
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) UIActionSheet *installerActionSheet;
@property (nonatomic, strong) NSMutableArray *installersList;
@property (nonatomic, strong) NSMutableArray *installerOutlet;
@property (strong, nonatomic) IBOutlet UITextField *installer1;
@property (strong, nonatomic) IBOutlet UITextField *installer2;
@property (strong, nonatomic) IBOutlet UITextField *installer3;
@property (strong, nonatomic) IBOutlet UITextField *installer4;
@property (strong, nonatomic) IBOutlet UITextField *installer5;
@property (strong, nonatomic) IBOutlet UITextField *installer6;
@property (strong, nonatomic) IBOutlet UITextField *installer7;
@property (strong, nonatomic) IBOutlet UITextField *installer8;

- (IBAction)doneBtnClicked:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)addContact:(id)sender;

@end
