//
//  isql.m
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import "isql.h"
#import "SqlClient.h"
#import "SqlResultSet.h"
#import "SqlClientQuery.h"
#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "LGViewHUD.h"
#import "ZipArchive.h"
#import "objc/runtime.h"

#define testing

@implementation isql

static isql *sharedIsql = nil;

static SqlClient *client = nil;

+(isql*)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedIsql = [[isql alloc] init];
        sharedIsql.debugMode = NO;//
        sharedIsql.loadingViews = 0;
        sharedIsql.first_time_load = 1;
        sharedIsql.room_complete_status = [NSMutableDictionary dictionary];
        sharedIsql.dbpathString = [sharedIsql getDBPath];
    }
    return sharedIsql;
}

-(SqlClient *) databaseConnect

{    
    //if(client == nil)
    //{
        //client = [SqlClient clientWithServer: @"http://10.0.14.121/isql/" Instance:@"3YWD8P1" Database:@"sitesurvey" Username:@"sa" Password:@"Z3#gCh@r"];
        client = [SqlClient clientWithServer: @"http://108.54.230.13/isql/" Instance:@"ARTEMIS" Database:@"install" Username:@"tequser" Password:@"Teq058"];
        //NSLog(@"Create a new sql instance");
    //}
    return client;
}

- (NSMutableString *) displayDataFunction: (SqlClientQuery *) query  {
    
    NSMutableString *outputString =  [NSMutableString stringWithCapacity:1024];
    //[outputString appendFormat:@"%@ | ", query];
    for(SqlResultSet *resultSet in query.resultSets){
        for(int i=0; i<resultSet.fieldCount;i++){
            [outputString appendFormat:@"%@ | ", [resultSet nameForField:i]];
        }
        [outputString appendString:@"\r\n-----------\r\n"];
        
        while([resultSet moveNext]) {
            for(int i=0; i<resultSet.fieldCount; i++){
                [outputString appendFormat:@"%@ | ", [resultSet getData:i]];
            }
            [outputString appendString:@"\r\n"];
        }
    }
    return outputString;
    //resultLabel.text = outputString;
    
    
    //[resultLabel sizeToFit];
    
    
}

- (NSInteger) countDataFunction: (SqlClientQuery *) query  {
    
    NSInteger outputNumber = 0;
    //[outputString appendFormat:@"%@ | ", query];
    for(SqlResultSet *resultSet in query.resultSets){
        outputNumber = resultSet.recordCount;
    }
    return outputNumber;
    //resultLabel.text = outputString;
    
    
    //[resultLabel sizeToFit];
    
    
}

- (void) checkLatestVersion {
    
#ifndef testing
    //only work in production environment
    /*
    isql *database = [isql initialize];
    SqlClient *client =[database databaseConnect];
    //[activityIndicator startAnimating];
    
    NSString* queryString = @"select [Version] from [sitesurvey].[dbo].[ipadSiteSurveyVersion] order by [ReleaseDate] desc";
    
    [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
        
        NSString *latestVersion = nil;
        if(query.succeeded){
            
            SqlResultSet *resultSet = [query.resultSets objectAtIndex:0];
            
            while([resultSet moveNext]) {
                latestVersion = [NSString stringWithFormat:@"%@", [resultSet getData:0]];
            }
            
        }else{
            NSLog(@"%@", query.errorText);
        }
        NSString *currentVersion = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        if ([currentVersion length] > 0 && [latestVersion length] > 0) {
            int currentVersionNumber = [[currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
            int latestVersionNumber = [[latestVersion stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
            if (currentVersionNumber < latestVersionNumber) {
                //if you are behind latest version, pops up. if you are latest version of beyond latest version, it is fine.
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"There is a new version %@ available. Please update through testFlight as soon as possible.", latestVersion] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [message show];
            }
        }
        
    }];
     */
#endif
}

- (void) remoteSrcToLocalSrc: (BOOL) upload {
    
    [self copyDatabaseIfNeeded];
    
    isql *database = [isql initialize];
    
    SqlClient *client =[database databaseConnect];
    //[activityIndicator startAnimating];
    
    NSMutableString* queryString = [NSMutableString string];
    [queryString appendString:[NSString stringWithFormat:@"%@", @"select [Activity Number], [AssignedName], [BP Code], [BP Name], [Business Partner 2], [BP2 Name], [District], [Contact Person], [Contact 2], [POD], [SO], [StartDateTime], [User ID], [File1], [File2] from [install].[dbo].[IpadInstall_Phoenix]"]];
    
    [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
        //[activityIndicator stopAnimating];
        
        if(query.succeeded){
            
            srcDBArray = [NSMutableArray arrayWithObjects: nil];              
            SqlResultSet *resultSet = [query.resultSets objectAtIndex:0];
            int row_number = 0;
            while([resultSet moveNext]) {
                NSMutableArray *srcDBRow = [NSMutableArray arrayWithObjects: nil];
                for(int i=0; i<resultSet.fieldCount; i++){
                    //it is easy to do full find and replace in objective c than in sql
                    NSString *string = [NSString stringWithFormat:@"%@", [resultSet getData:i]];
                    [srcDBRow addObject: [database removeApostrophe: string]];
                }
                [srcDBArray addObject: srcDBRow];
                row_number++;
            }
            
            sqlite3 *masterDB;
            
            @try {
                
                
                sqlite3_stmt *init_statement = nil;
                const char *dbpath = [self.dbpathString UTF8String];
                
                if (sqlite3_open(dbpath, &masterDB) == SQLITE_OK)
                    
                {
                    NSString* statement;
                    
                    statement = @"BEGIN EXCLUSIVE TRANSACTION";
                    
                    if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &init_statement, NULL) != SQLITE_OK) {
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"init_statement wrong" format:@"init_statement wrong"];
                        //return NO;
                    }
                    
                    if (sqlite3_step(init_statement) != SQLITE_DONE) {
                        sqlite3_finalize(init_statement);
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"init_statement wrong" format:@"init_statement wrong"];
                        //return NO;
                    }
                    
                    statement = @"delete from local_src";
                    sqlite3_stmt *delete_statement;
                    
                    if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &delete_statement, NULL) != SQLITE_OK) {
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"delete_statement wrong" format:@"delete_statement wrong"];
                        //return NO;
                    }
                    if (sqlite3_step(delete_statement) != SQLITE_DONE) {
                        sqlite3_finalize(delete_statement);
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"delete_statement wrong" format:@"delete_statement wrong"];
                        //return NO;
                    }
                    
                    NSTimeInterval timestampB = [[NSDate date] timeIntervalSince1970];
                    //srcNameArray is the original SQL Server column names in original order
                    NSArray *srcNameArray = [NSArray arrayWithObjects:@"Activity Number", @"AssignedName", @"BP Code", @"BP Name", @"Business Partner 2", @"BP2 Name", @"District", @"Contact Person", @"Contact 2", @"POD", @"SO", @"StartDateTime", @"User ID", @"File1", @"File2", nil];
                    //destNameArray is the original SQL Server column names in local_src order
                    NSArray *destNameArray = [NSArray arrayWithObjects:@"Activity Number", @"AssignedName", @"BP Code", @"BP Name", @"District", @"Contact Person", @"POD", @"SO", @"StartDateTime", @"User ID", @"File1", @"File2", nil];
                    //below is insert statement, which use local_src column names and order
                    statement = @"INSERT INTO local_src(Activity_Number, Assigned_Name, BP_Code, BP_Name, District, Contact_Person, POD, SO, StartDateTime, User_ID, File1, File2) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";

                    sqlite3_stmt *compiledStatement;
                    
                    if(sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
                    {
                        for (int i = 0; i < [srcDBArray count]; i++) {
                            
                            NSMutableDictionary *srcDict = [NSMutableDictionary dictionary];
                            for (int j = 0; j < [srcNameArray count]; j++) {
                                //StartDateTime, EndDateTime needs to trancate the last part
                                NSString *tempString = [[srcDBArray objectAtIndex:i] objectAtIndex:j];
                                if ((j == 11) && [tempString length] > 21) {
                                    tempString = [tempString substringToIndex:19];
                                }                                
                                [srcDict setObject: tempString forKey:[srcNameArray objectAtIndex: j] ];                                
                            }
                                                        
                            if ([[srcDict objectForKey:@"Business Partner 2"] length] > 0) {                                
                                //if bp2 exists, use bp2 info
                                [srcDict setObject:[srcDict objectForKey:@"Business Partner 2"] forKey:@"BP Code" ];
                                [srcDict setObject:[srcDict objectForKey:@"BP2 Name"] forKey:@"BP Name" ];                                
                            }
                            
                            if ([[srcDict objectForKey:@"Business Partner 2"] length] > 0 && [[srcDict objectForKey:@"Contact 2"] length] > 0 ) {                                
                                //if bp2 exists, and contact2 exists, use contact2
                                [srcDict setObject:[srcDict objectForKey:@"Contact 2"] forKey: @"Contact Person"];
                            }                            
                                                        
                            for (int j = 0; j < [destNameArray count]; j++) {
                                sqlite3_bind_text(compiledStatement, j+1, [[srcDict objectForKey: [destNameArray objectAtIndex:j]] UTF8String], -1, SQLITE_TRANSIENT);
                            }
                            while(YES){
                                NSInteger result = sqlite3_step(compiledStatement);
                                if(result == SQLITE_DONE){
                                    break;
                                }
                                else if(result != SQLITE_BUSY){
                                    printf("db error: %s\n", sqlite3_errmsg(masterDB));
                                    break;
                                }
                            }
                            sqlite3_reset(compiledStatement);
                        }
                       
                        timestampB = [[NSDate date] timeIntervalSince1970] - timestampB;
                        NSLog(@"RemoteSrcToLocalSrc Insert Time Taken: %f",timestampB);
                        
                        // COMMIT
                        statement = @"COMMIT TRANSACTION";
                        sqlite3_stmt *commitStatement;
                        if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &commitStatement, NULL) != SQLITE_OK) {
                            printf("db error: %s\n", sqlite3_errmsg(masterDB));
                            [NSException raise:@"commitStatement wrong" format:@"commitStatement wrong"];
                            //return NO;
                        }
                        if (sqlite3_step(commitStatement) != SQLITE_DONE) {
                            printf("db error: %s\n", sqlite3_errmsg(masterDB));
                            [NSException raise:@"commitStatement wrong" format:@"commitStatement wrong"];
                            //return NO;
                        }
                        
                        //     sqlite3_finalize(beginStatement);
                        sqlite3_finalize(compiledStatement);
                        sqlite3_finalize(commitStatement);
                        //return YES;
                    }
                    
                    //return YES;
                }
                
            }
            
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {        
                sqlite3_close(masterDB);
                NSLog(@"remoteSrcToLocalSrc complete");
                               
                [self checkifMenuTableExist];
            }
            
        }else{
            NSLog(@"no network -- remoteSrcToLocalSrc fail");
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil message:@"Could not connect to the server. Working offline" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
          
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"EnableLogin" object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:nil];
            NSLog(@"%@", query.errorText);
        }
    }];
    
}

- (void) checkifMenuTableExist

{
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    
    [database copyDatabaseIfNeeded];
    __block NSString *localMenuVersion;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {   
            
            NSString *selectSQL = [NSString stringWithFormat:@"select [name] from local_menu where Xib = 'Version'"];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    localMenuVersion = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
            
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
    }
    @finally {
        sqlite3_close(db);
        
        
        SqlClient *client =[database databaseConnect];
        //[activityIndicator startAnimating];
        
        NSString* queryString = @"select [name] from [sitesurvey].[dbo].[menu202] where Xib = 'Version'";
        
        [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
            
            NSString *version = nil;
            if(query.succeeded){
                
                SqlResultSet *resultSet = [query.resultSets objectAtIndex:0];
                
                while([resultSet moveNext]) {
                    version = [NSString stringWithFormat:@"%@", [resultSet getData:0]];
                }
                
            }else{
                NSLog(@"%@", query.errorText);
            }
            
            if (![localMenuVersion isEqualToString:version]) {
                [self remoteMenuToLocalMenu];
            }
            else {
                NSLog(@"remoteMenuToLocalMenu skip");
                [self remoteUserToLocalUser];
            }
            
            
        }];
    }
}

