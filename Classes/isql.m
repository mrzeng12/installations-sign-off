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
#import "LGViewHUD.h"
#import "ZipArchive.h"
#import "objc/runtime.h"
#import "TestFlight.h"

//#define testing

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

- (void) remoteSrcToLocalSrc: (BOOL) upload {
    
    [self copyDatabaseIfNeeded];
    
    isql *database = [isql initialize];
    
    SqlClient *client =[database databaseConnect];
    //[activityIndicator startAnimating];
    
    NSMutableString* queryString = [NSMutableString string];
#ifdef testing
    [queryString appendString:[NSString stringWithFormat:@"%@", @"select [Activity Number], [AssignedName], [BP Code], [BP Name], [Business Partner 2], [BP2 Name], [District], [Contact Person], [Contact 2], [POD], [SO], [StartDateTime], [User ID], [File1], [File2], [Address], [BP2 Address], [SOJobName] from [install].[dbo].[IpadInstall_Phoenix]"]];
#else
    [queryString appendString:[NSString stringWithFormat:@"%@", @"select [Activity Number], [AssignedName], [BP Code], [BP Name], [Business Partner 2], [BP2 Name], [District], [Contact Person], [Contact 2], [POD], [SO], [StartDateTime], [User ID], [File1], [File2], [Address], [BP2 Address], [SOJobName] from [install].[dbo].[IpadInstall_Phoenix]"]];
#endif
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
                    NSArray *srcNameArray = [NSArray arrayWithObjects:@"Activity Number", @"AssignedName", @"BP Code", @"BP Name", @"Business Partner 2", @"BP2 Name", @"District", @"Contact Person", @"Contact 2", @"POD", @"SO", @"StartDateTime", @"User ID", @"File1", @"File2", @"Address", @"BP2 Address", @"SOJobName", nil];
                    //destNameArray is the original SQL Server column names in local_src order
                    NSArray *destNameArray = [NSArray arrayWithObjects:@"Activity Number", @"AssignedName", @"BP Code", @"BP Name", @"District", @"Contact Person", @"POD", @"SO", @"StartDateTime", @"User ID", @"File1", @"File2", @"Address", @"SOJobName", nil];
                    //below is insert statement, which use local_src column names and order
                    statement = @"INSERT INTO local_src(Activity_Number, Assigned_Name, BP_Code, BP_Name, District, Contact_Person, POD, SO, StartDateTime, User_ID, File1, File2, [Reserved 1], [Reserved 2]) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";

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
                                [srcDict setObject:[srcDict objectForKey:@"BP2 Address"] forKey:@"Address" ];
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
                               
                [self remoteInstallerToLocalInstaller];
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

- (void) remoteInstallerToLocalInstaller {
    
    [self copyDatabaseIfNeeded];
    
    isql *database = [isql initialize];
    
    SqlClient *client =[database databaseConnect];
    
    NSMutableString* queryString = [NSMutableString string];
    [queryString appendString:[NSString stringWithFormat:@"%@", @"select [Name] from [Install].[dbo].[Installers]"]];
    
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
                    
                    statement = @"delete from local_installers";
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
                    statement = @"INSERT INTO local_installers ([Name]) VALUES (?);";
                    sqlite3_stmt *compiledStatement;
                    
                    if(sqlite3_prepare_v2(masterDB, [statement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
                    {
                        for(int i = 0; i < [srcDBArray count]; i++){
                            NSMutableArray *stringArray = [NSMutableArray array];
                            
                            for (int j = 0; j < 1; j++) {
                                NSString *tempString = [NSString stringWithFormat:@"%@", [[srcDBArray objectAtIndex:i] objectAtIndex:j] ] ;
                                tempString = [tempString stringByReplacingOccurrencesOfString:@"'" withString:@""];
                                [stringArray addObject: tempString];
                                
                            }
                            for (int j = 0; j < 1; j++) {
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
                        NSLog(@"Installer Insert Time Taken: %f",timestampB);
                        
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
                NSLog(@"remoteInstallerToLocalInstaller complete");
                
                [self remoteUserToLocalUser];
            }
            
            
        }else{
            NSLog(@"no network -- remoteInstallerToLocalInstaller fail");
            
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
    
    NSMutableArray *items = [NSMutableArray array];
    NSMutableString* queryString = [NSMutableString string];
        
    NSMutableDictionary *Rowofdict = [tempArrayDict objectAtIndex:index];
    
    NSString *statusString = [Rowofdict objectForKey:@"Status"];
    NSString *serialNoString = [Rowofdict objectForKey:@"Serial_no"];
    NSString *notesString = [Rowofdict objectForKey:@"General_notes"];
    
    NSData *data = [serialNoString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
      
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *todayString = [formatter stringFromDate: today];
        
    NSString *thisTeqRep = [[Rowofdict objectForKey:@"Teq_rep"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *thisActivityNumber = [[Rowofdict objectForKey:@"Activity_no"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *thisRoomNumber = [[Rowofdict objectForKey:@"Room_Number"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *allRooms = [self saveAllRoomsWithActivity:thisActivityNumber andTeqRep:thisTeqRep];
    //insert all items 
    [queryString appendString:@"BEGIN TRANSACTION;"];
#ifdef testing
    NSString *deleteQuery = [NSString stringWithFormat: @"DELETE FROM [DevInstall].[dbo].[InstallSummary] WHERE Activity = '%@' AND RoomNumber = '%@';", thisActivityNumber, thisRoomNumber];
    [queryString appendString: deleteQuery];
    NSString *deleteOtherRoomQuery = [NSString stringWithFormat:@"DELETE FROM [DevInstall].[dbo].[InstallSummary] where Activity = '%@' AND RoomNumber NOT IN %@;", thisActivityNumber, allRooms];
    [queryString appendString: deleteOtherRoomQuery];
#else
    NSString *deleteQuery = [NSString stringWithFormat: @"DELETE FROM [Install].[dbo].[InstallSummary] WHERE Activity = '%@' AND RoomNumber = '%@';", thisActivityNumber, thisRoomNumber];
    [queryString appendString: deleteQuery];
    NSString *deleteOtherRoomQuery = [NSString stringWithFormat:@"DELETE FROM [Install].[dbo].[InstallSummary] where Activity = '%@' AND RoomNumber NOT IN %@;", thisActivityNumber, allRooms];
    [queryString appendString: deleteOtherRoomQuery];
#endif    
    for (NSMutableDictionary *dict in dictArray) {
        NSString *statusCol = statusString;
        NSString *itemtypeCol = [dict objectForKey:@"type"];
        NSString *serialnumberCol = [dict objectForKey:@"serial"];
        NSString *notesCol = notesString;
        
        statusCol = [self escapeString:statusCol];
        itemtypeCol = [self escapeString:itemtypeCol];
        serialnumberCol = [self escapeString:serialnumberCol];
        notesCol = [self escapeString:notesCol];
#ifdef testing
        [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [DevInstall].[dbo].[InstallSummary] ([Activity] ,[RoomNumber], [Status], [ItemType], [SerialNumber], [Notes], [SyncTime]) VALUES ('%@','%@','%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, statusCol, itemtypeCol, serialnumberCol, notesCol,  todayString]];
#else
        [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [Install].[dbo].[InstallSummary] ([Activity] ,[RoomNumber], [Status], [ItemType], [SerialNumber], [Notes], [SyncTime]) VALUES ('%@','%@','%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, statusCol, itemtypeCol, serialnumberCol, notesCol, todayString]];
#endif
       
    }       
    
    NSString *installerString = [Rowofdict objectForKey:@"Installer"];
    items = [[installerString  componentsSeparatedByString:@", "] mutableCopy];
    
#ifdef testing
    deleteQuery = [NSString stringWithFormat: @"DELETE FROM [DevInstall].[dbo].[Installer] WHERE Activity = '%@' AND RoomNumber = '%@';", thisActivityNumber, thisRoomNumber];
    [queryString appendString: deleteQuery];
    deleteOtherRoomQuery = [NSString stringWithFormat:@"DELETE FROM [DevInstall].[dbo].[Installer] where Activity = '%@' AND RoomNumber NOT IN %@;", thisActivityNumber, allRooms];
    [queryString appendString: deleteOtherRoomQuery];
#else
    deleteQuery = [NSString stringWithFormat: @"DELETE FROM [Install].[dbo].[Installer] WHERE Activity = '%@' AND RoomNumber = '%@';", thisActivityNumber, thisRoomNumber];
    [queryString appendString: deleteQuery];
    deleteOtherRoomQuery = [NSString stringWithFormat:@"DELETE FROM [Install].[dbo].[Installer] where Activity = '%@' AND RoomNumber NOT IN %@;", thisActivityNumber, allRooms];
    [queryString appendString: deleteOtherRoomQuery];
#endif
    for (NSString *oneItem in items) {
        
        NSString *installerCol = [self escapeString:oneItem];
#ifdef testing
        [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [DevInstall].[dbo].[Installer]([Activity],[RoomNumber],[Installer],[SyncTime]) VALUES ('%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, installerCol, todayString]];
#else
        [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [Install].[dbo].[Installer]([Activity],[RoomNumber],[Installer],[SyncTime]) VALUES ('%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, installerCol, todayString]];
#endif
    }
    
    NSString *vanStockString = [Rowofdict objectForKey:@"Reserved 5"];
    NSString *useVanStockString = [Rowofdict objectForKey:@"Reserved 4"];
    
    if ([useVanStockString isEqualToString:@"Yes"]) {
        
#ifdef testing
        deleteQuery = [NSString stringWithFormat: @"DELETE FROM [DevInstall].[dbo].[VanStock] WHERE Activity = '%@' AND RoomNumber = '%@';", thisActivityNumber, thisRoomNumber];
        [queryString appendString: deleteQuery];
        deleteOtherRoomQuery = [NSString stringWithFormat:@"DELETE FROM [DevInstall].[dbo].[VanStock] where Activity = '%@' AND RoomNumber NOT IN %@;", thisActivityNumber, allRooms];
        [queryString appendString: deleteOtherRoomQuery];
#else
        deleteQuery = [NSString stringWithFormat: @"DELETE FROM [Install].[dbo].[VanStock] WHERE Activity = '%@' AND RoomNumber = '%@';", thisActivityNumber, thisRoomNumber];
        [queryString appendString: deleteQuery];
        deleteOtherRoomQuery = [NSString stringWithFormat:@"DELETE FROM [Install].[dbo].[VanStock] where Activity = '%@' AND RoomNumber NOT IN %@;", thisActivityNumber, allRooms];
        [queryString appendString: deleteOtherRoomQuery];
#endif
        
        data = [vanStockString dataUsingEncoding:NSUTF8StringEncoding];
        e = nil;
        dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        for (int i = 0; i< [dictArray count]; i++) {
            NSMutableDictionary *dict = [dictArray objectAtIndex:i];
            NSString *installerCol = [dict objectForKey:@"installer"];
            NSString *materialCol = [dict objectForKey:@"material"];
            
            installerCol = [self escapeString:installerCol];
            materialCol = [self escapeString:materialCol];
#ifdef testing
            [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [DevInstall].[dbo].[VanStock]([Activity], [RoomNumber], [Installer], [Material], [SyncTime]) VALUES ('%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, installerCol, materialCol, todayString]];
#else
            [queryString appendString:[NSString stringWithFormat:@"INSERT INTO [Install].[dbo].[VanStock]([Activity], [RoomNumber], [Installer], [Material], [SyncTime]) VALUES ('%@','%@','%@','%@','%@');", thisActivityNumber, thisRoomNumber, installerCol, materialCol, todayString]];
#endif
        }
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

- (void) localDestToRemoteDestRecursive: (NSArray *) tempArray withIndexNumber: (int) index andDict: (NSArray *) tempArrayDict
{
    
    if (index < 0) {
        [self selectFailFileList];
        return;
    }
    NSMutableDictionary *Rowofdict = [tempArrayDict objectAtIndex:index];
    
    NSLog(@"uploading .. Room %@, index %d", [[Rowofdict objectForKey:@"Room_Number"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"], index);
    
    isql *database = [isql initialize];
    
    SqlClient *client =[database databaseConnect];
    
    NSMutableDictionary *dict = [tempArrayDict objectAtIndex:index];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *todayString = [formatter stringFromDate: today];
    
    NSMutableString* queryString = [NSMutableString string];
    
    [queryString appendString:@"BEGIN TRANSACTION;"];
    
#ifdef testing
    NSString *deleteQuery = [NSString stringWithFormat: @"DELETE FROM [DevInstall].[dbo].[InstallCoverSheet] WHERE Activity = '%@';", [dict objectForKey:@"Activity_no"]];
    [queryString appendString:deleteQuery];
    [queryString appendString:@"INSERT INTO [DevInstall].[dbo].[InstallCoverSheet] ([Activity], [Technician], [CardCode], [CardName], [Address], [Address2], [District], [Contact], [Pod], [SO], [PO], [Date], [Username], [File1], [File2], [TypeOfWork], [ArrivalTime], [DepartureTime], [JobSummary], [CustomerSignatureAvailable], [CustomerSignatureName], [CustomerNotes], [TechnicianSignatureName], [FileName], [SyncTime]) VALUES ("];
#else
    NSString *deleteQuery = [NSString stringWithFormat: @"DELETE FROM [Install].[dbo].[InstallCoverSheet] WHERE Activity = '%@';", [dict objectForKey:@"Activity_no"]];
    [queryString appendString:deleteQuery];
    [queryString appendString:@"INSERT INTO [Install].[dbo].[InstallCoverSheet] ([Activity], [Technician], [CardCode], [CardName], [Address], [Address2], [District], [Contact], [Pod], [SO], [PO], [Date], [Username], [File1], [File2], [TypeOfWork], [ArrivalTime], [DepartureTime], [JobSummary], [CustomerSignatureAvailable], [CustomerSignatureName], [CustomerNotes], [TechnicianSignatureName], [FileName], [SyncTime]) VALUES ("];
#endif
    
    NSString *cols = [NSString stringWithFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');",
                      [self escapeString: [dict objectForKey:@"Activity_no"]],
                      [self escapeString: [dict objectForKey:@"Teq_rep"]],
                      [self escapeString: [dict objectForKey:@"Bp_code"]],
                      [self escapeString: [dict objectForKey:@"Location"]],
                      [self escapeString: [dict objectForKey:@"Reserved 2"]],
                      [self escapeString: [dict objectForKey:@"Reserved 3"]],
                      [self escapeString: [dict objectForKey:@"District"]],
                      [self escapeString: [dict objectForKey:@"Primary_contact"]],
                      [self escapeString: [dict objectForKey:@"Pod"]],
                      [self escapeString: [dict objectForKey:@"Sales_Order"]],
                      [self escapeString: [dict objectForKey:@"Reserved 7"]],                      
                      [self escapeString: [dict objectForKey:@"Date"]],
                      [self escapeString: [dict objectForKey:@"Username"]],
                      [self escapeString: [dict objectForKey:@"File1"]],
                      [self escapeString: [dict objectForKey:@"File2"]],
                      [self escapeString: [dict objectForKey:@"Type_of_work"]],
                      [self escapeString: [dict objectForKey:@"Arrival_time"]],
                      [self escapeString: [dict objectForKey:@"Departure_time"]],
                      [self escapeString: [dict objectForKey:@"Reserved 1"]],
                      [self escapeString: [dict objectForKey:@"Reserved 6"]],
                      [self escapeString: [dict objectForKey:@"Print_name_1"]],
                      [self escapeString: [dict objectForKey:@"Customer_notes"]],
                      [self escapeString: [dict objectForKey:@"Print_name_3"]],
                      [self escapeString: [dict objectForKey:@"Comlete_PDF_file_name"]],
                       todayString ];
    
    [queryString appendString:cols];
    [queryString appendString:@"COMMIT TRANSACTION;"];
    [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
        //[activityIndicator stopAnimating];
        
        if(query.succeeded){
            [self uploadNewTable:tempArray withIndexNumber:index andDict:tempArrayDict];
        }else{
            
            NSLog(@"%@", query.errorText);  
            NSLog(@"%@", queryString);
            
            NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Sync failed" forKey:@"index"]; 
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"alertDBError" object:self userInfo:dict];
             
        }
        //NSLog(@"%@", queryString);
        
        //[self localDestToRemoteDestRecursive:tempArray withIndexNumber:(index-1)];
        
        
    }];
    
}

- (void) checkSignature {
    
    isql *database = [isql initialize];
    sqlite3 *db;
    sqlite3_stmt    *statement;
    NSMutableString *tempString = [NSMutableString string];
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            //it does not sync as long as one of the rooms is not complete
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT DISTINCT activity_no FROM local_dest WHERE (sync_time = '' OR save_time > sync_time) AND (Arrival_time = '' OR Departure_time = '' OR Signature_file_directory_3 = '' OR (Signature_file_directory_1 = '' AND [Reserved 6] = 'Yes')) AND Teq_rep = '%@' ORDER BY activity_no", database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *activity = [NSString stringWithFormat:@"%@, ",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                    [tempString appendString:activity];
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
        if ([tempString length] > 0) {
            //some activities missing data, alert, then upload
            NSString *string = [NSString stringWithFormat:@"The following activities are missing \"Arrival Time\", \"Departure Time\" or \"Customer Signature\" or \"Technician Signature\": %@", tempString];
            string = [string substringToIndex:[string length] - 2];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil message: string delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message setTag:0];
            [message show];
        }
        else {
            //no activities missing data, go directly to upload
            [self localDestToRemoteDest];
        }
    }
}

- (void) localDestToRemoteDest {
    
    isql *database = [isql initialize];
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *tempArrayDict = [NSMutableArray array];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [self.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            //it does not sync as long as one of the rooms is not complete
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM local_dest WHERE (sync_time = '' OR save_time > sync_time) AND [Raceway_part_9] = 'complete' AND [Raceway_part_10] != 'onhold' AND Arrival_time != '' AND Departure_time != '' AND Signature_file_directory_3 != '' AND (Signature_file_directory_1 != '' OR [Reserved 6] != 'Yes') AND [Activity_no] NOT IN (SELECT [Activity_no] FROM local_dest WHERE [Raceway_part_9] != 'complete') AND Teq_rep = '%@';", database.current_teq_rep];
            
            //NSString *selectSQL = [NSString stringWithFormat:@"select * from local_dest where (sync_time = '' or save_time > sync_time) and [Raceway_part_9] = 'complete' and [Raceway_part_10] != 'onhold';"];
            //NSString *selectSQL = [NSString stringWithFormat:@"select * from local_dest where (sync_time = '' or save_time > sync_time) and [Raceway_part_10] != 'onhold';"];
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
    [self saveAllPendingUploadPhotoAndPDFToFailList:tempArray];
    [self localDestToRemoteDestRecursive:tempArray withIndexNumber:([tempArray count]-1) andDict: tempArrayDict];
         
}
- (NSString *) saveAllRoomsWithActivity : (NSString *)activity_no andTeqRep: (NSString *) teq_rep{
    isql *database = [isql initialize];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    NSMutableArray *roomList = [NSMutableArray array];
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat:@"select Room_Number from local_dest where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' order by CASE WHEN cast(Room_Number as int) = 0 THEN 9999999999 ELSE cast(Room_Number as int) END, Room_Number;", activity_no, teq_rep];
            
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    [roomList addObject:[[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(statement, 0)]];
                }                
                sqlite3_finalize(statement);
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
        NSMutableString *allRooms = [NSMutableString string];
        for (NSString *room in roomList) {
            NSString *string = [NSString stringWithFormat:@"'%@',", room];
            [allRooms appendString:string];
        }
        if ( [allRooms length] > 0)
            allRooms = [NSMutableString stringWithFormat:@"(%@)", [allRooms substringToIndex:[allRooms length] - 1]];
        return allRooms;
    }
}
- (void) saveAllPendingUploadPhotoAndPDFToFailList: (NSArray *) tempArray {
    
    for(int index = 0; index< [tempArray count]; index++)
    {
        NSArray *tempRow = [tempArray objectAtIndex:index];
        
        NSString *thisTeqRep = [tempRow objectAtIndex:1] ;
        NSString *thisActivityNumber = [tempRow objectAtIndex:0];
        
        if([[tempRow objectAtIndex:44] length] > 10) {
            NSString *imageString = [NSString stringWithFormat: @"%@",[tempRow objectAtIndex:44]];
            [self saveAllPendingUploadPDFToFailList:imageString withActivity:thisActivityNumber andTeqRep:thisTeqRep];
        }
        
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

- (void) uploadImagesFromFailList: (NSArray *) tempArray {
    
    //upload failed pdf
    for (NSMutableDictionary *dict in tempArray) {
        if ([[dict objectForKey:@"filetype"] isEqualToString:@"pdf"]) {
            [self uploadPDFFromFailList:dict];
        }
    }
   
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RefreshRoomList" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:nil];
    
    
}

- (void) uploadPDFFromFailList : (NSDictionary *) dict {
    
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
        NSString *urlString = @"http://108.54.230.13/devinstall/Default.aspx";
#else
        NSString *urlString = @"http://108.54.230.13/install/Default.aspx";
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

- (void) uploadSpeedTestFile {
    
    NSString *speedtestFileName = [[NSBundle mainBundle] pathForResource:@"speedtest" ofType:@"png"];
    
    NSData *myData = [NSData dataWithContentsOfFile:speedtestFileName];
    
#ifdef testing
    NSString *urlString = @"http://108.54.230.13/devinstall/Default.aspx";
#else
    NSString *urlString = @"http://108.54.230.13/install/Default.aspx";
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
            [self checkSignature];
        }
        else {
            //alert and give options
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Your internet seems to be slow. Are you sure to sync now?" message: nil delegate:self cancelButtonTitle:@"Sync now" otherButtonTitles: @"Sync later", nil];
            [message setTag:1];
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
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            [self localDestToRemoteDest];
        }
    }
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [self checkSignature];
        }
        else {
            [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RefreshRoomList" object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LoadFirstPageAfterSync" object:self userInfo:nil];
        }
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
        NSString* fileName = [NSString stringWithFormat:@"IR-%@-%@.PDF", (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_username == nil)? @"":[database.current_username capitalizedString]];
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
    [NSString stringWithFormat: @"update local_dest set [Bp_code]='%@', [Location]='%@', [District]='%@', [Primary_contact]='%@', [Pod]='%@', [Sales_Order]='%@', [Date]='%@', [File1]='%@', [File2]='%@', [Type_of_work]='%@', [Job_status]='%@', [Arrival_time]='%@', [Departure_time]='%@', [Reason_for_visit]='%@', [Agreement_1]='%@', [Agreement_2]='%@',  [Print_name_1]='%@', [Print_name_3]='%@', [Signature_file_directory_1]='%@', [Signature_file_directory_3]='%@', [Comlete_PDF_file_name]='%@', [Reserved 1]='%@', [Customer_notes]='%@', [Reserved 2]='%@', [Reserved 3]='%@', [Reserved 6]='%@', [Reserved 7]='%@', [Save_time]='%@' where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' and ([Bp_code] <>'%@' or [Location] <>'%@' or [District] <>'%@' or [Primary_contact] <>'%@' or [Pod] <>'%@' or [Sales_Order] <>'%@' or [Date] <>'%@' or [File1] <>'%@' or [File2] <>'%@' or [Type_of_work] <>'%@' or [Job_status] <>'%@' or [Arrival_time] <>'%@' or [Departure_time] <>'%@' or [Reason_for_visit] <>'%@' or [Agreement_1] <>'%@' or [Agreement_2] <>'%@' or  [Print_name_1] <>'%@' or [Print_name_3] <>'%@' or [Signature_file_directory_1] <>'%@' or [Signature_file_directory_3] <>'%@' or [Comlete_PDF_file_name] <>'%@' or [Reserved 1] <>'%@' or [Customer_notes] <>'%@' or [Reserved 2] <>'%@' or [Reserved 3] <>'%@' or [Reserved 6] <>'%@' or [Reserved 7] <>'%@');",
     
     (database.current_bp_code==nil)?@"":[database.current_bp_code stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_location==nil)?@"":[database.current_location stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_district==nil)?@"":[database.current_district stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_primary_contact==nil)?@"":[database.current_primary_contact stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_pod==nil)?@"":[database.current_pod stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
          
     (database.current_so==nil)?@"":[database.current_so stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_date==nil)?@"":[database.current_date stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_pdf1==nil)?@"":[database.current_pdf1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_pdf2==nil)?@"":[database.current_pdf2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_type_of_work==nil)?@"":[database.current_type_of_work stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_job_status==nil)?@"":[database.current_job_status stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_arrival_time==nil)?@"":[database.current_arrival_time stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     (database.current_departure_time==nil)?@"":[database.current_departure_time stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_reason_for_visit==nil)?@"":[database.current_reason_for_visit stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_agreement_1==nil)?@"":[database.current_agreement_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_agreement_2==nil)?@"":[database.current_agreement_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_print_name_1==nil)?@"":[database.current_print_name_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_print_name_3==nil)?@"":[database.current_print_name_3 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_signature_file_directory_1==nil)?@"":[database.current_signature_file_directory_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
          
     (database.current_signature_file_directory_3==nil)?@"":[database.current_signature_file_directory_3 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
          
     (database.current_comlete_pdf_file_name==nil)?@"":[database.current_comlete_pdf_file_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_job_summary==nil)?@"":[database.current_job_summary stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_customer_notes==nil)?@"":[database.current_customer_notes stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_address==nil)?@"":[database.current_address stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_address_2==nil)?@"":[database.current_address_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_customer_signature_available==nil)?@"":[database.current_customer_signature_available stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_po==nil)?@"":[database.current_po stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     [formatter stringFromDate: today],
          
     (database.current_activity_no==nil)?@"":[database.current_activity_no stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_teq_rep==nil)?@"":[database.current_teq_rep stringByReplacingOccurrencesOfString:@"'" withString:@"''"],

     //--------again-------
     
     (database.current_bp_code==nil)?@"":[database.current_bp_code stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_location==nil)?@"":[database.current_location stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_district==nil)?@"":[database.current_district stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_primary_contact==nil)?@"":[database.current_primary_contact stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_pod==nil)?@"":[database.current_pod stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_so==nil)?@"":[database.current_so stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_date==nil)?@"":[database.current_date stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_pdf1==nil)?@"":[database.current_pdf1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_pdf2==nil)?@"":[database.current_pdf2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_type_of_work==nil)?@"":[database.current_type_of_work stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_job_status==nil)?@"":[database.current_job_status stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_arrival_time==nil)?@"":[database.current_arrival_time stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     (database.current_departure_time==nil)?@"":[database.current_departure_time stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_reason_for_visit==nil)?@"":[database.current_reason_for_visit stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_agreement_1==nil)?@"":[database.current_agreement_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_agreement_2==nil)?@"":[database.current_agreement_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_print_name_1==nil)?@"":[database.current_print_name_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_print_name_3==nil)?@"":[database.current_print_name_3 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_signature_file_directory_1==nil)?@"":[database.current_signature_file_directory_1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_signature_file_directory_3==nil)?@"":[database.current_signature_file_directory_3 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_comlete_pdf_file_name==nil)?@"":[database.current_comlete_pdf_file_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_job_summary==nil)?@"":[database.current_job_summary stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_customer_notes==nil)?@"":[database.current_customer_notes stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_address==nil)?@"":[database.current_address stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_address_2==nil)?@"":[database.current_address_2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_customer_signature_available==nil)?@"":[database.current_customer_signature_available stringByReplacingOccurrencesOfString:@"'" withString:@"''"],
     
     (database.current_po==nil)?@"":[database.current_po stringByReplacingOccurrencesOfString:@"'" withString:@"''"]
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
    
    database.editingNSUrl = nil;
    
    database.current_installer = nil;
    
    database.current_status = nil;
    
    database.current_serial_no = nil;
    
    database.current_general_notes = nil;
    
    database.current_use_van_stock = nil;
    
    database.current_van_stock = nil;
            
    database.current_photo_file_directory_1 = nil;
    
    database.current_photo_file_directory_2 = nil;
    
    database.current_photo_file_directory_3 = nil;
    
    database.current_photo_file_directory_4 = nil;
    
    database.current_photo_file_directory_5 = nil;
    
    database.current_photo_file_directory_6 = nil;
    
    database.current_photo_file_directory_7 = nil;
    
    database.current_photo_file_directory_8 = nil;
        
    database.current_raceway_part_9 = nil;
    
    database.current_raceway_part_10 = nil;
    
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
        NSLog(@"comp");
    }
    else {
        database.current_raceway_part_9 = @"incomplete";
        NSLog(@"incomp");
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
