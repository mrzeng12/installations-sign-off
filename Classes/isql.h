//
//  isql.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlClient.h"
#import "SqlClientQuery.h"
#import "SqlResultSet.h"

@interface isql : NSObject {
    NSMutableArray *srcDBArray;
}

+(isql*)initialize;

-(SqlClient *) databaseConnect;

- (NSMutableString *) displayDataFunction: (SqlClientQuery *) query;

- (NSInteger) countDataFunction: (SqlClientQuery *) query;

- (void) loadVariablesFromLocalDest: (BOOL) loadViews;

- (void) remoteSrcToLocalSrc: (BOOL) upload;

- (void) remoteUserToLocalUser;

- (void) localDestToRemoteDest;

- (void) saveVariableToLocalDest;

- (void) updateLocalDestForCoverPage;

- (void) uploadSpeedTestFile;

- (void) localDestToRemoteDestRecursive: (NSArray *) tempArray withIndexNumber: (int) index andDict: (NSArray *) tempArrayDict;

- (NSString *) getDBPath;

- (UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath; 

//- (void) uploadImage : (NSString *) imageString withType : (NSString *) type;

- (BOOL) checkIfFileUploaded : (NSString *) filename withDateTime : (NSString *) saveDateTime;

- (void) saveFileUploadRecords : (NSString *) filename withDateTime : (NSString *) saveDateTime;
    
- (void) copyDatabaseIfNeeded;

- (void) greyoutMenu: (NSMutableDictionary *)greyoutDict andHightlight:(int)menuNumber;

- (void) addNumberToAppIcon;

- (NSString *) sanitizeFile: (NSString *)string;

-(NSString *)escapeString: (NSString *)string;

-(NSString *)removeApostrophe: (NSString *)string;

-(void)resetVariables;

- (void) checkRoomComplete;

- (BOOL) checkActivityExistsInLocalDest: (NSString *)string;

- (BOOL) checkActivityExistsInLocalSrc: (NSString *)string;


@property (nonatomic) int selectedMenu;

@property (strong, nonatomic) NSMutableArray *menu_grey_out;

@property (strong, nonatomic) NSMutableArray *menu_complete;

@property (strong, nonatomic) NSMutableDictionary *observer_flag;

@property (strong, nonatomic) NSString *signature_filename;

@property (strong, nonatomic) NSMutableArray *classrooms_in_one_location;

@property (strong, nonatomic) NSString *editingNSUrl;

@property (strong, nonatomic) NSString *editingPhotoType;

@property (strong, nonatomic) UIImage *editedPhoto;

@property (nonatomic) int loadingViews;

@property ( nonatomic) int editing_flag;

@property (nonatomic) int first_time_load;

@property (nonatomic) BOOL debugMode;

@property (strong, nonatomic) NSString *menuVersion;

@property (strong, nonatomic) NSString *duplicate_drawing;

@property (strong, nonatomic) NSString *duplicate_notes;

@property (strong, nonatomic) NSMutableDictionary *room_complete_status;

@property (strong, nonatomic) NSMutableArray *raceway_parts_description;

@property (strong, nonatomic) NSMutableArray *raceway_parts;

@property (strong, nonatomic) NSMutableArray *raceway_quantity;

@property (strong, nonatomic) NSString *selected_current_classroom_number;

@property (strong, nonatomic) NSString *selected_current_classroom_floor;

@property (strong, nonatomic) NSString *selected_current_classroom_grade;

@property (strong, nonatomic) NSString *selected_current_classroom_notes;

@property (strong, nonatomic) NSMutableArray *menuItems;

@property (strong, nonatomic) NSString *activity_room_count;

@property (strong, nonatomic) NSString *activity_complete_count;

@property (strong, nonatomic) NSString *activity_synced_count;

@property (strong, nonatomic) NSString *activity_failfile_count;

@property (strong, nonatomic) NSString *selected_date;

@property (strong, nonatomic) NSString *selected_location;

@property (strong, nonatomic) NSString *selected_activity_no;

@property (strong, nonatomic) NSString *selected_room_index;

@property (nonatomic,strong) NSMutableDictionary *objectName;

@property (nonatomic,strong) NSMutableDictionary *objectFullName;

@property (nonatomic, strong) NSArray *menuColumnName;

@property (nonatomic, strong) NSString *dbpathString;

@property (strong, nonatomic) NSMutableDictionary *cable_rca_video;

@property (strong, nonatomic) NSMutableDictionary *cable_rca_audio;

@property (strong, nonatomic) NSMutableDictionary *cable_cat5e;

@property (strong, nonatomic) NSMutableDictionary *cable_vgamf;

@property (strong, nonatomic) NSMutableDictionary *cable_hdmisplitter;

@property (strong, nonatomic) NSMutableDictionary *cable_usbxt;

@property (strong, nonatomic) NSString *classroom_index;

@property (strong, nonatomic) NSString *src_latitude;

@property (strong, nonatomic) NSString *src_longitude;

@property (nonatomic) BOOL moveSpiral;

@property (strong, nonatomic) NSString *customDate;

@property (strong, nonatomic) NSString *customLocation;

@property (strong, nonatomic) NSString *customOnthefly;



@property (strong, nonatomic) NSString *current_activity_no;

@property (strong, nonatomic) NSString *current_teq_rep;

@property (strong, nonatomic) NSString *current_bp_code;

@property (strong, nonatomic) NSString *current_location;

@property (strong, nonatomic) NSString *current_district;

@property (strong, nonatomic) NSString *current_primary_contact;

@property (strong, nonatomic) NSString *current_pod;

@property (strong, nonatomic) NSString *current_so;

@property (strong, nonatomic) NSString *current_date;

@property (strong, nonatomic) NSString *current_username;

@property (strong, nonatomic) NSString *current_pdf1;

@property (strong, nonatomic) NSString *current_pdf2;

@property (strong, nonatomic) NSString *current_type_of_work;

@property (strong, nonatomic) NSString *current_job_status;

@property (strong, nonatomic) NSString *current_arrival_time;

@property (strong, nonatomic) NSString *current_departure_time;

@property (strong, nonatomic) NSString *current_reason_for_visit;

@property (strong, nonatomic) NSString *current_agreement_1;

@property (strong, nonatomic) NSString *current_agreement_2;

@property (strong, nonatomic) NSString *current_print_name_1;

@property (strong, nonatomic) NSString *current_print_name_3;

@property (strong, nonatomic) NSString *current_customer_notes;

@property (strong, nonatomic) NSString *current_classroom_number;

@property (strong, nonatomic) NSString *current_classroom_floor;

@property (strong, nonatomic) NSString *current_classroom_grade;

@property (strong, nonatomic) NSString *current_classroom_notes;

@property (strong, nonatomic) NSString *current_installer;

@property (strong, nonatomic) NSString *current_status;

@property (strong, nonatomic) NSString *current_serial_no;

@property (strong, nonatomic) NSString *current_general_notes;

@property (strong, nonatomic) NSString *current_raceway_part_9;

@property (strong, nonatomic) NSString *current_raceway_part_10;

@property (strong, nonatomic) NSString *current_signature_file_directory_1;

@property (strong, nonatomic) NSString *current_signature_file_directory_3;

@property (strong, nonatomic) NSString *current_photo_file_directory_1;

@property (strong, nonatomic) NSString *current_photo_file_directory_2;

@property (strong, nonatomic) NSString *current_photo_file_directory_3;

@property (strong, nonatomic) NSString *current_photo_file_directory_4;

@property (strong, nonatomic) NSString *current_photo_file_directory_5;

@property (strong, nonatomic) NSString *current_photo_file_directory_6;

@property (strong, nonatomic) NSString *current_photo_file_directory_7;

@property (strong, nonatomic) NSString *current_photo_file_directory_8;

@property (strong, nonatomic) NSString *current_comlete_pdf_file_name;

@property (strong, nonatomic) NSString *current_job_summary;    //reserved 1

@property (strong, nonatomic) NSString *current_address;        //reserved 2

@property (strong, nonatomic) NSString *current_address_2;      //reserved 3

@property (strong, nonatomic) NSString *current_use_van_stock;  //reserved 4

@property (strong, nonatomic) NSString *current_van_stock;      //reserved 5

@property (strong, nonatomic) NSString *current_customer_signature_available;   //reserved 6

@property (strong, nonatomic) NSString *current_reserved_7;

@property (strong, nonatomic) NSString *current_reserved_8;

@property (strong, nonatomic) NSString *current_reserved_9;

@property (strong, nonatomic) NSString *current_reserved_10;


@end