- (void) remoteMenuToLocalMenu {
    
    [self copyDatabaseIfNeeded];
    
    isql *database = [isql initialize];
    
    SqlClient *client =[database databaseConnect];
    //[activityIndicator startAnimating];
    
    NSMutableString* queryString = [NSMutableString string];
    [queryString appendString:[NSString stringWithFormat:@"%@", @"select [Xib], [Name], [SOR], [Session], [Row], [Cat1], [Cat2], [Cat3], [Number], [Form], [Dependency1], [Dependency2], [Dependency3], [Dependency4], [Dependency5], [Dependency6], [Key1], [Value1], [Key2], [Value2], [Key3], [Value3] from [sitesurvey].[dbo].[menu202]"]];
    
    [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
        //[activityIndicator stopAnimating];
        
        if(query.succeeded){
            
            srcDBArray = [NSMutableArray arrayWithObjects: nil];
            SqlResultSet *resultSet = [query.resultSets objectAtIndex:0];
            int row_number = 0;
            while([resultSet moveNext]) {
                NSMutableArray *srcDBRow = [NSMutableArray arrayWithObjects: nil];
                for(int i=0; i<resultSet.fieldCount; i++){
                    [srcDBRow addObject: [resultSet getData:i]];
                }
                [srcDBArray addObject: srcDBRow];
                row_number++;
            }
            
            //sqlite3 *db;
            //sqlite3_stmt    *statement;
            sqlite3 *masterDB;
            
            @try {
                
                
                sqlite3_stmt *init_statement = nil;
                const char *dbpath = [self.dbpathString UTF8String];
                
                if (sqlite3_open(dbpath, &masterDB) == SQLITE_OK)
                
                {
                    NSString* statement;
                    
                    statement = @"BEGIN EXCLUSIVE TRANSACTION";
                    
                    if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &init_statement, NULL) != SQLITE_OK) {
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"init_statement wrong" format:@"init_statement wrong"];
                        //return NO;
                    }
                    
                    if (sqlite3_step(init_statement) != SQLITE_DONE) {
                        sqlite3_finalize(init_statement);
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"init_statement wrong" format:@"init_statement wrong"];
                        //return NO;
                    }
                    
                    statement = @"delete from local_menu";
                    sqlite3_stmt *delete_statement;
                    
                    if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &delete_statement, NULL) != SQLITE_OK) {
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"delete_statement wrong" format:@"delete_statement wrong"];
                        //return NO;
                    }
                    if (sqlite3_step(delete_statement) != SQLITE_DONE) {
                        sqlite3_finalize(delete_statement);
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"delete_statement wrong" format:@"delete_statement wrong"];
                        //return NO;
                    }
                    
                    NSTimeInterval timestampB = [[NSDate date] timeIntervalSince1970];
                    
                    //statement = @"insert into table(id, name) values(?,?)";
                    statement = @"INSERT INTO local_menu ([Xib], [Name], [SOR], [Session], [Row], [Cat1], [Cat2], [Cat3], [Number], [Form], [Dependency1], [Dependency2], [Dependency3], [Dependency4], [Dependency5], [Dependency6], [Key1], [Value1], [Key2], [Value2], Key3, Value3) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
                    sqlite3_stmt *compiledStatement;
                    
                    if(sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
                    {
                        for(int i = 0; i < [srcDBArray count]; i++){
                            NSMutableArray *stringArray = [NSMutableArray array];
                            
                            for (int j = 0; j < 22; j++) {
                                NSString *tempString = [NSString stringWithFormat:@"%@", [[srcDBArray objectAtIndex:i] objectAtIndex:j] ] ;
                                tempString = [tempString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                                [stringArray addObject: tempString];
                                
                            }
                            for (int j = 0; j < 22; j++) {
                                NSString *tempString = ([[srcDBArray objectAtIndex:i] objectAtIndex:j] != [NSNull null])?[stringArray objectAtIndex:j]:@"";
                                sqlite3_bind_text(compiledStatement, j+1, [tempString UTF8String], -1, SQLITE_TRANSIENT);
                            }
                            //sqlite3_bind_int(compiledStatement, 1, i );
                            //sqlite3_bind_text(compiledStatement, 2, [objName UTF8String], -1, SQLITE_TRANSIENT);
                            while(YES){
                                NSInteger result = sqlite3_step(compiledStatement);
                                if(result == SQLITE_DONE){
                                    break;
                                }
                                else if(result != SQLITE_BUSY){
                                    printf("db error: %s\n", sqlite3_errmsg(masterDB));
                                    break;
                                }
                            }
                            sqlite3_reset(compiledStatement);
                            
                        }
                        timestampB = [[NSDate date] timeIntervalSince1970] - timestampB;
                        NSLog(@"Menu Insert Time Taken: %f",timestampB);
                        
                        // COMMIT
                        statement = @"COMMIT TRANSACTION";
                        sqlite3_stmt *commitStatement;
                        if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &commitStatement, NULL) != SQLITE_OK) {
                            printf("db error: %s\n", sqlite3_errmsg(masterDB));
                            [NSException raise:@"commitStatement wrong" format:@"commitStatement wrong"];
                            //return NO;
                        }
                        if (sqlite3_step(commitStatement) != SQLITE_DONE) {
                            printf("db error: %s\n", sqlite3_errmsg(masterDB));
                            [NSException raise:@"commitStatement wrong" format:@"commitStatement wrong"];
                            //return NO;
                        }
                        
                        //     sqlite3_finalize(beginStatement);
                        sqlite3_finalize(compiledStatement);
                        sqlite3_finalize(commitStatement);
                        //return YES;
                    }
                    
                    //return YES;
                }
                
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {
                sqlite3_close(masterDB);
                NSLog(@"remoteMenuToLocalMenu complete");
                                
                [self remoteUserToLocalUser];
            }
            
            
        }else{
            NSLog(@"no network -- remoteMenuToLocalMenu fail");
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil message:@"Could not connect to the server. Working offline" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
            
            NSLog(@"%@", query.errorText);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"EnableLogin" object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:nil];
        }
    }];
    
}

- (void) remoteUserToLocalUser {
    
    [self copyDatabaseIfNeeded];
    
    isql *database = [isql initialize];
    
    if ([database.current_teq_rep length] > 0) {
        
        //if login already, skip this step. Because the user already exists in the list
        NSLog(@"remoteUserToLocalUser skip");
        
        NSDate *today = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
        NSString *tempString = [formatter stringFromDate:today];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:tempString forKey:@"lastUpdated"];
        [prefs synchronize];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:nil];
        
        return;
    }
    //beyond this line is for login page only.
    
    SqlClient *client =[database databaseConnect];
    //[activityIndicator startAnimating];
    
    NSMutableString* queryString = [NSMutableString string];
    [queryString appendString:[NSString stringWithFormat:@"%@", @"select [Name], [User ID] from [sitesurvey].[dbo].[Users] where [User ID] is not null"]];
    
    [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
        //[activityIndicator stopAnimating];
        
        if(query.succeeded){
            
            srcDBArray = [NSMutableArray arrayWithObjects: nil];
            SqlResultSet *resultSet = [query.resultSets objectAtIndex:0];
            int row_number = 0;
            while([resultSet moveNext]) {
                NSMutableArray *srcDBRow = [NSMutableArray arrayWithObjects: nil];
                for(int i=0; i<resultSet.fieldCount; i++){
                    [srcDBRow addObject: [resultSet getData:i]];
                }
                [srcDBArray addObject: srcDBRow];
                row_number++;
            }
            
            sqlite3 *masterDB;
            
            @try {
                
                
                sqlite3_stmt *init_statement = nil;
                const char *dbpath = [self.dbpathString UTF8String];
                
                if (sqlite3_open(dbpath, &masterDB) == SQLITE_OK)
                    
                {
                    NSString* statement;
                    
                    statement = @"BEGIN EXCLUSIVE TRANSACTION";
                    
                    if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &init_statement, NULL) != SQLITE_OK) {
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"init_statement wrong" format:@"init_statement wrong"];
                        //return NO;
                    }
                    
                    if (sqlite3_step(init_statement) != SQLITE_DONE) {
                        sqlite3_finalize(init_statement);
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"init_statement wrong" format:@"init_statement wrong"];
                        //return NO;
                    }
                    
                    statement = @"delete from local_sap_user;";
                    sqlite3_stmt *delete_statement;
                    
                    if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &delete_statement, NULL) != SQLITE_OK) {
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"delete_statement wrong" format:@"delete_statement wrong"];
                        //return NO;
                    }
                    if (sqlite3_step(delete_statement) != SQLITE_DONE) {
                        sqlite3_finalize(delete_statement);
                        printf("db error: %s\n", sqlite3_errmsg(masterDB));
                        [NSException raise:@"delete_statement wrong" format:@"delete_statement wrong"];
                        //return NO;
                    }
                    
                    NSTimeInterval timestampB = [[NSDate date] timeIntervalSince1970];
                    
                    //statement = @"insert into table(id, name) values(?,?)";
                    statement = @"INSERT INTO local_sap_user ([Name], [User ID]) VALUES (?, ?)";
                    sqlite3_stmt *compiledStatement;
                    
                    if(sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
                    {
                        for(int i = 0; i < [srcDBArray count]; i++){
                            
                            NSMutableArray *stringArray = [NSMutableArray array];
                            
                            for (int j = 0; j < 2; j++) {
                                NSString *tempString = [NSString stringWithFormat:@"%@", [[srcDBArray objectAtIndex:i] objectAtIndex:j] ] ;
                                //tempString = [tempString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                                [stringArray addObject: tempString];
                                //NSLog(@"%@", tempString);
                            }
                            
                            NSString *columnOne = ([[srcDBArray objectAtIndex:i] objectAtIndex:0] != [NSNull null])?[database removeApostrophe:[stringArray objectAtIndex:0]]:@"";
                            sqlite3_bind_text(compiledStatement, 1, [columnOne UTF8String], -1, SQLITE_TRANSIENT);
                            NSString *columnTwo = ([[srcDBArray objectAtIndex:i] objectAtIndex:1] != [NSNull null])?[stringArray objectAtIndex:1]:@"";
                            sqlite3_bind_text(compiledStatement, 2, [columnTwo UTF8String], -1, SQLITE_TRANSIENT);
                            
                            while(YES){
                                NSInteger result = sqlite3_step(compiledStatement);
                                if(result == SQLITE_DONE){
                                    break;
                                }
                                else if(result != SQLITE_BUSY){
                                    printf("db error: %s\n", sqlite3_errmsg(masterDB));
                                    break;
                                }
                            }
                            sqlite3_reset(compiledStatement);
                            
                        }
                        timestampB = [[NSDate date] timeIntervalSince1970] - timestampB;
                        NSLog(@"RemoteUserToLocalUser Insert Time Taken: %f",timestampB);
                        
                        // COMMIT
                        statement = @"COMMIT TRANSACTION";
                        sqlite3_stmt *commitStatement;
                        if (sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &commitStatement, NULL) != SQLITE_OK) {
                            printf("db error: %s\n", sqlite3_errmsg(masterDB));
                            [NSException raise:@"commitStatement wrong" format:@"commitStatement wrong"];
                            //return NO;
                        }
                        if (sqlite3_step(commitStatement) != SQLITE_DONE) {
                            printf("db error: %s\n", sqlite3_errmsg(masterDB));
                            [NSException raise:@"commitStatement wrong" format:@"commitStatement wrong"];
                            //return NO;
                        }
                        
                        //     sqlite3_finalize(beginStatement);
                        sqlite3_finalize(compiledStatement);
                        sqlite3_finalize(commitStatement);
                        //return YES;
                    }
                    
                    //return YES;
                }
                
            }
            
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {
                sqlite3_close(masterDB);
                NSLog(@"remoteUserToLocalUser complete");
                
                NSDate *today = [NSDate date];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
                NSString *tempString = [formatter stringFromDate:today];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setObject:tempString forKey:@"lastUpdated"];
                [prefs synchronize];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"EnableLogin" object:self userInfo:nil];
            }
            
            
        }else{
            NSLog(@"no network -- remoteUserToLocalUser fail");
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil message:@"Could not connect to the server. Working offline" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
            
            NSLog(@"%@", query.errorText);
            //NSLog(@"%@", queryString);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"EnableLogin" object:self userInfo:nil];
        }
    }];
    
}

