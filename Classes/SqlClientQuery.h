//
//  SqlClientQuery.h
//  iSqlClient
//
//  Created by Robert Chipperfield on 05/01/2011.
//  Copyright 2011 MobileFoo / Red Gate Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlClient.h"
#import "SqlResultSet.h"
@interface SqlClientQuery : NSObject {

}

// Whether the query succeeded, in which case zero or more results tables will be
// returned, or failed, in which case the error text will be set
@property (nonatomic, assign) BOOL succeeded;

// If succeeded is NO, a description of the reason for the query failing
@property (nonatomic, retain) NSString *errorText;

// An array of SqlResultSet objects, containing the individual results of the queries
// executed. For simple queries, this will just contain a single object, but if multiple
// statements are passed in the query text, this may result in multiple result sets.
@property (nonatomic, retain) NSArray *resultSets;

@end
