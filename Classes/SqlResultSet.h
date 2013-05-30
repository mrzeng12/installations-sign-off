//
//  SqlResultSet.h
//  iSqlClient
//
//  Created by Robert Chipperfield on 05/01/2011.
//  Copyright 2011 MobileFoo / Red Gate Software. All rights reserved.
//
#import <Foundation/Foundation.h>


// A SqlResultSet object is a representation of a single SQL Server result set: somewhat
// analogous to a table, it contains some number of fields and rows. Initially the result
// set is positioned at BOF (beginning-of-file); navigation through rows is accomplished
// by calling moveNext until EOF is reached. Data in individual fields is retrieved via
// the various get methods available - getObject in the general case, with some convenience
// methods for other data types. Fields that are NULL in the database are returned as
// an NSNull object.
@interface SqlResultSet : NSObject {

}
// The number of rows in the result set
@property (nonatomic, readonly) NSInteger recordCount;
// The number of fields in the result set
@property (nonatomic, readonly) NSInteger fieldCount;

// Gets the name of a field, given its (zero-based) index
- (NSString *)nameForField:(NSInteger)fieldIndex;
// Gets the (zero-based) index of a field given its name; returns -1 if no field with the 
// specified name was found
- (NSInteger)indexForField:(NSString *)fieldName;

// Returns YES if the result set is currently positioned before the first record
- (BOOL)bof;
// Returns YES if the result set is currently positioned after the last record
- (BOOL)eof;
// Moves to the next record, if it exists; if so, returns YES, otherwise NO.
- (BOOL)moveNext;
// Moves back to before the first record - moveNext should be called before reading
// the first record
- (void)reset;

- (NSObject *)getObject:(NSInteger)field;
- (NSInteger)getInteger:(NSInteger)field;
- (long long)getLong:(NSInteger)field;
- (NSString *)getString:(NSInteger)field;
- (NSData *)getData:(NSInteger)field;
- (NSDate *)getDate:(NSInteger)field;

@end