- (void) uploadNewTable: (NSArray *) tempArray withIndexNumber: (int) index andDict: (NSArray *)   tempArrayDict{
    
    
    [self copyDatabaseIfNeeded];
    
    isql *database = [isql initialize];
    
    SqlClient *client =[database databaseConnect];
    //[activityIndicator startAnimating];
    NSMutableArray *items = [NSMutableArray array];
    NSMutableString* queryString = [NSMutableString string];
    
    //NSMutableDictionary *item = [NSMutableDictionary dictionary];    
    
    NSMutableDictionary *Rowofdict = [tempArrayDict objectAtIndex:index];
    NSString *string;
    NSMutableDictionary *dictFromString;
    NSString *stringData;
    NSData *data;
    NSError *e;
    
    string = [Rowofdict objectForKey:@"Projection_availability"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Projection_availability" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"New_projection_type"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"New_projection_type" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Existing_projection_type"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Existing_projection_type" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"No_projection_type"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"No_projection_type" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Projection_type"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Projection_type" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Projector"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Projection" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Projector_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Projection_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Flat_panel"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Flat_panel" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Flat_panel_other"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Flat_panel_other" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Smartboard"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Interactive_whiteboard" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Smartboard_other"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Interactive_whiteboard_other" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    /*
    string = [Rowofdict objectForKey:@"Mounting"];  //dict
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Mounting" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
     */
    stringData = [Rowofdict objectForKey:@"Mounting"];
    data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    e = nil;
    dictFromString = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    for(id key in dictFromString)
    {
        if ([[dictFromString objectForKey:key] isEqualToString:@"New"]) {
            NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
            [oneItem setObject:@"Mounting_equipment" forKey:@"type"];
            [oneItem setObject:key forKey:@"code"];
            [oneItem setObject:@"no" forKey:@"notes"];
            [items addObject:oneItem];
        }
    }
    string = [Rowofdict objectForKey:@"Mounting_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Mounting_equipment_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Custom_build_rail"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Custom_build_rail" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    /*
    string = [Rowofdict objectForKey:@"Cmp_mounting"];  //dict
    if ([string length] > 0) {        
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"CMP_mounting" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
     */
    string = [Rowofdict objectForKey:@"Cmp_mounting_location"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"CMP_mounting_location" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    stringData = [Rowofdict objectForKey:@"Cmp_mounting"];
    data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    e = nil;
    dictFromString = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    for(id key in dictFromString)
    {
        if ([[dictFromString objectForKey:key] isEqualToString:@"New"]) {
            NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
            [oneItem setObject:@"CMP_mounting" forKey:@"type"];
            [oneItem setObject:key forKey:@"code"];
            [oneItem setObject:@"no" forKey:@"notes"];
            [items addObject:oneItem];
        }
    }
    
    string = [Rowofdict objectForKey:@"CMP_mouting_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"CMP_mounting_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"CMP_mounting_other"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"CMP_mounting_other" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Cmp_poleLength"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"CMP_poleLength" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Cmp_poleLength_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Cmp_poleLength_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Existing_board_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Existing_board_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Existing_board_other"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Existing_board_other" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Existing_projector_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Existing_projector_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Existing_projector_serial"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Existing_projector_serial_no" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Existing_cmp_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Existing_CMP_model" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Existing_CMP_throw_distance"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Throw_distance_from_existing_projector_to_SB" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Existing_CMP_remount"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Relocate_existing_ceiling_mount" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Equipment_location_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Current_equipment_location" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
        
    stringData = [Rowofdict objectForKey:@"Speaker"];
    data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    e = nil;
    dictFromString = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    for(id key in dictFromString)
    {
        if ([[dictFromString objectForKey:key] isEqualToString:@"New"]) {
            NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
            [oneItem setObject:@"Speaker" forKey:@"type"];
            [oneItem setObject:key forKey:@"code"];
            [oneItem setObject:@"no" forKey:@"notes"];
            [items addObject:oneItem];
        }
    }
    string = [Rowofdict objectForKey:@"Audio_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Speaker_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Audio"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Audio" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Audio_package"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Audio_package" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Audio_accessories"];
    if ([string length] > 0) {
        NSMutableArray *array = [[string componentsSeparatedByString:@", "] mutableCopy];
        for (NSString *obj in array) {
            NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
            [oneItem setObject:@"Audio_accessories" forKey:@"type"];
            [oneItem setObject:obj forKey:@"code"];
            [oneItem setObject:@"no" forKey:@"notes"];
            [items addObject:oneItem];
        }
    }
    string = [Rowofdict objectForKey:@"Audio_accessories_other"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Audio_accessories_other" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Peripherals"];
    if ([string length] > 0) {
        NSMutableArray *array = [[string componentsSeparatedByString:@", "] mutableCopy];
        for (NSString *obj in array) {
            NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
            [oneItem setObject:@"Peripherals" forKey:@"type"];
            [oneItem setObject:obj forKey:@"code"];
            [oneItem setObject:@"no" forKey:@"notes"];
            [items addObject:oneItem];
        }
    }
    string = [Rowofdict objectForKey:@"Peripherals_others"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Peripherals_others" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Audio_accessories_other"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Audio_accessories_other" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Raceway_part_2"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Pieces_of_8_foot_raceway" forKey:@"type"];
        [oneItem setObject:@"TYTTSR2FW-8A" forKey:@"code"];
        [oneItem setObject:string forKey:@"quantity"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"General_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"General_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Internal_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Internal_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    
    string = [Rowofdict objectForKey:@"Cable_type"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Cable_type" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Cable_type_notes"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Cable_type_notes" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Cable_ports"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Cable_ports" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Port_desc"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Cable_ports_description" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Nyc_cable_bundle"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Nyc_cable_bundle" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
        
        oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Mounting_equipment" forKey:@"type"];
        [oneItem setObject:@"Teq-SBMount" forKey:@"code"];
        [oneItem setObject:@"no" forKey:@"notes"];
        [items addObject:oneItem];
    }
    string = [Rowofdict objectForKey:@"Cables_other"];
    if ([string length] > 0) {
        NSMutableDictionary *oneItem = [NSMutableDictionary dictionary];
        [oneItem setObject:@"Cables_other" forKey:@"type"];
        [oneItem setObject:string forKey:@"code"];
        [oneItem setObject:@"yes" forKey:@"notes"];
        [items addObject:oneItem];
    }
    //use the output function to convert raw cable data to part number and volumes
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    dict = [self outputCableDictFromRawData:Rowofdict];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *todayString = [formatter stringFromDate: today];
    
    NSArray *tempRow = [tempArray objectAtIndex:index];
    
    NSString *thisTeqRep = [[tempRow objectAtIndex:8] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *thisActivityNumber = [[tempRow objectAtIndex:1] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *thisRoomNumber = [[tempRow objectAtIndex:2] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    //insert all items except cables
    [queryString appendString:@"BEGIN TRANSACTION;"];
    for (NSMutableDictionary *oneItem in items) {
        NSString *item_type = [oneItem objectForKey:@"type"];
        NSString *item_code = [oneItem objectForKey:@"code"];
        NSString *is_notes = [oneItem objectForKey:@"notes"];
        NSString *item_quantity = [oneItem objectForKey:@"quantity"];
        if (item_quantity == nil) {
            item_quantity = @"1";
        }
        item_type = [item_type stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        item_code = [item_code stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
#ifdef testing
        [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [sitesurvey2].[dbo].[ipadSiteSurveyNew204] VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, thisTeqRep, item_type, item_code, item_quantity, is_notes, todayString]];
#else
        [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [sitesurvey].[dbo].[ipadSiteSurveyNew204] VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, thisTeqRep, item_type, item_code, item_quantity, is_notes, todayString]];
#endif
       
    }
    //insert cables
    for (id key in dict) {
        NSString *item_quantity = [dict objectForKey:key];
        NSString *key_string = [key stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        item_quantity = [item_quantity stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        if ([item_quantity intValue] > 0) {
            
#ifdef testing
            [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [sitesurvey2].[dbo].[ipadSiteSurveyNew204] VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, thisTeqRep, @"Cables", key_string, item_quantity, @"no", todayString]];
#else
            [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [sitesurvey].[dbo].[ipadSiteSurveyNew204] VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, thisTeqRep, @"Cables", key_string, item_quantity, @"no", todayString]];
#endif
           
        }
    }
    
    //just to make sure it is not sending empty query
    if ([queryString length] == 0) {
#ifdef testing
        [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [sitesurvey2].[dbo].[ipadSiteSurveyNew204] VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, thisTeqRep, @"testing", @"testing", @"1", @"no", todayString]];
#else
        [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [sitesurvey].[dbo].[ipadSiteSurveyNew204] VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, thisTeqRep, @"testing", @"testing", @"1", @"no", todayString]];
#endif
        
    }
    [queryString appendString:@"COMMIT TRANSACTION;"];
    //NSLog(@"%@", queryString);
    
    [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
        //[activityIndicator stopAnimating];
        
        if(query.succeeded){
            {
                
                NSLog(@"%@", @"localDestToRemoteDest success");
                
                sqlite3 *db;
                sqlite3_stmt    *statement;
                
                @try {
                    
                    const char *dbpath = [self.dbpathString UTF8String];
                    
                    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
                    {
                        
                        NSString *insertSQL = [NSString stringWithFormat:
                                               @"update local_dest set [Sync_time]='%@' where [Teq_rep]='%@' and [Activity_no]='%@' and [Room_Number]='%@';", todayString, thisTeqRep, thisActivityNumber, thisRoomNumber];
                        const char *insert_stmt = [insertSQL UTF8String];
                        
                        if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                            
                            if (sqlite3_step(statement) == SQLITE_DONE)
                            {
                                //NSLog(@"delete successfully");
                            } else {
                                NSLog(@"delete failed: %s", sqlite3_errmsg(db));
                                
                            }
                            sqlite3_finalize(statement);
                        }
                        else {
                            NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                        }
                        
                    }
                }
                @catch (NSException *exception) {
                    /*
                     NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Something wrong during syncronization, please try later again" forKey:@"index"];
                     
                     [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"alertDBError" object:self userInfo:dict];
                     */
                }
                @finally {        
                    sqlite3_close(db);
                }  
                
            }
        }else{
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil message:@"Sync failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
            
            NSLog(@"%@", query.errorText);
            //NSLog(@"%@", queryString);
        }
        [self localDestToRemoteDestRecursive:tempArray withIndexNumber:(index-1) andDict:tempArrayDict];
    }];
    
    
}

- (NSMutableDictionary *) outputCableDictFromRawData : (NSMutableDictionary *) Rowofdict {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *string;
    
    if (![[Rowofdict objectForKey:@"Vgamm_plenum"] isEqualToString:@"Yes"]) {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM015"] intValue]+[[Rowofdict objectForKey:@"Vgamm15"] intValue]];
        [dict setObject:string forKey:@"HD15MM015"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM025"] intValue]+[[Rowofdict objectForKey:@"Vgamm25"] intValue]];
        [dict setObject:string forKey:@"HD15MM025"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM035"] intValue]+[[Rowofdict objectForKey:@"Vgamm35"] intValue]];
        [dict setObject:string forKey:@"HD15MM035"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM050"] intValue]+[[Rowofdict objectForKey:@"Vgamm50"] intValue]];
        [dict setObject:string forKey:@"HD15MM050"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM075"] intValue]+[[Rowofdict objectForKey:@"Vgamm75"] intValue]];
        [dict setObject:string forKey:@"HD15MM075"];
    }
    else {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM015P"] intValue]+[[Rowofdict objectForKey:@"Vgamm15"] intValue]];
        [dict setObject:string forKey:@"HD15MM015P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM025P"] intValue]+[[Rowofdict objectForKey:@"Vgamm25"] intValue]];
        [dict setObject:string forKey:@"HD15MM025P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM035P"] intValue]+[[Rowofdict objectForKey:@"Vgamm35"] intValue]];
        [dict setObject:string forKey:@"HD15MM035P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM050P"] intValue]+[[Rowofdict objectForKey:@"Vgamm50"] intValue]];
        [dict setObject:string forKey:@"HD15MM050P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM075P"] intValue]+[[Rowofdict objectForKey:@"Vgamm75"] intValue]];
        [dict setObject:string forKey:@"HD15MM075P"];
    }
    if (![[Rowofdict objectForKey:@"Hdmi_plenum"] isEqualToString:@"Yes"]) {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI016"] intValue]+[[Rowofdict objectForKey:@"Hdmi15"] intValue]];
        [dict setObject:string forKey:@"HDMI016"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI025"] intValue]+[[Rowofdict objectForKey:@"Hdmi25"] intValue]];
        [dict setObject:string forKey:@"HDMI025"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI050"] intValue]+[[Rowofdict objectForKey:@"Hdmi50"] intValue]];
        [dict setObject:string forKey:@"HDMI050"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI075"] intValue]+[[Rowofdict objectForKey:@"Hdmi75"] intValue]];
        [dict setObject:string forKey:@"HDMI075"];
    }
    else {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI015P"] intValue]+[[Rowofdict objectForKey:@"Hdmi15"] intValue]];
        [dict setObject:string forKey:@"HDMI015P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI025P"] intValue]+[[Rowofdict objectForKey:@"Hdmi25"] intValue]];
        [dict setObject:string forKey:@"HDMI025P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI050P"] intValue]+[[Rowofdict objectForKey:@"Hdmi50"] intValue]];
        [dict setObject:string forKey:@"HDMI050P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI075P"] intValue]+[[Rowofdict objectForKey:@"Hdmi75"] intValue]];
        [dict setObject:string forKey:@"HDMI075P"];
    }
    if (![[Rowofdict objectForKey:@"Rca_comp_plenum"] isEqualToString:@"Yes"]) {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAC012"] intValue]+[[Rowofdict objectForKey:@"Rca_comp12"] intValue]];
        [dict setObject:string forKey:@"RCAC012"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAC025"] intValue]+[[Rowofdict objectForKey:@"Rca_comp25"] intValue]];
        [dict setObject:string forKey:@"RCAC025"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAC050"] intValue]+[[Rowofdict objectForKey:@"Rca_comp50"] intValue]];
        [dict setObject:string forKey:@"RCAC050"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAC075"] intValue]+[[Rowofdict objectForKey:@"Rca_comp75"] intValue]];
        [dict setObject:string forKey:@"RCAC075"];
    }
    else {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAC012P"] intValue]+[[Rowofdict objectForKey:@"Rca_comp12"] intValue]];
        [dict setObject:string forKey:@"RCAC012P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAC025P"] intValue]+[[Rowofdict objectForKey:@"Rca_comp25"] intValue]];
        [dict setObject:string forKey:@"RCAC025P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAC050P"] intValue]+[[Rowofdict objectForKey:@"Rca_comp50"] intValue]];
        [dict setObject:string forKey:@"RCAC050P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAC075P"] intValue]+[[Rowofdict objectForKey:@"Rca_comp75"] intValue]];
        [dict setObject:string forKey:@"RCAC075P"];
    }
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAA012"] intValue]+[[Rowofdict objectForKey:@"Rca_audio12"] intValue]];
    [dict setObject:string forKey:@"RCAA012"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAA025"] intValue]+[[Rowofdict objectForKey:@"Rca_audio25"] intValue]];
    [dict setObject:string forKey:@"RCAA025"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAA050"] intValue]+[[Rowofdict objectForKey:@"Rca_audio50"] intValue]];
    [dict setObject:string forKey:@"RCAA050"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAA075"] intValue]+[[Rowofdict objectForKey:@"Rca_audio75"] intValue]];
    [dict setObject:string forKey:@"RCAA075"];
    
    if (![[Rowofdict objectForKey:@"Audio35mm_plenum"] isEqualToString:@"Yes"]) {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM015S"] intValue]+[[Rowofdict objectForKey:@"Audio35mm15"] intValue]];
        [dict setObject:string forKey:@"35MM015S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM025S"] intValue]+[[Rowofdict objectForKey:@"Audio35mm25"] intValue]];
        [dict setObject:string forKey:@"35MM025S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM050S"] intValue]+[[Rowofdict objectForKey:@"Audio35mm50"] intValue]];
        [dict setObject:string forKey:@"35MM050S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM075S"] intValue]+[[Rowofdict objectForKey:@"Audio35mm75"] intValue]];
        [dict setObject:string forKey:@"35MM075S"];
    }
    else {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM015P"] intValue]+[[Rowofdict objectForKey:@"Audio35mm15"] intValue]];
        [dict setObject:string forKey:@"35MM015P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM025P"] intValue]+[[Rowofdict objectForKey:@"Audio35mm25"] intValue]];
        [dict setObject:string forKey:@"35MM025P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM050P"] intValue]+[[Rowofdict objectForKey:@"Audio35mm50"] intValue]];
        [dict setObject:string forKey:@"35MM050P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM075P"] intValue]+[[Rowofdict objectForKey:@"Audio35mm75"] intValue]];
        [dict setObject:string forKey:@"35MM075P"];
    }
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"USBAB009"] intValue]+[[Rowofdict objectForKey:@"Usbab9"] intValue]];
    [dict setObject:string forKey:@"USBAB009"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"USBAB015"] intValue]+[[Rowofdict objectForKey:@"Usbab15"] intValue]];
    [dict setObject:string forKey:@"USBAB015"];
    
    if (![[Rowofdict objectForKey:@"Cat5xt_plenum"] isEqualToString:@"Yes"]) {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45025S"] intValue]+[[Rowofdict objectForKey:@"Cat5xt25"] intValue]];
        [dict setObject:string forKey:@"RJ45025S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"CAT5XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt25"] intValue]];
        [dict setObject:string forKey:@"CAT5XT"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45050S"] intValue]+[[Rowofdict objectForKey:@"Cat5xt50"] intValue]];
        [dict setObject:string forKey:@"RJ45050S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"CAT5XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt50"] intValue]];
        [dict setObject:string forKey:@"CAT5XT"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45075S"] intValue]+[[Rowofdict objectForKey:@"Cat5xt75"] intValue]];
        [dict setObject:string forKey:@"RJ45075S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"CAT5XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt75"] intValue]];
        [dict setObject:string forKey:@"CAT5XT"];
    }
    else {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45025P"] intValue]+[[Rowofdict objectForKey:@"Cat5xt25"] intValue]];
        [dict setObject:string forKey:@"RJ45025P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"CAT5XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt25"] intValue]];
        [dict setObject:string forKey:@"CAT5XT"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45050P"] intValue]+[[Rowofdict objectForKey:@"Cat5xt50"] intValue]];
        [dict setObject:string forKey:@"RJ45050P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"CAT5XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt50"] intValue]];
        [dict setObject:string forKey:@"CAT5XT"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45075P"] intValue]+[[Rowofdict objectForKey:@"Cat5xt75"] intValue]];
        [dict setObject:string forKey:@"RJ45075P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"CAT5XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt75"] intValue]];
        [dict setObject:string forKey:@"CAT5XT"];
    }
    
    if (![[Rowofdict objectForKey:@"Cat5xt_sbx800_plenum"] isEqualToString:@"Yes"]) {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45025S"] intValue]+[[Rowofdict objectForKey:@"Cat5xt25For800"] intValue]];
        [dict setObject:string forKey:@"RJ45025S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"SBX800 CAT5-XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt25For800"] intValue]];
        [dict setObject:string forKey:@"SBX800 CAT5-XT"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45050S"] intValue]+[[Rowofdict objectForKey:@"Cat5xt50For800"] intValue]];
        [dict setObject:string forKey:@"RJ45050S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"SBX800 CAT5-XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt50For800"] intValue]];
        [dict setObject:string forKey:@"SBX800 CAT5-XT"];
    }
    else {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45025P"] intValue]+[[Rowofdict objectForKey:@"Cat5xt25For800"] intValue]];
        [dict setObject:string forKey:@"RJ45025P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"SBX800 CAT5-XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt25For800"] intValue]];
        [dict setObject:string forKey:@"SBX800 CAT5-XT"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45050P"] intValue]+[[Rowofdict objectForKey:@"Cat5xt50For800"] intValue]];
        [dict setObject:string forKey:@"RJ45050P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"SBX800 CAT5-XT"] intValue]+[[Rowofdict objectForKey:@"Cat5xt50For800"] intValue]];
        [dict setObject:string forKey:@"SBX800 CAT5-XT"];
    }
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"VS-2M/F6"] intValue]+[[Rowofdict objectForKey:@"Vga_splitter_2port"] intValue]];
    [dict setObject:string forKey:@"VS-2M/F6"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"VS-2M/M6"] intValue]+[[Rowofdict objectForKey:@"Vga_splitter_2portwaudio"] intValue]];
    [dict setObject:string forKey:@"VS-2M/M6"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"VS-4M/F6"] intValue]+[[Rowofdict objectForKey:@"Vga_splitter_4port"] intValue]];
    [dict setObject:string forKey:@"VS-4M/F6"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"VS-4M/M6"] intValue]+[[Rowofdict objectForKey:@"Vga_splitter_4portwaudio"] intValue]];
    [dict setObject:string forKey:@"VS-4M/M6"];
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM006"] intValue]+[[Rowofdict objectForKey:@"Patch_vga6"] intValue]];
    [dict setObject:string forKey:@"HD15MM006"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MM015"] intValue]+[[Rowofdict objectForKey:@"Patch_vga12"] intValue]];
    [dict setObject:string forKey:@"HD15MM015"];
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"USBAB006"] intValue]+[[Rowofdict objectForKey:@"Patch_usbab6"] intValue]];
    [dict setObject:string forKey:@"USBAB006"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"USBAB009"] intValue]+[[Rowofdict objectForKey:@"Patch_usbab9"] intValue]];
    [dict setObject:string forKey:@"USBAB009"];
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI006"] intValue]+[[Rowofdict objectForKey:@"Patch_hdmi6"] intValue]];
    [dict setObject:string forKey:@"HDMI006"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HDMI009"] intValue]+[[Rowofdict objectForKey:@"Patch_hdmi10"] intValue]];
    [dict setObject:string forKey:@"HDMI009"];
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM006"] intValue]+[[Rowofdict objectForKey:@"Patch_audio35mm6"] intValue]];
    [dict setObject:string forKey:@"35MM006"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35MM015S"] intValue]+[[Rowofdict objectForKey:@"Patch_audio35mm15"] intValue]];
    [dict setObject:string forKey:@"35MM015S"];
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45005"] intValue]+[[Rowofdict objectForKey:@"Patch_cat5e5"] intValue]];
    [dict setObject:string forKey:@"RJ45005"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45007"] intValue]+[[Rowofdict objectForKey:@"Patch_cat5e7"] intValue]];
    [dict setObject:string forKey:@"RJ45007"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45010"] intValue]+[[Rowofdict objectForKey:@"Patch_cat5e10"] intValue]];
    [dict setObject:string forKey:@"RJ45010"];
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAV012"] intValue]+[[Rowofdict objectForKey:@"Add_rca_video12"] intValue]];
    [dict setObject:string forKey:@"RCAV012"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAV025"] intValue]+[[Rowofdict objectForKey:@"Add_rca_video25"] intValue]];
    [dict setObject:string forKey:@"RCAV025"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAV050"] intValue]+[[Rowofdict objectForKey:@"Add_rca_video50"] intValue]];
    [dict setObject:string forKey:@"RCAV050"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RCAV075"] intValue]+[[Rowofdict objectForKey:@"Add_rca_video75"] intValue]];
    [dict setObject:string forKey:@"RCAV075"];
    
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35RCAA012"] intValue]+[[Rowofdict objectForKey:@"Add_35rcaaudio12"] intValue]];
    [dict setObject:string forKey:@"35RCAA012"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35RCAA025"] intValue]+[[Rowofdict objectForKey:@"Add_35rcaaudio25"] intValue]];
    [dict setObject:string forKey:@"35RCAA025"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35RCAA050V"] intValue]+[[Rowofdict objectForKey:@"Add_35rcaaudio50"] intValue]];
    [dict setObject:string forKey:@"35RCAA050V"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"35RCAA075V"] intValue]+[[Rowofdict objectForKey:@"Add_35rcaaudio75"] intValue]];
    [dict setObject:string forKey:@"35RCAA075V"];
    
    
    if (![[Rowofdict objectForKey:@"Add_cat5e_plenum"] isEqualToString:@"Yes"]) {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45025S"] intValue]+[[Rowofdict objectForKey:@"Add_cat5e25"] intValue]];
        [dict setObject:string forKey:@"RJ45025S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45050S"] intValue]+[[Rowofdict objectForKey:@"Add_cat5e50"] intValue]];
        [dict setObject:string forKey:@"RJ45050S"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45075S"] intValue]+[[Rowofdict objectForKey:@"Add_cat5e75"] intValue]];
        [dict setObject:string forKey:@"RJ45075S"];
    }
    else {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45025P"] intValue]+[[Rowofdict objectForKey:@"Add_cat5e25"] intValue]];
        [dict setObject:string forKey:@"RJ45025P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45050P"] intValue]+[[Rowofdict objectForKey:@"Add_cat5e50"] intValue]];
        [dict setObject:string forKey:@"RJ45050P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"RJ45075P"] intValue]+[[Rowofdict objectForKey:@"Add_cat5e75"] intValue]];
        [dict setObject:string forKey:@"RJ45075P"];
    }
    if (![[Rowofdict objectForKey:@"Add_vgamf_plenum"] isEqualToString:@"Yes"]) {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MF006"] intValue]+[[Rowofdict objectForKey:@"Add_vgamf6"] intValue]];
        [dict setObject:string forKey:@"HD15MF006"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MF015"] intValue]+[[Rowofdict objectForKey:@"Add_vgamf15"] intValue]];
        [dict setObject:string forKey:@"HD15MF015"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MF025"] intValue]+[[Rowofdict objectForKey:@"Add_vgamf25"] intValue]];
        [dict setObject:string forKey:@"HD15MF025"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MF050"] intValue]+[[Rowofdict objectForKey:@"Add_vgamf50"] intValue]];
        [dict setObject:string forKey:@"HD15MF050"];
    }
    else {
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MF015P"] intValue]+[[Rowofdict objectForKey:@"Add_vgamf15"] intValue]];
        [dict setObject:string forKey:@"HD15MF015P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MF030P"] intValue]+[[Rowofdict objectForKey:@"Add_vgamf25"] intValue]];
        [dict setObject:string forKey:@"HD15MF030P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MF050P"] intValue]+[[Rowofdict objectForKey:@"Add_vgamf50"] intValue]];
        [dict setObject:string forKey:@"HD15MF050P"];
        string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"HD15MF075P"] intValue]+[[Rowofdict objectForKey:@"Add_vgamf75"] intValue]];
        [dict setObject:string forKey:@"HD15MF075P"];
    }
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"VASHDMI2"] intValue]+[[Rowofdict objectForKey:@"Add_hdmisplitter_2port"] intValue]];
    [dict setObject:string forKey:@"VASHDMI2"];
    string = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"USB-XT"] intValue]+[[Rowofdict objectForKey:@"Add_usbxt16"] intValue]];
    [dict setObject:string forKey:@"USB-XT"];
    
    return dict;

}

