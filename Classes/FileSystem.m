//
//  FileSystem.m
//  Site Survey
//
//  Created by Chao Zeng on 4/10/13.
//
//

#import "FileSystem.h"
#import "isql.h"

@implementation FileSystem

- (void) copyOldFiles: (NSArray *)fileNames{
    
    // copy editing files as backup
    for (NSString *fileName in fileNames) {
        NSString* dPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* sourceName = [dPath stringByAppendingPathComponent:fileName];
        NSString* destName = [dPath stringByAppendingPathComponent:[NSString stringWithFormat:@"old-%@", fileName]];
        
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceName] ){
            if([[NSFileManager defaultManager] copyItemAtPath:sourceName toPath:destName error:nil]){
                NSLog(@"copied success %@", fileName);
            }
            else {
                NSLog(@"copied failed %@", fileName);
            }
        }
    }
    
}

- (void) removeOldFiles: (NSArray *)fileNames{
    
    // remove backup files
    for (NSString *fileName in fileNames) {
        NSString* dPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *oldFileName = [NSString stringWithFormat:@"old-%@", fileName];
        NSString* destName = [dPath stringByAppendingPathComponent:oldFileName];
        
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:destName] ){
            if([[NSFileManager defaultManager] removeItemAtPath:destName error:nil]){
                NSLog(@"remove success %@", oldFileName);
            }
            else {
                NSLog(@"remove failed %@", oldFileName);
            }
        }
    }
}

- (void) removeNewFiles: (NSArray *)fileNames{
    // remove editing files
    for (NSString *fileName in fileNames) {
        NSString* dPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString* sourceName = [dPath stringByAppendingPathComponent:fileName];
        
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceName] ){
            if([[NSFileManager defaultManager] removeItemAtPath:sourceName error:nil]){
                NSLog(@"remove success %@", fileName);
            }
            else {
                NSLog(@"remove failed %@", fileName);
            }
        }
    }
}

- (void) renameOldFiles: (NSArray *)fileNames{
    //rename backup files
    for (NSString *fileName in fileNames) {
        NSString* dPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString* sourceName = [dPath stringByAppendingPathComponent:fileName];
        NSString *oldFileName = [NSString stringWithFormat:@"old-%@", fileName];
        NSString* destName = [dPath stringByAppendingPathComponent:oldFileName];
        
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:destName] ){
            if([[NSFileManager defaultManager] moveItemAtPath:destName toPath:sourceName error:nil]){
                NSLog(@"rename success %@", oldFileName);
            }
            else {
                NSLog(@"rename failed %@", oldFileName);
            }
        }
    }
}

- (NSArray *) generateFileNames: (NSString *) teq_rep withActivity: (NSString *)activity andRoomNumber: (NSString *)roomNumber andDateTime: (NSString *)datetime{
    
    isql *database = [isql initialize];
    NSMutableArray *fileNames = [NSMutableArray arrayWithObjects: nil];
    NSString *imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (RM %@)(%@) - drawing.jpg", (teq_rep == nil)? @"":teq_rep, (activity  == nil)? @"": activity, (roomNumber == nil)? @"":roomNumber, (datetime == nil)? @"":datetime];
    imageString = [database sanitizeFile:imageString];
    [fileNames addObject:imageString];
    
    for (int i = 1; i <= 8; i++) {
        NSString *imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (RM %@)(%@) - photo%d.jpg", (teq_rep == nil)? @"":teq_rep, (activity  == nil)? @"": activity, (roomNumber == nil)? @"":roomNumber, (datetime == nil)? @"":datetime, i];
        imageString = [database sanitizeFile:imageString];
        [fileNames addObject:imageString];
    }
    return fileNames;
}
@end
