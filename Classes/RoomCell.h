//
//  RoomCell.h
//  Site Survey
//
//  Created by Helpdesk on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *roomNumber1;
@property (weak, nonatomic) IBOutlet UILabel *roomNumber2;
@property (weak, nonatomic) IBOutlet UILabel *roomNumber3;


@property (weak, nonatomic) IBOutlet UIButton *readyBtn;

@property (weak, nonatomic) IBOutlet UIButton *checkmarkBtn;

@property (weak, nonatomic) IBOutlet UILabel *complete1;

@property (weak, nonatomic) IBOutlet UILabel *complete2;

@property (weak, nonatomic) IBOutlet UILabel *complete3;


@end