- (void) localDestToRemoteDestRecursive: (NSArray *) tempArray withIndexNumber: (int) index andDict: (NSArray *) tempArrayDict
{
    
    if (index < 0) {
        [self uploadImages:tempArray];
        //[self remoteSrcToLocalSrc];
        return;
    }
    NSLog(@"uploading .. Room %@, index %d", [[[tempArray objectAtIndex:index] objectAtIndex:2] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], index);
    
    isql *database = [isql initialize];
    
    SqlClient *client =[database databaseConnect];
    
    NSArray *tempRow = [tempArray objectAtIndex:index];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *todayString = [formatter stringFromDate: today];
    
    NSMutableString* queryString = [NSMutableString string];
   
#ifdef testing
    [queryString appendString:@"INSERT INTO [sitesurvey2].[dbo].[ipadSiteSurvey204] VALUES ("];
#else
    [queryString appendString:@"INSERT INTO [sitesurvey].[dbo].[ipadSiteSurvey204] VALUES ("];
#endif
    
    int column_count = [tempRow count];
    
    for (int i = 0; i < column_count; i++) {
        if (i != 103) {
            [queryString appendString: [NSString stringWithFormat:@"'%@',", [[tempRow objectAtIndex:i] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]]];
        }
        else {
            [queryString appendString: [NSString stringWithFormat:@"'%@',", todayString]];
        }
        
    }
    queryString = [NSMutableString stringWithFormat:@"%@)", [queryString substringToIndex:(queryString.length - 1)]];
    
    [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
        //[activityIndicator stopAnimating];
        
        if(query.succeeded){
            [self uploadNewTable:tempArray withIndexNumber:index andDict:tempArrayDict];
        }else{
            
            NSLog(@"%@", query.errorText);  
            //NSLog(@"%@", queryString);
            
            NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Sync failed" forKey:@"index"]; 
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"alertDBError" object:self userInfo:dict];
             
        }
        //NSLog(@"%@", queryString);
        
        //[self localDestToRemoteDestRecursive:tempArray withIndexNumber:(index-1)];
        
        
    }];
    
}

- (NSMutableArray *) queryMenu: (NSString *) query {
    //isql *database = [isql initialize];
    //database.queryCounter++;
    //NSLog(@"%d", database.queryCounter);
    self.menuColumnName = [NSArray arrayWithObjects:@"Xib", @"Name", @"SOR", @"Session", @"Row", @"Cat1", @"Cat2", @"Cat3", @"Number", @"Form", @"Dependency1", @"Dependency2", @"Dependency3", @"Dependency4", @"Dependency5", @"Dependency6", @"Key1", @"Value1", @"Key2", @"Value2", @"Key3", @"Value3", nil];
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    //NSMutableArray *tempArray =  [NSMutableArray array];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            //NSString *selectSQL = [NSString stringWithFormat:@"select * from local_dest order by rowid desc limit 1,1"];
            NSString *selectSQL = [NSString stringWithFormat:@"%@", query];
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    //NSLog(@"fetch a row");
                    NSMutableDictionary *tempRow = [[NSMutableDictionary alloc] init];
                    
                    for (int i = 0; i< sqlite3_column_count(statement); i++) {
                        
                        NSString *tempValue = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i)];
                        
                        //NSString *tempName = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_name(statement, i)]];
                        NSString *tempName = [self.menuColumnName objectAtIndex:i];
                        
                        [tempRow setObject:tempValue forKey:tempName];
                        
                    }                    
                    
                    [returnArray addObject:tempRow];
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));       
        
    }
    @finally {
        sqlite3_close(db);
    }
    return returnArray;
}

