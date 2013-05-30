//
//  photoEditor.h
//  Site Survey
//
//  Created by Helpdesk on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "photoPaintView.h"

@interface photoEditor : UIViewController{
    photoPaintView *paint;
}
@property (strong, nonatomic) photoPaintView *paint;

- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)clearBtnClicked:(id)sender;
- (IBAction)DoneBtnClicked:(id)sender;



@end
