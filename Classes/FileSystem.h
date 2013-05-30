//
//  FileSystem.h
//  Site Survey
//
//  Created by Chao Zeng on 4/10/13.
//
//

#import <Foundation/Foundation.h>

@interface FileSystem : NSObject

- (void) copyOldFiles: (NSArray *)fileNames;

- (void) removeOldFiles: (NSArray *)fileNames;

- (void) removeNewFiles: (NSArray *)fileNames;

- (void) renameOldFiles: (NSArray *)fileNames;

- (NSArray *) generateFileNames: (NSString *) teq_rep withActivity: (NSString *)activity andRoomNumber: (NSString *)roomNumber andDateTime: (NSString *)datetime;

@end