- (void) localDestToRemoteDest {
    
    
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *tempArrayDict = [NSMutableArray array];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {	
            
            //NSString *selectSQL = [NSString stringWithFormat:@"select * from local_dest order by rowid desc limit 1,1"];
            NSString *selectSQL = [NSString stringWithFormat:@"select * from local_dest where (sync_time = '' or save_time > sync_time) and [Raceway_part_9] = 'complete' and [Raceway_part_10] != 'onhold';"];
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {                     
                    //NSLog(@"fetch a row");
                    NSMutableArray *tempRow = [NSMutableArray array];
                    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                    int column_count = sqlite3_data_count(statement);
                    for (int i = 0; i< column_count; i++) {
                                              
                        NSString *tempString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i)]];
                        NSString *tempFieldName = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_name(statement, i)]];
                        [tempRow addObject: tempString];
                        [tempDict setObject:tempString forKey:tempFieldName];
                        
                    }                    
                    [tempArray addObject:tempRow];
                    [tempArrayDict addObject:tempDict];
                }        
                
                sqlite3_finalize(statement);
            } 
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
                
            }
        }
        
        
    }
    @catch (NSException *exception) {
         NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Sync failed" forKey:@"index"]; 
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"alertDBError" object:self userInfo:dict]; 
    }
    @finally {        
        sqlite3_close(db);        
    }  
    
    
    //[activityIndicator startAnimating];
    
    [self saveAllPendingUploadPhotoAndPDFToFailList:tempArray];
    [self localDestToRemoteDestRecursive:tempArray withIndexNumber:([tempArray count]-1) andDict: tempArrayDict];
         
}

-(UIImage *)imageWithImage:(UIImage *)imageToCompress scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [imageToCompress drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) uploadImages: (NSArray *) tempArray {
    
    for(int index = 0; index< [tempArray count]; index++)
    {
        NSArray *tempRow = [tempArray objectAtIndex:index];
        
        NSString *thisTeqRep = [tempRow objectAtIndex:8] ;
        NSString *thisActivityNumber = [tempRow objectAtIndex:1];
        
        for (int i = 104; i <= 115; i++) {
            
            if([[tempRow objectAtIndex:i] length] > 10) {
                
                NSString *imageString = [NSString stringWithFormat: @"%@",[tempRow objectAtIndex:i]];
                [self uploadImage:imageString withType:@"jpg" andActivity:thisActivityNumber andTeqRep:thisTeqRep];
            }
        }
        
        if([[tempRow objectAtIndex:132] length] > 10) {
            NSString *imageString = [NSString stringWithFormat: @"%@",[tempRow objectAtIndex:132]];
            [self uploadPDF:imageString withActivity:thisActivityNumber andTeqRep:thisTeqRep];
        }
        
    }
    
    [self selectFailFileList];
}

- (void) saveAllPendingUploadPhotoAndPDFToFailList: (NSArray *) tempArray {
        
    for(int index = 0; index< [tempArray count]; index++)
    {   
        NSArray *tempRow = [tempArray objectAtIndex:index];
      
        NSString *thisTeqRep = [tempRow objectAtIndex:8] ;
        NSString *thisActivityNumber = [tempRow objectAtIndex:1];
       
        for (int i = 104; i <= 115; i++) {
            
            if([[tempRow objectAtIndex:i] length] > 10) {
                
                NSString *imageString = [NSString stringWithFormat: @"%@",[tempRow objectAtIndex:i]];
                [self saveAllPendingUploadPhotoToFailList:imageString withType:@"jpg" andActivity:thisActivityNumber andTeqRep:thisTeqRep];
            }
        }
        
        if([[tempRow objectAtIndex:132] length] > 10) {
            NSString *imageString = [NSString stringWithFormat: @"%@",[tempRow objectAtIndex:132]];
            [self saveAllPendingUploadPDFToFailList:imageString withActivity:thisActivityNumber andTeqRep:thisTeqRep];
        }
                
    }
}

- (void) saveAllPendingUploadPhotoToFailList : (NSString *) imageString withType : (NSString *) type andActivity: (NSString *) activity andTeqRep: (NSString *) teqrep{
    
    UIImage *drawImage = [self loadImage: imageString ofType: type inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    NSData *imageData = UIImageJPEGRepresentation(drawImage, 0.75);
    
    NSString *imageStringWithType = [NSString stringWithFormat:@"%@.%@", imageString, type];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDir stringByAppendingPathComponent:imageStringWithType];
    
    NSError *error;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:imagePath error:&error];
    NSDate *fileDate = [dictionary objectForKey:NSFileModificationDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:fileDate];
    if ([self checkIfFileUploaded:imageStringWithType withDateTime:dateString]) {
        //return YES means it found the same file has been uploaded, stop uploading
        return;
    }
    
    if (imageData == nil) {
        //no image
    }
    else {
        //use imagePath as main id. If file does not exists, it cannot upload anyway.
        [self writeToFailedFileUploadRecords:imagePath withDBName:imageStringWithType andFileType:@"image" andActivity:activity andTeqRep:teqrep];
        NSLog(@"write image to fail log");
    }
}

- (void) uploadSpeedTestFile {
    
    NSString *speedtestFileName = [[NSBundle mainBundle] pathForResource:@"speedtest" ofType:@"png"];
    
    NSData *myData = [NSData dataWithContentsOfFile:speedtestFileName];
    
#ifdef testing
    NSString *urlString = @"http://108.54.230.13/website4/Default.aspx";
#else
    NSString *urlString = @"http://108.54.230.13/website3/Default.aspx";
#endif
    
    // setting up the request object now
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    /*
     add some header info now
     we always need a boundary when we post a file
     also we need to set the content type
     
     You might want to generate a random boundary.. this is just the same
     as my output from wireshark on a valid html post
     */
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    /*
     now lets create the body of the post
     */
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", @"speedtest.png"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:myData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // now lets make the connection to the web
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    float speed = (myData.length/1024)/([NSDate timeIntervalSinceReferenceDate] - startTime);
    TFLog(@"upload speed = %f Kbps", speed);
    //NSLog(@"time elapse = %f",([NSDate timeIntervalSinceReferenceDate] - startTime));
    //NSLog(@"upload speed = %f Kbps",  (myData.length/1024)/([NSDate timeIntervalSinceReferenceDate] - startTime));
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    if ([returnString isEqualToString:@"Success"]) {
        if (speed > 10) {
            //fast enough
            [self localDestToRemoteDest];
        }
        else {
            //alert and give options
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Your internet seems to be slow. Are you sure to sync now?" message: nil delegate:self cancelButtonTitle:@"Sync now" otherButtonTitles: @"Sync later", nil];
            [message show];
        }
    }
    else {
        //alert and stop
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sync error" message: returnString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RefreshRoomList" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //detect slow internet. buttonIndex = 0 means continue to sync, buttonIndex = 1 means stop.
    if (buttonIndex == 0) {
        [self localDestToRemoteDest];
    }
    else {
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RefreshRoomList" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:nil];
    }
}

- (void) saveAllPendingUploadPDFToFailList : (NSString *) pdfString withActivity: (NSString *) activity andTeqRep: (NSString *) teqrep {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDir stringByAppendingPathComponent:pdfString];
    
    NSData *myData = [NSData dataWithContentsOfFile:pdfPath];
    
    NSError *error;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:pdfPath error:&error];
    NSDate *fileDate = [dictionary objectForKey:NSFileModificationDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:fileDate];
    if ([self checkIfFileUploaded:pdfString withDateTime:dateString]) {
        //return YES means it found the same file has been uploaded, stop uploading
        return;
    }
    if (myData == nil) {
        //no image
    }
    else {
        //use pdfPath as main id. If file does not exists, it cannot upload anyway.
        [self writeToFailedFileUploadRecords:pdfPath withDBName:pdfString andFileType:@"pdf" andActivity:activity andTeqRep:teqrep];
        NSLog(@"write pdf to fail log %@", pdfString);
    }
   
}

- (void) uploadImage : (NSString *) imageString withType : (NSString *) type andActivity: (NSString *) activity andTeqRep: (NSString *) teqrep {
    
    UIImage *drawImage = [self loadImage: imageString ofType: type inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    NSData *imageData = UIImageJPEGRepresentation(drawImage, 0.75);
    
    NSError *error;
    NSString *imageStringWithType = [NSString stringWithFormat:@"%@.%@", imageString, type];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDir stringByAppendingPathComponent:imageStringWithType];
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:imagePath error:&error];
    //NSLog(@"%@", error);
    
    NSDate *fileDate = [dictionary objectForKey:NSFileModificationDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:fileDate];
    if ([self checkIfFileUploaded:imageStringWithType withDateTime:dateString]) {
        //return YES means it found the same file has been uploaded, stop uploading
        return;
    }
    if (imageData == nil) {
        //NSLog(@"no image");
    }
    else {
        //use imagePath as main id. If file does not exists, it cannot upload anyway.
        //[self writeToFailedFileUploadRecords:imagePath withDBName:imageStringWithType andFileType:@"image" andActivity:activity andTeqRep:teqrep];
        //NSLog(@"write image to fail log");
        
        imageString = [NSString stringWithFormat:@"%@.%@", imageString, type];
        // setting up the URL to post to
#ifdef testing
        NSString *urlString = @"http://108.54.230.13/website4/Default.aspx";
#else
        NSString *urlString = @"http://108.54.230.13/website3/Default.aspx";
#endif
        
        // setting up the request object now
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        /*
         add some header info now
         we always need a boundary when we post a file
         also we need to set the content type
         
         You might want to generate a random boundary.. this is just the same 
         as my output from wireshark on a valid html post
         */
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        /*
         now lets create the body of the post
         */
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];	
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", imageString] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        // now lets make the connection to the web
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        //NSLog(@"%@",returnString);
        if ([returnString isEqualToString:@"Success"]) {
            //NSLog(@"file return success");
            [self removeFromFailedFileUploadRecords:imagePath];
            NSLog(@"remove image to fail log");
            [self saveFileUploadRecords:imageStringWithType withDateTime:dateString];
        }
        else {
            //NSLog(@"%@", returnString);
            //[self saveFailedFileUploadRecords:imagePath withDBName:imageString andFileType:@"image"];
            NSLog(@"%@ fail", imageString);
        }
    }
}

- (void) uploadPDF : (NSString *) pdfString withActivity: (NSString *) activity andTeqRep: (NSString *) teqrep {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDir stringByAppendingPathComponent:pdfString];
    
    NSError *error;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:pdfPath error:&error];
    NSDate *fileDate = [dictionary objectForKey:NSFileModificationDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:fileDate];
    if ([self checkIfFileUploaded:pdfString withDateTime:dateString]) {
        //return YES means it found the same file has been uploaded, stop uploading
        //NSLog(@"don't upload pdf");
        return;
    }
    //NSLog(@"upload pdf");
    NSData *myData = [NSData dataWithContentsOfFile:pdfPath];
    
    if (myData == nil) {
        //NSLog(@"no image");
    }
    else {
        NSString *zipFileName = [NSString stringWithFormat:@"%@zip", [pdfString substringToIndex:[pdfString length] - 3]];
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* dPath = [paths objectAtIndex:0];
        NSString* zipfile = [dPath stringByAppendingPathComponent:zipFileName];
        ZipArchive* zip = [[ZipArchive alloc] init];
        [zip CreateZipFile2:zipfile];
        [zip addFileToZip:pdfPath newname:pdfString];//zip
        if( ![zip CloseZipFile2] )
        {
            zipfile = @"";
        }
        NSLog(@"The file has been zipped");
        
        //NSString *zipFilePath = [documentsDir stringByAppendingPathComponent:zipFileName];
        //NSData *myZipData = [NSData dataWithContentsOfFile:zipFilePath];
        NSData *myZipData = [NSData dataWithContentsOfFile:zipfile];
        //if zip file is not created, transfer PDF file instead
        NSString *transferFileName = pdfString;
        
        if (myZipData != nil) {
            myData = myZipData;
            transferFileName = zipFileName;
        }
        //use pdfPath as main id. If file does not exists, it cannot upload anyway.
        //[self writeToFailedFileUploadRecords:pdfPath withDBName:pdfString andFileType:@"pdf" andActivity:activity andTeqRep:teqrep];
        //NSLog(@"write pdf to fail log");
        
        // setting up the URL to post to
#ifdef testing
        NSString *urlString = @"http://108.54.230.13/website4/Default.aspx";
#else
        NSString *urlString = @"http://108.54.230.13/website3/Default.aspx";
#endif
        
        // setting up the request object now
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        /*
         add some header info now
         we always need a boundary when we post a file
         also we need to set the content type
         
         You might want to generate a random boundary.. this is just the same
         as my output from wireshark on a valid html post
         */
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        /*
         now lets create the body of the post
         */
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", transferFileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:myData];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        // now lets make the connection to the web
        //NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
       
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
       
        //NSLog(@"time elapse = %f",([NSDate timeIntervalSinceReferenceDate] - startTime));
        //NSLog(@"upload speed = %f Kbps",  (myData.length/1024)/([NSDate timeIntervalSinceReferenceDate] - startTime));
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        //NSLog(@"%@",returnString);
        
        if ([returnString isEqualToString:@"Success"]) {
            //NSLog(@"insert into file upload log");
            [self removeFromFailedFileUploadRecords:pdfPath];
            NSLog(@"remove pdf from fail log %@", pdfString);
            [self saveFileUploadRecords:pdfString withDateTime:dateString];
        }
        else {
            NSLog(@"%@", returnString);
            //[self saveFailedFileUploadRecords:pdfPath withDBName:pdfString andFileType:@"pdf"];
            NSLog(@"%@ fail", pdfString);
        }
        //Remove zip file after uploaded
        if (myZipData != nil) {
            [[NSFileManager defaultManager] removeItemAtPath:zipfile error:&error];
        }
    }
}

- (void) uploadImagesFromFailList: (NSArray *) tempArray {
    
    //upload failed pdf
    for (NSMutableDictionary *dict in tempArray) {
        if ([[dict objectForKey:@"filetype"] isEqualToString:@"pdf"]) {
            [self uploadPDFFromFailList:dict];
        }
    }
    //upload failed image
    for (NSMutableDictionary *dict in tempArray) {
        if ([[dict objectForKey:@"filetype"] isEqualToString:@"image"]) {
            [self uploadImageFromFailList:dict];
        }
    }
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RefreshRoomList" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:nil];
    
    
}

