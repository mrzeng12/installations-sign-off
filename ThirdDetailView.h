//
//  ThirdDetailView.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ThirdDetailView : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>{
    float lastInputY;
    int addBtnCount;
    NSMutableArray *addBtnArray;
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureRecognizer;

- (IBAction)testChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *testContent;
@property (strong, nonatomic) IBOutlet UIButton *statusComplete;
@property (strong, nonatomic) IBOutlet UIButton *statusIncomplete;
@property (strong, nonatomic) IBOutlet UITextField *SerialSB;
@property (strong, nonatomic) IBOutlet UITextField *SerialPJ;
@property (strong, nonatomic) IBOutlet UITextField *SerialSK;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) IBOutlet UILabel *addBtnDesc;
@property (strong, nonatomic) IBOutlet UILabel *commentsTag;
@property (strong, nonatomic) IBOutlet UITextView *commentsOutlet;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)addSerial:(id)sender;

@end


