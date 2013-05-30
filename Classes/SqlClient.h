//
//  SqlClient.h
//  iSqlClient
//
//  Created by Robert Chipperfield on 05/01/2011.
//  Copyright 2011 MobileFoo / Red Gate Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SqlClientQuery;

// Block definition for the block-based API
typedef void (^SqlClientCompletionBlock)(SqlClientQuery *);

// SqlClientDelegate is a protocol that you should implement on the class you
// wish to receive callbacks when a query you requested completes
@protocol SqlClientDelegate

// The sqlQueryDidFinishExecuting method is called on the supplied delegate when
// the query has been processed by the server and the results are ready to be
// consumed. The status, error text (if any) and result sets (if any) are
// passed in the supplied SqlClientQuery object.
- (void)sqlQueryDidFinishExecuting:(SqlClientQuery *)query;

@end

// The SqlClient object is the base object that dispatches queries to the web service,
// and parses the results returned. Keep this object alive until you finish dealing with queries
// and their results.
@interface SqlClient : NSObject {

}

// Use the clientWithServer method to create an instance of the SqlClient class, passing it the URL
// of the web service, SQL Server instance and databse to connect to, and a username and password
// used to connect to SQL Server. If username is empty, Integrated Authentication using the identity
// of the IIS Worker Process will be attempted.
+ (SqlClient *)clientWithServer:(NSString *)serverURL Instance:(NSString *)instance Database:(NSString *)db Username:(NSString *)user Password:(NSString *)pass;

// Dispatch a query to the SQL Server asynchronously. When the query completes, the
// sqlQueryDidFinishExecuting method is called on the supplied delegate, allowing results
// to be retrieved.
- (void)executeQuery:(NSString *)queryString withDelegate:(id<SqlClientDelegate>)delegate;

// Block-based version of executeQuery:withDelegate:. When the query completes, the block
// will be called, allowing results to be retrieved.
- (void)executeQuery:(NSString *)queryString withCompletionBlock:(SqlClientCompletionBlock)block;

@end