- (void) uploadImageFromFailList : (NSDictionary *) dict {
    
    UIImage *drawImage = [self loadImage:[dict objectForKey:@"dbname"] inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    NSData *imageData = UIImageJPEGRepresentation(drawImage, 0.75);
    
    NSError *error;
    //NSString *imageStringWithType = [NSString stringWithFormat:@"%@.%@", imageString, type];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    //NSString *documentsDir = [paths objectAtIndex:0];
    //NSString *imagePath = [documentsDir stringByAppendingPathComponent:imageStringWithType];
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[dict objectForKey:@"path"] error:&error];
    //NSLog(@"%@", error);
    
    NSDate *fileDate = [dictionary objectForKey:NSFileModificationDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:fileDate];
    /*
    if ([self checkIfFileUploaded:imageStringWithType withDateTime:dateString]) {
        //return YES means it found the same file has been uploaded, stop uploading
        return;
    }
     */
    if (imageData == nil) {
        //NSLog(@"no image");
    }
    else {
        //use imagePath as main id. If file does not exists, it cannot upload anyway.
        /*
        [self writeToFailedFileUploadRecords:imagePath withDBName:imageStringWithType andFileType:@"image" andActivity:activity andTeqRep:teqrep];
        NSLog(@"write image to fail log");
        
        imageString = [NSString stringWithFormat:@"%@.%@", imageString, type];
         */
        // setting up the URL to post to
#ifdef testing
        NSString *urlString = @"http://108.54.230.13/website4/Default.aspx";
#else
        NSString *urlString = @"http://108.54.230.13/website3/Default.aspx";
#endif
        
        // setting up the request object now
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        /*
         add some header info now
         we always need a boundary when we post a file
         also we need to set the content type
         
         You might want to generate a random boundary.. this is just the same
         as my output from wireshark on a valid html post
         */
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        /*
         now lets create the body of the post
         */
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", [dict objectForKey:@"dbname"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        // now lets make the connection to the web
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        //NSLog(@"%@",returnString);
        if ([returnString isEqualToString:@"Success"]) {
            //NSLog(@"file return success");
            [self removeFromFailedFileUploadRecords:[dict objectForKey:@"path"]];
            NSLog(@"remove image to fail log");
            [self saveFileUploadRecords:[dict objectForKey:@"dbname"] withDateTime:dateString];
        }
        else {
            //NSLog(@"%@", returnString);
            //[self saveFailedFileUploadRecords:imagePath withDBName:imageString andFileType:@"image"];
            NSLog(@"%@ fail", [dict objectForKey:@"dbname"]);
        }
    }
}

- (void) uploadPDFFromFailList : (NSDictionary *) dict {
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    //NSString *documentsDir = [paths objectAtIndex:0];
    //NSString *pdfPath = [documentsDir stringByAppendingPathComponent:pdfString];
    
    NSString *pdfPath = [dict objectForKey:@"path"];
    NSError *error;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:pdfPath error:&error];
    NSDate *fileDate = [dictionary objectForKey:NSFileModificationDate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:fileDate];
    /*
    if ([self checkIfFileUploaded:pdfString withDateTime:dateString]) {
        //return YES means it found the same file has been uploaded, stop uploading
        //NSLog(@"don't upload pdf");
        return;
    }
     */
    //NSLog(@"upload pdf");
    NSData *myData = [NSData dataWithContentsOfFile:pdfPath];
    
    if (myData == nil) {
        //NSLog(@"no image");
    }
    else {
        NSString *zipFileName = [NSString stringWithFormat:@"%@zip", [[dict objectForKey:@"dbname"] substringToIndex:[[dict objectForKey:@"dbname"] length] - 3]];
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* dPath = [paths objectAtIndex:0];
        NSString* zipfile = [dPath stringByAppendingPathComponent:zipFileName];
        ZipArchive* zip = [[ZipArchive alloc] init];
        [zip CreateZipFile2:zipfile];
        [zip addFileToZip:pdfPath newname:[dict objectForKey:@"dbname"]];//zip
        if( ![zip CloseZipFile2] )
        {
            zipfile = @"";
        }
        NSLog(@"The file has been zipped");
        
        //NSString *zipFilePath = [dPath stringByAppendingPathComponent:zipFileName];
        //NSData *myZipData = [NSData dataWithContentsOfFile:zipFilePath];
        NSData *myZipData = [NSData dataWithContentsOfFile:zipfile];
        //if zip file is not created, transfer PDF file instead
        NSString *transferFileName = [dict objectForKey:@"dbname"];
        if (myZipData != nil) {
            myData = myZipData;
            transferFileName = zipFileName;
        }
        //use pdfPath as main id. If file does not exists, it cannot upload anyway.
        /*
        [self writeToFailedFileUploadRecords:pdfPath withDBName:pdfString andFileType:@"pdf" andActivity:activity andTeqRep:teqrep];
        NSLog(@"write pdf to fail log");
        */
        // setting up the URL to post to
#ifdef testing
        NSString *urlString = @"http://108.54.230.13/website4/Default.aspx";
#else
        NSString *urlString = @"http://108.54.230.13/website3/Default.aspx";
#endif
        
        // setting up the request object now
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        /*
         add some header info now
         we always need a boundary when we post a file
         also we need to set the content type
         
         You might want to generate a random boundary.. this is just the same
         as my output from wireshark on a valid html post
         */
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        /*
         now lets create the body of the post
         */
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", transferFileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:myData];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        // now lets make the connection to the web
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        //NSLog(@"%@",returnString);
        
        if ([returnString isEqualToString:@"Success"]) {
            //NSLog(@"insert into file upload log");
            [self removeFromFailedFileUploadRecords:[dict objectForKey:@"path"]];
            NSLog(@"remove pdf from fail log");
            [self saveFileUploadRecords:[dict objectForKey:@"dbname"] withDateTime:dateString];
        }
        else {
            NSLog(@"%@", returnString);
            //[self saveFailedFileUploadRecords:pdfPath withDBName:pdfString andFileType:@"pdf"];
            NSLog(@"%@ fail", [dict objectForKey:@"dbname"]);
        }
        //Remove zip file after uploaded
        if (myZipData != nil){
            [[NSFileManager defaultManager] removeItemAtPath:zipfile error:&error];
        }
    }
}

- (void) selectFailFileList {
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    NSMutableArray *failedFiles = [NSMutableArray arrayWithObjects: nil];
    NSString *returnString;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            //NSString *selectSQL = [NSString stringWithFormat:@"select * from local_dest order by rowid desc limit 1,1"];
            NSString *selectSQL = [NSString stringWithFormat:@"select path, dbname, filetype, activity_no, teq_rep from fail_upload_log"];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSMutableDictionary *dict= [NSMutableDictionary dictionary];
                    
                    returnString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                    [dict setObject:returnString forKey:@"path"];
                    
                    returnString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)]];
                    [dict setObject:returnString forKey:@"dbname"];
                    
                    returnString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)]];
                    [dict setObject:returnString forKey:@"filetype"];
                    
                    returnString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)]];
                    [dict setObject:returnString forKey:@"activity_no"];
                    
                    returnString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)]];
                    [dict setObject:returnString forKey:@"teq_rep"];
                    
                    [failedFiles addObject:dict];
                    
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                NSLog(@"%@", selectSQL);
            }
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        [self uploadImagesFromFailList:failedFiles];
    }
    
}

- (BOOL) checkIfFileUploaded : (NSString *) filename withDateTime : (NSString *) saveDateTime {
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    NSString *returnedDateString = @"";
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            //NSString *selectSQL = [NSString stringWithFormat:@"select * from local_dest order by rowid desc limit 1,1"];
            NSString *selectSQL = [NSString stringWithFormat:@"select savetime from upload_file_log where fullname = '%@' order by savetime desc limit 0,1", filename];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                     returnedDateString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                NSLog(@"%@", selectSQL);
            }
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        /*
        if ([returnedDateString isEqualToString:@""]) {
            return NO;
        }
        if (![saveDateTime isEqualToString:returnedDateString]) {
            return NO;
        }
        return YES;
         */
        // new logic to make sure it uploads if exception happens
        if ([returnedDateString length] > 0){
            if([returnedDateString isEqualToString:saveDateTime]){
                return YES;
            }
        }
        return NO;
    }

}

- (void) saveFileUploadRecords : (NSString *) filename withDateTime : (NSString *) saveDateTime  {
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSMutableString* queryString = [NSString stringWithFormat:@"insert into upload_file_log ([fullname], [savetime]) values ('%@', '%@')", filename, saveDateTime];
            
            
            const char *insert_stmt = [queryString UTF8String];
            
            if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    
                } else {
                    //NSLog(@"Insert failed: %s", sqlite3_errmsg(db));
                    
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                NSLog(@"%@", queryString);
            }
            //NSLog(@"%@", queryString);
            
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        NSLog(@"upload %@", filename);
    }
}

- (void) writeToFailedFileUploadRecords : (NSString *) path withDBName : (NSString *) DBName andFileType: (NSString *)filetype andActivity: (NSString *)activity andTeqRep: (NSString *)teqRep  {
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSMutableString* queryString = [NSString stringWithFormat:@"replace into fail_upload_log ([path], [dbname], [filetype], [activity_no], [teq_rep]) values ('%@', '%@' ,'%@' ,'%@' ,'%@')", path, DBName, filetype, activity, teqRep];
            
            
            const char *insert_stmt = [queryString UTF8String];
            
            if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    
                } else {
                    //NSLog(@"Insert failed: %s", sqlite3_errmsg(db));
                    
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                NSLog(@"%@", queryString);
            }
            //NSLog(@"%@", queryString);
            
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
    }
}

- (void) removeFromFailedFileUploadRecords : (NSString *) path {
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSMutableString* queryString = [NSString stringWithFormat:@"delete from fail_upload_log where [path] = '%@'", path];
            
            const char *insert_stmt = [queryString UTF8String];
            
            if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    
                } else {
                    //NSLog(@"Insert failed: %s", sqlite3_errmsg(db));
                    
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                NSLog(@"%@", queryString);
            }
            //NSLog(@"%@", queryString);
            
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
    }
}

- (void) loadVariablesFromLocalDest: (BOOL) loadViews {
    
    isql *database = [isql initialize];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat:@"select * from local_dest where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' and [Room_Number] ='%@';", database.current_activity_no, database.current_teq_rep, database.current_classroom_number];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    int index = 0;
                    
                    unsigned int outCount, i;
                    
                    objc_property_t *properties = class_copyPropertyList([database class], &outCount);
                    for(i = 0; i < outCount; i++) {
                        objc_property_t property = properties[i];
                        const char *propName = property_getName(property);
                        const char *propType = property_getAttributes(property);
                        if(propName) {
                            
                            NSString *propertyName = [NSString stringWithUTF8String:propName];
                            NSString *propertyType = [NSString stringWithUTF8String:propType];
                            if ([[propertyName substringToIndex:8] isEqualToString:@"current_"]) {
                                
                                if ([propertyType rangeOfString:@"NSString"].location != NSNotFound)
                                {
                                    //NSLog(@"NSString");
                                    [database setValue:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, index++)] forKey:propertyName];
                                    
                                }
                                else if ([propertyType rangeOfString:@"NSMutableDictionary"].location != NSNotFound){
                                    //NSLog(@"NSMutableDictionary");
                                    NSString *stringData = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, index++)];
                                    NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
                                    NSError *e = nil;
                                    [database setValue:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e] forKey:propertyName];
                                }
                                else if ([propertyType rangeOfString:@"NSMutableArray"].location != NSNotFound){
                                    //NSLog(@"NSMutableArray");
                                    NSString *temp_array = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, index++)];
                                    if (temp_array.length > 0) {
                                        [database setValue:[[temp_array  componentsSeparatedByString:@", "] mutableCopy] forKey:propertyName];
                                    }
                                    else {
                                        [database setValue:nil forKey:propertyName];
                                    }
                                    
                                }
                                else {
                                    //NSLog(@"other type...");
                                }
                                //skip savetime and synctime after current_general_notes
                                if ([propertyName isEqualToString:@"current_general_notes"]) {
                                    index++;
                                    index++;
                                }
                                
                            }
                        }
                    }
                    free(properties);
                    
                    NSLog(@"loadVariablesFromLocalDest success");
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
            //NSLog(@"%@", selectSQL);
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"loadVariablesFromLocalDest %@", exception);
    }
    @finally {
        sqlite3_close(db);
        
        //NSLog(@"loadVariablesFromLocalDest success");
        if (loadViews == YES) {
            //NSLog(@"%@", database.current_photo_file_directory_1);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"loadSavedViewsFromVariables" object:self userInfo:nil];
        }
        else {
            //duplicate rooms
            
            database.current_classroom_number = database.selected_current_classroom_number;
            database.current_classroom_floor = database.selected_current_classroom_floor;
            database.current_classroom_grade = database.selected_current_classroom_grade;
            database.current_classroom_notes = database.selected_current_classroom_notes;
            
            //database.current_raceway_part_8 = @"notsync";
            database.current_raceway_part_9 = @"incomplete";
            database.current_raceway_part_10 = @"";
            //NSLog(@"%@", database.current_classroom_number);
            //NSLog(@"%@", database.current_projection_availability);
            
            database.current_photo_file_directory_1 = @"";
            database.current_photo_file_directory_2 = @"";
            database.current_photo_file_directory_3 = @"";
            database.current_photo_file_directory_4 = @"";
            database.current_photo_file_directory_5 = @"";
            database.current_photo_file_directory_6 = @"";
            database.current_photo_file_directory_7 = @"";
            database.current_photo_file_directory_8 = @"";
            
            database.current_diagram_file_directory = @"";
            
            if ([database.duplicate_drawing isEqualToString:@"No"]) {
                //database.current_diagram_file_directory = @"";
                database.current_serialized_drawing = @"";
            }
            if ([database.duplicate_notes isEqualToString:@"No"]) {
                database.current_general_notes = @"";
                database.current_internal_notes = @"";
            }
            
            [database saveVariableToLocalDest];
            [database addNumberToAppIcon];
        }
        //NSLog(@"db closed");
    }
    
}

