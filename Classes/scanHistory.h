//
//  scanHistory.h
//  Installation
//
//  Created by Chao Zeng on 8/2/13.
//
//

#import <UIKit/UIKit.h>
#import "ThirdDetailView.h"

@interface scanHistory : UITableViewController {
    NSMutableArray *scanHistoryArray;
}
@property (nonatomic, strong) ThirdDetailView *thirdViewController;

@end
