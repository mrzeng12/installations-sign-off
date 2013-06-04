//
//  CustomerAgreement.h
//  Site Survey
//
//  Created by Helpdesk on 8/1/12.
//
//
@class FirstDetailView4;
#import <UIKit/UIKit.h>
#import "UICustomSwitch.h"

@interface CustomerAgreement : UIViewController {
    NSMutableArray *roomList;
    NSMutableString *roomListString;
}
- (IBAction)viewPDF:(id)sender;
- (IBAction)option2:(id)sender;
@property (strong, nonatomic) IBOutlet FirstDetailView4 *firstdetailview4;
@property (strong, nonatomic) IBOutlet UIButton *viewPDFbtn;
@property (strong, nonatomic) IBOutlet UIButton *option2btn;
- (IBAction)firstSwitch:(id)sender;
- (IBAction)secondSwitch:(id)sender;

@property (strong, nonatomic) UICustomSwitch *firstSwitch;

@property (strong, nonatomic) UICustomSwitch *secondSwitch;
@property (strong, nonatomic) IBOutlet UITextView *roomListTextView;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell2;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@end