- (void) saveVariableToLocalDest{
    
    isql *database = [isql initialize];
    
    //when loadingViewsFromSavedVariables, do not save any variables
    if (database.loadingViews == 1) {
        return;
    }
    /**************** no activityNo., no date, no location or no classroom_number, won't save***************/
    
    if(database.current_activity_no==nil){
        return;
    }
    if (database.current_date == nil) {
        return;
    }
    if (database.current_location == nil) {
        return;
    }
    if (database.current_classroom_number == nil) {
        //if not room is selected, still update cover page
        [self updateLocalDestForCoverPage];
        return;
    }
    
    
    [self copyDatabaseIfNeeded];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSMutableString* queryString = [NSMutableString string];
            
            [queryString appendString:[NSString stringWithFormat:@"%@", @"replace into local_dest values ("]];
            
            unsigned int outCount, i;
            
            objc_property_t *properties = class_copyPropertyList([database class], &outCount);
            for(i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                const char *propName = property_getName(property);
                const char *propType = property_getAttributes(property);
                if(propName) {
                    
                    NSString *propertyName = [NSString stringWithUTF8String:propName];
                    NSString *propertyType = [NSString stringWithUTF8String:propType];
                    if ([[propertyName substringToIndex:8] isEqualToString:@"current_"]) {
                        
                        if ([propertyType rangeOfString:@"NSString"].location != NSNotFound)
                        {
                             //NSLog(@"NSString");
                            [queryString appendString:[NSString stringWithFormat:@"'%@',",([database valueForKey:propertyName]==nil)?@"":[[database valueForKey:propertyName] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]]];                            
                        }
                        else if ([propertyType rangeOfString:@"NSMutableDictionary"].location != NSNotFound){
                            //NSLog(@"NSMutableDictionary");
                            if ([database valueForKey:propertyName] == nil) {
                                [queryString appendString:@"'',"] ;
                            }
                            else {
                                NSError *error = nil;
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[database valueForKey:propertyName] options:NSJSONWritingPrettyPrinted error:&error];
                                [queryString appendString:[NSString stringWithFormat:@"'%@',",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]]]; 
                            }
                        }
                        else if ([propertyType rangeOfString:@"NSMutableArray"].location != NSNotFound){
                            //NSLog(@"NSMutableArray");
                            [queryString appendString:[NSString stringWithFormat:@"'%@',",([database valueForKey:propertyName]==nil)?@"":[[[database valueForKey:propertyName] componentsJoinedByString:@", "] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]] ];
                            
                        }
                        else {
                            //NSLog(@"other type...");
                        }
                        //insert savetime and synctime after current_general_notes
                        if ([propertyName isEqualToString:@"current_general_notes"]) {
                            NSDate *today = [NSDate date];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                            [queryString appendString:[NSString stringWithFormat:@"'%@',", [formatter stringFromDate: today]]];
                            
                            [queryString appendString:@"'', "];
                        }
                        
                    }
                }
            }
            free(properties);
            
            queryString = [NSMutableString stringWithFormat:@"%@", [queryString substringToIndex:(queryString.length - 1)]];
            [queryString appendString:[NSString stringWithFormat:@"%@", @");"]];
            
            const char *insert_stmt = [queryString UTF8String];
            
            if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"saveVariableToLocalDest success");
                } else {
                    NSLog(@"Insert failed: %s", sqlite3_errmsg(db));
                    
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                NSLog(@"%@", queryString);
            }
            //NSLog(@"%@", queryString);
            
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        [self updateLocalDestForCoverPage];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Saved all changes" forKey:@"datetime"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"displaySaveTime" object:self userInfo:dict];
        
    }
    
}

- (void) updateLocalDestForCoverPage {
    
    isql *database = [isql initialize];
   
    if ([database.current_activity_no length]>0 && [database.current_username length] >0) {
        //completereport
        NSString* fileName = [NSString stringWithFormat:@"SS-%@-%@.PDF", (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_username == nil)? @"":[database.current_username capitalizedString]];
        fileName = [database sanitizeFile:fileName];
        database.current_comlete_pdf_file_name = fileName;
    }
    
    //save date time
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    //update all rooms in the activity if there is anything changed in the cover page, and update [save_time] too.
    //Reserved 1 and Reserved 2 are not subject to change by user
    
    NSString *queryString = 
    [NSString stringWithFormat: @"update local_dest set [Bp_code]='%@' ,[Address]='%@' ,[Sales_Order]='%@' ,[Sales_Quote]='%@' ,[Walk_through_with]='%@' ,[Primary_contact]='%@' ,[Primary_contact_title]='%@' ,[Primary_contact_phone]='%@' ,[Primary_contact_email]='%@' ,[Second_contact]='%@' ,[Second_contact_title]='%@' ,[Second_contact_phone]='%@' ,[Second_contact_email]='%@' ,[Engineer_contact]='%@' ,[Engineer_contact_title]='%@' ,[Engineer_contact_phone]='%@' ,[Engineer_contact_email]='%@' ,[School_hours]='%@' ,[Elevator_available]='%@' ,[Loading_available]='%@' ,[Special_instructions]='%@' ,[Hours_of_install]='%@' ,[Installers_needed]='%@' ,[Save_time]='%@', [Signature_file_directory_1]='%@', [Signature_file_directory_2]='%@', [Signature_file_directory_3]='%@',  [Print_name_1]='%@', [Print_name_2]='%@', [Print_name_3]='%@',  [Title_of_signature_1]='%@', [Agreement_1] ='%@', [Agreement_2] ='%@', [PDF_file_name] ='%@', [Comlete_PDF_file_name] ='%@', [Installation_vans] ='%@', [Latitude] ='%@', [Longitude] ='%@', [Reserved 1] ='%@', [Reserved 2] ='%@' where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' and ([Bp_code] <>'%@' or [Address] <>'%@' or [Sales_Order] <>'%@' or [Sales_Quote] <>'%@' or [Walk_through_with] <>'%@' or [Primary_contact] <>'%@' or [Primary_contact_title] <>'%@' or [Primary_contact_phone] <>'%@' or [Primary_contact_email] <>'%@' or [Second_contact] <>'%@' or [Second_contact_title] <>'%@' or [Second_contact_phone] <>'%@' or [Second_contact_email] <>'%@' or [Engineer_contact] <>'%@' or [Engineer_contact_title] <>'%@' or [Engineer_contact_phone] <>'%@' or [Engineer_contact_email] <>'%@' or [School_hours] <>'%@' or [Elevator_available] <>'%@' or [Loading_available] <>'%@' or [Special_instructions] <>'%@' or [Hours_of_install] <>'%@' or [Installers_needed] <>'%@' or [Signature_file_directory_1] <>'%@'or  [Signature_file_directory_2] <>'%@' or [Signature_file_directory_3] <>'%@' or [Print_name_1] <>'%@' or [Print_name_2] <>'%@' or [Print_name_3] <>'%@'or [Title_of_signature_1] <>'%@' or [Agreement_1] <>'%@'or [Agreement_2] <>'%@'or [PDF_file_name] <>'%@' or [Comlete_PDF_file_name] <>'%@' or [Installation_vans] <>'%@' or [Latitude] <>'%@' or [Longitude] <>'%@' or [Reserved 1] <>'%@' or [Reserved 2] <>'%@');",
     
     (database.current_bp_code==nil)?@"":[database.current_bp_code stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_address==nil)?@"":[database.current_address stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_so==nil)?@"":[database.current_so stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_sq==nil)?@"":[database.current_sq stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_walk_through_with==nil)?@"":[database.current_walk_through_with stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_primary_contact==nil)?@"":[database.current_primary_contact stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_primary_contact_title==nil)?@"":[database.current_primary_contact_title stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_primary_contact_phone==nil)?@"":[database.current_primary_contact_phone stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_primary_contact_email==nil)?@"":[database.current_primary_contact_email stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_second_contact==nil)?@"":[database.current_second_contact stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_second_contact_title==nil)?@"":[database.current_second_contact_title stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_second_contact_phone==nil)?@"":[database.current_second_contact_phone stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_second_contact_email==nil)?@"":[database.current_second_contact_email stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_engineer_contact==nil)?@"":[database.current_engineer_contact stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_engineer_contact_title==nil)?@"":[database.current_engineer_contact_title stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_engineer_contact_phone==nil)?@"":[database.current_engineer_contact_phone stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_engineer_contact_email==nil)?@"":[database.current_engineer_contact_email stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_school_hours==nil)?@"":[database.current_school_hours stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_elevator_available==nil)?@"":[database.current_elevator_available stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_loading_available==nil)?@"":[database.current_loading_available stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_special_instructions==nil)?@"":[database.current_special_instructions stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_hours_of_install==nil)?@"":[database.current_hours_of_install stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_installers_needed==nil)?@"":[database.current_installers_needed stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     [formatter stringFromDate: today],
     
     (database.current_signature_file_directory_1==nil)?@"":[database.current_signature_file_directory_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_signature_file_directory_2==nil)?@"":[database.current_signature_file_directory_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_signature_file_directory_3==nil)?@"":[database.current_signature_file_directory_3 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_print_name_1==nil)?@"":[database.current_print_name_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_print_name_2==nil)?@"":[database.current_print_name_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_print_name_3==nil)?@"":[database.current_print_name_3 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_title_of_signature_1==nil)?@"":[database.current_title_of_signature_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_agreement_1==nil)?@"":[database.current_agreement_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_agreement_2==nil)?@"":[database.current_agreement_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_pdf_file_name==nil)?@"":[database.current_pdf_file_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_comlete_pdf_file_name==nil)?@"":[database.current_comlete_pdf_file_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_installation_vans==nil)?@"":[database.current_installation_vans stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_dest_latitude==nil)?@"":[database.current_dest_latitude stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_dest_longitude==nil)?@"":[database.current_dest_longitude stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_purchasing_agent==nil)?@"":[database.current_purchasing_agent stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_job_name==nil)?@"":[database.current_job_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_activity_no==nil)?@"":[database.current_activity_no stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_teq_rep==nil)?@"":[database.current_teq_rep stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_bp_code==nil)?@"":[database.current_bp_code stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_address==nil)?@"":[database.current_address stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_so==nil)?@"":[database.current_so stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_sq==nil)?@"":[database.current_sq stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_walk_through_with==nil)?@"":[database.current_walk_through_with stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_primary_contact==nil)?@"":[database.current_primary_contact stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_primary_contact_title==nil)?@"":[database.current_primary_contact_title stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_primary_contact_phone==nil)?@"":[database.current_primary_contact_phone stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_primary_contact_email==nil)?@"":[database.current_primary_contact_email stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_second_contact==nil)?@"":[database.current_second_contact stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_second_contact_title==nil)?@"":[database.current_second_contact_title stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_second_contact_phone==nil)?@"":[database.current_second_contact_phone stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_second_contact_email==nil)?@"":[database.current_second_contact_email stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_engineer_contact==nil)?@"":[database.current_engineer_contact stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_engineer_contact_title==nil)?@"":[database.current_engineer_contact_title stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_engineer_contact_phone==nil)?@"":[database.current_engineer_contact_phone stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_engineer_contact_email==nil)?@"":[database.current_engineer_contact_email stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_school_hours==nil)?@"":[database.current_school_hours stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_elevator_available==nil)?@"":[database.current_elevator_available stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_loading_available==nil)?@"":[database.current_loading_available stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_special_instructions==nil)?@"":[database.current_special_instructions stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_hours_of_install==nil)?@"":[database.current_hours_of_install stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_installers_needed==nil)?@"":[database.current_installers_needed stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_signature_file_directory_1==nil)?@"":[database.current_signature_file_directory_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_signature_file_directory_2==nil)?@"":[database.current_signature_file_directory_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_signature_file_directory_3==nil)?@"":[database.current_signature_file_directory_3 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_print_name_1==nil)?@"":[database.current_print_name_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_print_name_2==nil)?@"":[database.current_print_name_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_print_name_3==nil)?@"":[database.current_print_name_3 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_title_of_signature_1==nil)?@"":[database.current_title_of_signature_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_agreement_1==nil)?@"":[database.current_agreement_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_agreement_2==nil)?@"":[database.current_agreement_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_pdf_file_name==nil)?@"":[database.current_pdf_file_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
    
    (database.current_comlete_pdf_file_name==nil)?@"":[database.current_comlete_pdf_file_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
    (database.current_installation_vans==nil)?@"":[database.current_installation_vans stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
    (database.current_dest_latitude==nil)?@"":[database.current_dest_latitude stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
    (database.current_dest_longitude==nil)?@"":[database.current_dest_longitude stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
    (database.current_purchasing_agent==nil)?@"":[database.current_purchasing_agent stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
    (database.current_job_name==nil)?@"":[database.current_job_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"]
     
     ];
    
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {const char *insert_stmt = [queryString UTF8String];
            
            if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"updateLocalDestForCoverPage success");
                } else {
                    NSLog(@"update failed: %s", sqlite3_errmsg(db));                      
                    
                }                            
                sqlite3_finalize(statement);
            } 
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
                NSLog(@"%@", queryString);
            }
            //NSLog(@"%@", queryString);
            
            
        }                
    }
    @catch (NSException *exception) {
        
    }
    @finally {        
        sqlite3_close(db);
    }  

}



-(void)resetVariables {
    
    isql *database = [isql initialize];
    
    database.current_projection_availability = nil;
    
    database.current_new_projection_type = nil;
    
    database.current_existing_projection_type = nil;
    
    database.current_no_projection_type = nil;
    
    database.current_projector_type = nil;
    
    database.current_projector = nil;
    
    database.current_projector_notes = nil;
    
    database.current_existing_board_notes = nil;
    
    database.current_existing_projector_notes = nil;
    
    database.current_existing_CMP_notes = nil;
    
    database.current_projectors_include_mounts = nil;
    
    database.current_smartboard = nil;
    
    database.current_smartboard_other = nil;
    
    database.current_mounting = nil;
    
    database.current_CMP_mounting_location = nil;
    
    database.current_CMP_mounting = nil;
    
    database.current_CMP_poleLength = nil;
    
    database.current_CMP_poleLength_notes = nil;
    
    database.current_mounting_notes = nil;
    
    database.current_CMP_mouting_notes = nil;
    
    database.current_audios = nil;
    
    database.current_audio_notes = nil;
    
    database.current_audio_ceilingSpeakers = nil;
    
    database.current_audio_wallMountedSpeakers = nil;
    
    database.current_audio_includeReceiver = nil;
    
    database.current_peripherals = nil;
    
    database.current_peripherals_others = nil;
    
    database.current_height_of_smartboard = nil;
    
    database.current_height_of_smartboard_classroom_type = nil;
    
    database.current_height_of_smartboard_notes = nil;
    
    database.current_ceiling_height = nil;
    
    database.current_ceiling_structure = nil;
    
    database.current_ceiling_structure_other = nil;
    
    database.current_wall_structure = nil;
    
    database.current_wall_structure_notes = nil;
    
    database.current_wall_structure_board = nil;
    
    database.current_wall_structure_board_notes = nil;
    
    database.current_board = nil;
    
    database.current_client_agrees_to_remove = nil;
    
    database.current_client_agrees_to_remove_other = nil;
    
    database.current_client_will_provide_power = nil;
    
    database.current_client_will_provide_power_notes = nil;
    
    database.draw_button_index = 0;
    
    database.editingNSUrl = nil;
    
    database.current_general_notes = nil;
    /*
     database.current_dest_latitude = nil;
     
     database.current_dest_longitude = nil;
     
     database.src_latitude = nil;
     
     database.src_longitude = nil;
     */
    
    database.current_cable_type = nil;
    
    database.current_cable_type_notes = nil;
    
    database.current_cable_ports = nil;
    
    database.current_usb_length = nil;
    
    database.current_usb_quantity = nil;
    
    database.current_35mm_audio_length = nil;
    
    database.current_35mm_audio_quantity = nil;
    
    database.current_rca_video_length = nil;
    
    database.current_rca_video_quantity = nil;
    
    database.current_rca_audio_length = nil;
    
    database.current_rca_audio_quantity = nil;
    
    database.current_cat5e_length = nil;
    
    database.current_cat5e_quantity = nil;
    
    database.current_add_hdmi = nil;
    
    database.current_hdmi_length = nil;
    
    database.current_hdmi_quantity = nil;
    
    database.current_35mm_to_rca_length = nil;
    
    database.current_35mm_to_rca_quantity = nil;
    
    database.current_182_shield_cable_length = nil;
    
    database.current_182_shield_cable_quantity = nil;
    
    database.current_vga_splitter = nil;
    
    database.current_vga_length = nil;
    
    database.current_vga_quantity = nil;
    
    database.current_rcac_length = nil;
    
    database.current_rcac_quantity = nil;
    
    database.current_cabling_other = nil;
    
    database.current_diagram_file_directory = nil;
    
    database.current_photo_file_directory_1 = nil;
    
    database.current_photo_file_directory_2 = nil;
    
    database.current_photo_file_directory_3 = nil;
    
    database.current_photo_file_directory_4 = nil;
    
    database.current_photo_file_directory_5 = nil;
    
    database.current_photo_file_directory_6 = nil;
    
    database.current_photo_file_directory_7 = nil;
    
    database.current_photo_file_directory_8 = nil;
    
    database.current_serialized_drawing = nil;
    
    database.current_power_within_three_feet = nil;
    
    database.current_existing_cmp_serial = nil;
    
    database.current_existing_cmp_throw_distance = nil;
    
    database.current_existing_cmp_remount = nil;
    
    database.current_audio_ceiling_sensor = nil;
    
    database.current_audio_wall_sensor = nil;
    
    database.current_raceway_part_1 = nil;
    
    database.current_raceway_part_2 = nil;
    
    database.current_raceway_part_3 = nil;
    
    database.current_raceway_part_4 = nil;
    
    database.current_raceway_part_5 = nil;
    
    database.current_raceway_part_6 = nil;
    
    database.current_raceway_part_7 = nil;
    
    database.current_raceway_part_8 = nil;
    
    database.current_raceway_part_9 = nil;
    
    database.current_raceway_part_10 = nil;
    
    database.current_equipment_location_notes = nil;
    database.current_CMP_mounting_other = nil;
    database.current_skip_raceway = nil;
    database.current_skip_ceiling_structure = nil;
    database.current_vgamm6 = nil;
    database.current_vgamm15 = nil;
    database.current_vgamm25 = nil;
    database.current_vgamm35 = nil;
    database.current_vgamm50 = nil;
    database.current_vgamm75 = nil;
    database.current_hdmi10 = nil;
    database.current_hdmi15 = nil;
    database.current_hdmi25 = nil;
    database.current_hdmi50 = nil;
    database.current_hdmi75 = nil;
    database.current_rca_comp12 = nil;
    database.current_rca_comp25 = nil;
    database.current_rca_comp50 = nil;
    database.current_rca_comp75 = nil;
    database.current_rca_audio12 = nil;
    database.current_rca_audio25 = nil;
    database.current_rca_audio50 = nil;
    database.current_rca_audio75 = nil;
    database.current_35audiomm15 = nil;
    database.current_35audiomm25 = nil;
    database.current_35audiomm50 = nil;
    database.current_35audiomm75 = nil;
    database.current_usbab9 = nil;
    database.current_usbab15 = nil;
    database.current_cat5xt25 = nil;
    database.current_cat5xt50 = nil;
    database.current_cat5xt75 = nil;
    database.current_cat5xt25for800s = nil;
    database.current_cat5xt50for800s = nil;
    database.current_cat5xt75for800s = nil;
    database.current_vga_splitter_2port = nil;
    database.current_vga_splitter_2portwaudio = nil;
    database.current_vga_splitter_4port = nil;
    database.current_vga_splitter_4portwaudio = nil;
    database.current_patch_vga6 = nil;
    database.current_patch_vga12 = nil;
    database.current_patch_usbab6 = nil;
    database.current_patch_usbab9 = nil;
    database.current_patch_hdmi6 = nil;
    database.current_patch_hdmi10 = nil;
    database.current_patch_35audiomm6 = nil;
    database.current_patch_35audiomm15 = nil;
    database.current_patch_cat5e5 = nil;
    database.current_patch_cat5e7 = nil;
    database.current_patch_cat5e10 = nil;
    database.current_add_rca_video12 = nil;
    database.current_add_rca_video25 = nil;
    database.current_add_rca_video50 = nil;
    database.current_add_rca_video75 = nil;
    database.current_add_35rcaaudio12 = nil;
    database.current_add_35rcaaudio25 = nil;
    database.current_add_35rcaaudio50 = nil;
    database.current_add_35rcaaudio75 = nil;
    database.current_add_182speakerwire_length = nil;
    database.current_add_182speakerwire = nil;
    database.current_add_cat5e25 = nil;
    database.current_add_cat5e50 = nil;
    database.current_add_cat5e75 = nil;
    database.current_add_cat5e100 = nil;
    database.current_add_vgamf6 = nil;
    database.current_add_vgamf15 = nil;
    database.current_add_vgamf25 = nil;
    database.current_add_vgamf35 = nil;
    database.current_add_vgamf50 = nil;
    database.current_add_vgamf75 = nil;
    database.current_add_hdmisplitter_2port = nil;
    database.current_add_usbxt16 = nil;
    database.current_add_cat5xt25 = nil;
    database.current_add_cat5xt50 = nil;
    database.current_add_cat5xt75 = nil;
    database.current_plenum_rating_required = nil;
    database.current_nyc_cable_bundle = nil;
    
    database.cable_rca_video = nil;
    database.cable_rca_audio = nil;
    database.cable_cat5e = nil;
    database.cable_vgamf = nil;
    database.cable_hdmisplitter = nil;
    database.cable_usbxt = nil;
    
    database.current_custom_build_rail = nil;
    database.current_existing_board_other = nil;
    database.current_vgamm_plenum = nil;
    database.current_hdmi_plenum = nil;
    database.current_rca_comp_plenum = nil;
    database.current_35audiomm_plenum = nil;
    database.current_cat5xt_plenum = nil;
    database.current_cat5xt_sbx800_plenum = nil;
    database.current_add_cat5e_plenum = nil;
    database.current_add_vgamf_plenum = nil;
    
    database.current_speaker = nil;
    database.current_audio_package = nil;
    database.current_audio_accessories = nil;
    database.current_internal_notes = nil;
    database.current_port_desc = nil;
    
    database.current_flat_panel = nil;
    database.current_cork_penetrated = nil;
    database.current_audio_accessories_other = nil;
    database.current_flat_panel_other = nil;
    
    database.current_existing_projector_serial = nil;
    database.current_wall_number = nil;
}

- (void) copyDatabaseIfNeeded {
    
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = self.dbpathString;
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    //success = FALSE;
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ss.sqlite"];
        //[fileManager removeItemAtPath:defaultDBPath error:&error];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success){
            NSLog(@"%@", [error localizedDescription]);
            NSLog(@"not success");
        }else {;
            NSLog(@"db copied");
        }
        
    }
    else {
        //NSLog(@"db don't need to copy");
    }
}


- (NSString *) getDBPath {
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *version = [NSString stringWithFormat:@"ss_v%@.sqlite",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    NSString *dirWithVersion = [documentsDir stringByAppendingPathComponent: version];
    return dirWithVersion;
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]);
    return result;
}

