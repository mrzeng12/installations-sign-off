//
//  RoomCell.m
//  Site Survey
//
//  Created by Helpdesk on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RoomCell.h"

@implementation RoomCell
@synthesize roomNumber;
@synthesize roomFloorNumber;
@synthesize roomGradeNumber;
@synthesize roomNotes;
@synthesize roomNumber1;
@synthesize roomNumber2;
@synthesize roomNumber3;
@synthesize roomNumber4;
@synthesize roomNumber5;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
