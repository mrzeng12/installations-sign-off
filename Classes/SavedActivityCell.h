//
//  SavedActivityCell.h
//  Site Survey
//
//  Created by Chao Zeng on 2/25/13.
//
//

#import <UIKit/UIKit.h>

@interface SavedActivityCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *DateLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *AllRoomsLabel;
@property (strong, nonatomic) IBOutlet UILabel *CompleteLabel;
@property (strong, nonatomic) IBOutlet UILabel *SyncedLabel;
@property (strong, nonatomic) IBOutlet UILabel *activityLabel;
@property (strong, nonatomic) IBOutlet UILabel *sqLabel;
@property (strong, nonatomic) IBOutlet UILabel *soLabel;

@end