-(UIImage *) loadImage:(NSString *)fileFullName inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", directoryPath, fileFullName]];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]);
    return result;
}

- (void) resetSBMountAudioAfterProjectionChanged 
{
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"resetSBMountAudioTabs" object:self userInfo:nil];
     
}

- (void) resetSBHeight
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"resetSBHeight" object:self userInfo:nil];
}

- (void) revisitWallStructure
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"revisitWallStructure" object:self userInfo:nil];
}

- (void) greyoutMenu: (NSMutableDictionary *)greyoutDict andHightlight:(int)menuNumber {
    
    isql *database = [isql initialize];
    
    NSEnumerator *enumerator = [greyoutDict keyEnumerator];
    id key;
    //[greyoutDict setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:15]];
    
    while ((key = [enumerator nextObject])) {
        NSNumber *value = [greyoutDict objectForKey:key];   
        [database.menu_grey_out replaceObjectAtIndex:[key intValue] withObject:value];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"greyOutMenu" object:self];
    if (database.loadingViews == 1) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:menuNumber] forKey:@"index"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"justHighLight"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
}

- (void) addNumberToAppIcon {
    
    isql *database = [isql initialize];
    [self copyDatabaseIfNeeded];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    int count = [UIApplication sharedApplication].applicationIconBadgeNumber;
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            //NSString *selectSQL = [NSString stringWithFormat:@"select count(*) from local_dest where Save_time > Sync_time and [Teq_rep] like '%%%@%%';", database.current_teq_rep];
            
            //NSString *selectSQL = [NSString stringWithFormat:@"select count(*) from (select count(*) from local_dest where save_time > sync_time and teq_rep like '%%%@%%'group by activity_no)", database.current_teq_rep];
            
            //it counts how many activities have unsynced rooms or outstanding files for the teq representative
            
            NSString *selectSQL = [NSString stringWithFormat:@"select count(*) from (select count(*) from local_dest A left join fail_upload_log B on A.[Activity_no] = B.[Activity_no] and A.[Teq_rep] = B.[Teq_rep] where (A.save_time > A.sync_time or B.path is not null) and A.teq_rep like '%%%@%%'group by A.activity_no)",  database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    count = [[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] intValue];
                   
                }
                //NSLog(@"addNumberToAppIcon success");
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"addNumberToAppIcon prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);  
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    //NSLog(@"Set Icon Numbers");
}

- (NSString *) sanitizeFile: (NSString *)string {

    NSString *temp = [string stringByReplacingOccurrencesOfString:@":" withString:@""];
    return [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void) checkRoomComplete {
    
    isql *database = [isql initialize];
    int result = 1;
    
    if (![[database.room_complete_status objectForKey:@"2"] isEqualToString:@"1"]) result = 0;
    if (![[database.room_complete_status objectForKey:@"3"] isEqualToString:@"1"]) result = 0;
    if (result == 1) {
        database.current_raceway_part_9 = @"complete";
    }
    else {
        database.current_raceway_part_9 = @"incomplete";
    }
    /*
    if (result == 1 && [database.current_raceway_part_10 isEqualToString:@""]) {
        database.current_raceway_part_10 = @"ready";
    }
     */
    //NSLog(@"%@", database.current_raceway_part_9);
}

-(NSString *)escapeString: (NSString *)string{
    return [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}

-(NSString *)removeApostrophe: (NSString *)string{
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@""];
    return [string stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
    
}

- (BOOL) checkActivityExistsInLocalDest: (NSString *)string {
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    [database copyDatabaseIfNeeded];
    
    BOOL flag = NO;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM local_dest WHERE [Activity_no] = '%@' and [Teq_rep] like '%%%@%%';", string, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    
                    if ([[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] intValue] > 0)
                    {
                        flag = YES;
                    }
                }
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        return flag;
    }
}

- (BOOL) checkActivityExistsInLocalSrc: (NSString *)string {
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    [database copyDatabaseIfNeeded];
    
    BOOL flag = NO;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM local_src WHERE [Activity_Number] = '%@' and [Assigned_Name] like '%%%@%%';", string, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    
                    if ([[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] intValue] > 0)
                    {
                        flag = YES;
                    }
                }
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        return flag;
    }
}
@end
