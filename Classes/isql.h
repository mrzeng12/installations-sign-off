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

- (void) checkLatestVersion;

- (void) remoteSrcToLocalSrc: (BOOL) upload;

- (void) remoteMenuToLocalMenu;

- (void) remoteUserToLocalUser;

- (void) localDestToRemoteDest;

- (void) saveVariableToLocalDest;

- (void) updateLocalDestForCoverPage;

- (void) uploadSpeedTestFile;

- (void) localDestToRemoteDestRecursive: (NSArray *) tempArray withIndexNumber: (int) index andDict: (NSArray *) tempArrayDict;

- (NSString *) getDBPath;

- (void) uploadImages: (NSArray *) tempArray;

- (UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath; 

//- (void) uploadImage : (NSString *) imageString withType : (NSString *) type;

- (void) uploadImage : (NSString *) imageString withType : (NSString *) type andActivity: (NSString *) activity andTeqRep: (NSString *) teqrep;

- (BOOL) checkIfFileUploaded : (NSString *) filename withDateTime : (NSString *) saveDateTime;

- (void) saveFileUploadRecords : (NSString *) filename withDateTime : (NSString *) saveDateTime;
    
- (void) resetSBMountAudioAfterProjectionChanged;

- (void) resetSBHeight;

- (void) revisitWallStructure;

- (void) copyDatabaseIfNeeded;

- (void) greyoutMenu: (NSMutableDictionary *)greyoutDict andHightlight:(int)menuNumber;

- (void) addNumberToAppIcon;

- (NSString *) sanitizeFile: (NSString *)string;

- (NSMutableDictionary *) outputCableDictFromRawData : (NSMutableDictionary *) Rowofdict;
//- (void) updateLocalDestForSummary;

- (NSMutableArray *) queryMenu: (NSString *) query;

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

@property (nonatomic) int draw_button_index;

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



@property (strong, nonatomic) NSString *current_username;

@property (strong, nonatomic) NSString *current_activity_no;

@property (strong, nonatomic) NSString *current_classroom_number;

@property (strong, nonatomic) NSString *current_classroom_floor;

@property (strong, nonatomic) NSString *current_classroom_notes;

@property (strong, nonatomic) NSString *current_location;

@property (strong, nonatomic) NSString *current_bp_code;

@property (strong, nonatomic) NSString *current_address;

@property (strong, nonatomic) NSString *current_teq_rep;

@property (strong, nonatomic) NSString *current_date;

@property (strong, nonatomic) NSString *current_so;

@property (strong, nonatomic) NSString *current_sq;

@property (strong, nonatomic) NSString *current_walk_through_with;

@property (strong, nonatomic) NSString *current_primary_contact;

@property (strong, nonatomic) NSString *current_primary_contact_title;

@property (strong, nonatomic) NSString *current_primary_contact_phone;

@property (strong, nonatomic) NSString *current_primary_contact_email;

@property (strong, nonatomic) NSString *current_second_contact;

@property (strong, nonatomic) NSString *current_second_contact_title;

@property (strong, nonatomic) NSString *current_second_contact_phone;

@property (strong, nonatomic) NSString *current_second_contact_email;

@property (strong, nonatomic) NSString *current_engineer_contact;

@property (strong, nonatomic) NSString *current_engineer_contact_title;

@property (strong, nonatomic) NSString *current_engineer_contact_phone;

@property (strong, nonatomic) NSString *current_engineer_contact_email;

@property (strong, nonatomic) NSString *current_school_hours;

@property (strong, nonatomic) NSString *current_elevator_available;

@property (strong, nonatomic) NSString *current_loading_available;

@property (strong, nonatomic) NSString *current_special_instructions;

@property (strong, nonatomic) NSString *current_hours_of_install;

@property (strong, nonatomic) NSString *current_installers_needed;

@property (strong, nonatomic) NSString *current_projection_availability;

@property (strong, nonatomic) NSString *current_new_projection_type;

@property (strong, nonatomic) NSString *current_existing_projection_type;

@property (strong, nonatomic) NSString *current_no_projection_type;

@property (strong, nonatomic) NSString *current_projector_type;

@property (strong, nonatomic) NSString *current_projector;

@property (strong, nonatomic) NSString *current_projector_notes;

@property (strong, nonatomic) NSString *current_existing_board_notes;

@property (strong, nonatomic) NSString *current_existing_projector_notes;

@property (strong, nonatomic) NSString *current_existing_CMP_notes;

@property (strong, nonatomic) NSString *current_projectors_include_mounts;

@property (strong, nonatomic) NSString *current_smartboard;

@property (strong, nonatomic) NSString *current_smartboard_other;

@property (strong, nonatomic) NSMutableDictionary *current_mounting;

@property (strong, nonatomic) NSString *current_CMP_mounting_location;

@property (strong, nonatomic) NSMutableDictionary *current_CMP_mounting;

@property (strong, nonatomic) NSString *current_CMP_poleLength;

@property (strong, nonatomic) NSString *current_CMP_poleLength_notes;

@property (strong, nonatomic) NSString *current_audios;

@property (strong, nonatomic) NSString *current_audio_notes;

@property (strong, nonatomic) NSString *current_audio_ceilingSpeakers;

@property (strong, nonatomic) NSString *current_audio_wallMountedSpeakers;

@property (strong, nonatomic) NSString *current_audio_includeReceiver;

@property (strong, nonatomic) NSString *current_cable_type;

@property (strong, nonatomic) NSString *current_cable_type_notes;

@property (strong, nonatomic) NSString *current_cable_ports;

@property (strong, nonatomic) NSString *current_purchasing_agent;

@property (strong, nonatomic) NSString *current_job_name;

@property (strong, nonatomic) NSString *current_inventory_existing_equip;

@property (strong, nonatomic) NSString *current_onthefly_activity;

@property (strong, nonatomic) NSString *current_usb_length;

@property (strong, nonatomic) NSString *current_usb_quantity;

@property (strong, nonatomic) NSString *current_35mm_audio_length;

@property (strong, nonatomic) NSString *current_35mm_audio_quantity;

@property (strong, nonatomic) NSString *current_rca_video_length;

@property (strong, nonatomic) NSString *current_rca_video_quantity;

@property (strong, nonatomic) NSString *current_rca_audio_length;

@property (strong, nonatomic) NSString *current_rca_audio_quantity;

@property (strong, nonatomic) NSString *current_cat5e_length;

@property (strong, nonatomic) NSString *current_cat5e_quantity;

@property (strong, nonatomic) NSString *current_add_hdmi;

@property (strong, nonatomic) NSString *current_hdmi_length;

@property (strong, nonatomic) NSString *current_hdmi_quantity;

@property (strong, nonatomic) NSString *current_35mm_to_rca_length;

@property (strong, nonatomic) NSString *current_35mm_to_rca_quantity;

@property (strong, nonatomic) NSString *current_182_shield_cable_length;

@property (strong, nonatomic) NSString *current_182_shield_cable_quantity;

@property (strong, nonatomic) NSString *current_vga_splitter;

@property (strong, nonatomic) NSString *current_vga_length;

@property (strong, nonatomic) NSString *current_vga_quantity;

@property (strong, nonatomic) NSString *current_rcac_length;

@property (strong, nonatomic) NSString *current_rcac_quantity;

@property (strong, nonatomic) NSString *current_cabling_other;

@property (strong, nonatomic) NSMutableArray *current_peripherals;

@property (strong, nonatomic) NSString *current_peripherals_others;

@property (strong, nonatomic) NSString *current_height_of_smartboard;

@property (strong, nonatomic) NSString *current_height_of_smartboard_classroom_type;

@property (strong, nonatomic) NSString *current_height_of_smartboard_notes;

@property (strong, nonatomic) NSString *current_ceiling_height;

@property (strong, nonatomic) NSMutableArray *current_ceiling_structure;

@property (strong, nonatomic) NSString *current_ceiling_structure_other;

@property (strong, nonatomic) NSString *current_wall_structure;

@property (strong, nonatomic) NSString *current_wall_structure_notes;

@property (strong, nonatomic) NSString *current_wall_structure_board;

@property (strong, nonatomic) NSString *current_wall_structure_board_notes;

@property (strong, nonatomic) NSString *current_board;

@property (strong, nonatomic) NSMutableArray *current_client_agrees_to_remove;

@property (strong, nonatomic) NSString *current_client_agrees_to_remove_other;

@property (strong, nonatomic) NSString *current_client_will_provide_power;

@property (strong, nonatomic) NSString *current_client_will_provide_power_notes;

@property (strong, nonatomic) NSString *current_general_notes;

@property (strong, nonatomic) NSString *current_signature_file_directory_1;

@property (strong, nonatomic) NSString *current_signature_file_directory_2;

@property (strong, nonatomic) NSString *current_signature_file_directory_3;

@property (strong, nonatomic) NSString *current_diagram_file_directory;

@property (strong, nonatomic) NSString *current_photo_file_directory_1;

@property (strong, nonatomic) NSString *current_photo_file_directory_2;

@property (strong, nonatomic) NSString *current_photo_file_directory_3;

@property (strong, nonatomic) NSString *current_photo_file_directory_4;

@property (strong, nonatomic) NSString *current_photo_file_directory_5;

@property (strong, nonatomic) NSString *current_photo_file_directory_6;

@property (strong, nonatomic) NSString *current_photo_file_directory_7;

@property (strong, nonatomic) NSString *current_photo_file_directory_8;

@property (strong, nonatomic) NSString *current_print_name_1;

@property (strong, nonatomic) NSString *current_print_name_2;

@property (strong, nonatomic) NSString *current_print_name_3;

@property (strong, nonatomic) NSString *current_power_within_three_feet;

@property (strong, nonatomic) NSString *current_classroom_grade;

@property (strong, nonatomic) NSString *current_title_of_signature_1;

@property (strong, nonatomic) NSString *current_existing_cmp_serial;

@property (strong, nonatomic) NSString *current_existing_cmp_throw_distance;

@property (strong, nonatomic) NSString *current_existing_cmp_remount;

@property (strong, nonatomic) NSString *current_mounting_notes;

@property (strong, nonatomic) NSString *current_CMP_mouting_notes;

@property (strong, nonatomic) NSString *current_audio_ceiling_sensor;

@property (strong, nonatomic) NSString *current_audio_wall_sensor;

@property (strong, nonatomic) NSString *current_agreement_1;

@property (strong, nonatomic) NSString *current_agreement_2;

@property (strong, nonatomic) NSString *current_pdf_file_name;

@property (strong, nonatomic) NSString *current_comlete_pdf_file_name;

@property (strong, nonatomic) NSString *current_serialized_drawing;

@property (strong, nonatomic) NSString *current_raceway_part_1;

@property (strong, nonatomic) NSString *current_raceway_part_2;

@property (strong, nonatomic) NSString *current_raceway_part_3;

@property (strong, nonatomic) NSString *current_raceway_part_4;

@property (strong, nonatomic) NSString *current_raceway_part_5;

@property (strong, nonatomic) NSString *current_raceway_part_6;

@property (strong, nonatomic) NSString *current_raceway_part_7;

@property (strong, nonatomic) NSString *current_raceway_part_8;

@property (strong, nonatomic) NSString *current_raceway_part_9;

@property (strong, nonatomic) NSString *current_raceway_part_10;

@property (strong, nonatomic) NSString *current_equipment_location_notes;

@property (strong, nonatomic) NSString *current_CMP_mounting_other;

@property (strong, nonatomic) NSString *current_skip_raceway;

@property (strong, nonatomic) NSString *current_skip_ceiling_structure;

@property (strong, nonatomic) NSString *current_raceway_total_length;

@property (strong, nonatomic) NSString *current_raceway_pieces_of_eight_feet;

@property (strong, nonatomic) NSString *current_vgamm6;

@property (strong, nonatomic) NSString *current_vgamm15;

@property (strong, nonatomic) NSString *current_vgamm25;

@property (strong, nonatomic) NSString *current_vgamm35;

@property (strong, nonatomic) NSString *current_vgamm50;

@property (strong, nonatomic) NSString *current_vgamm75;

@property (strong, nonatomic) NSString *current_hdmi10;

@property (strong, nonatomic) NSString *current_hdmi15;

@property (strong, nonatomic) NSString *current_hdmi25;

@property (strong, nonatomic) NSString *current_hdmi50;

@property (strong, nonatomic) NSString *current_hdmi75;

@property (strong, nonatomic) NSString *current_rca_comp12;

@property (strong, nonatomic) NSString *current_rca_comp25;

@property (strong, nonatomic) NSString *current_rca_comp50;

@property (strong, nonatomic) NSString *current_rca_comp75;

@property (strong, nonatomic) NSString *current_rca_audio12;

@property (strong, nonatomic) NSString *current_rca_audio25;

@property (strong, nonatomic) NSString *current_rca_audio50;

@property (strong, nonatomic) NSString *current_rca_audio75;

@property (strong, nonatomic) NSString *current_35audiomm15;

@property (strong, nonatomic) NSString *current_35audiomm25;

@property (strong, nonatomic) NSString *current_35audiomm50;

@property (strong, nonatomic) NSString *current_35audiomm75;

@property (strong, nonatomic) NSString *current_usbab9;

@property (strong, nonatomic) NSString *current_usbab15;

@property (strong, nonatomic) NSString *current_cat5xt25;

@property (strong, nonatomic) NSString *current_cat5xt50;

@property (strong, nonatomic) NSString *current_cat5xt75;

@property (strong, nonatomic) NSString *current_vga_splitter_2port;

@property (strong, nonatomic) NSString *current_vga_splitter_2portwaudio;

@property (strong, nonatomic) NSString *current_vga_splitter_4port;

@property (strong, nonatomic) NSString *current_vga_splitter_4portwaudio;

@property (strong, nonatomic) NSString *current_patch_vga6;

@property (strong, nonatomic) NSString *current_patch_vga12;

@property (strong, nonatomic) NSString *current_patch_usbab6;

@property (strong, nonatomic) NSString *current_patch_usbab9;

@property (strong, nonatomic) NSString *current_patch_hdmi6;

@property (strong, nonatomic) NSString *current_patch_hdmi10;

@property (strong, nonatomic) NSString *current_patch_35audiomm6;

@property (strong, nonatomic) NSString *current_patch_35audiomm15;

@property (strong, nonatomic) NSString *current_patch_cat5e5;

@property (strong, nonatomic) NSString *current_patch_cat5e7;

@property (strong, nonatomic) NSString *current_patch_cat5e10;

@property (strong, nonatomic) NSString *current_add_rca_video12;

@property (strong, nonatomic) NSString *current_add_rca_video25;

@property (strong, nonatomic) NSString *current_add_rca_video50;

@property (strong, nonatomic) NSString *current_add_rca_video75;

@property (strong, nonatomic) NSString *current_add_35rcaaudio12;

@property (strong, nonatomic) NSString *current_add_35rcaaudio25;

@property (strong, nonatomic) NSString *current_add_35rcaaudio50;

@property (strong, nonatomic) NSString *current_add_35rcaaudio75;

@property (strong, nonatomic) NSString *current_add_182speakerwire_length;

@property (strong, nonatomic) NSString *current_add_182speakerwire;

@property (strong, nonatomic) NSString *current_add_cat5e25;

@property (strong, nonatomic) NSString *current_add_cat5e50;

@property (strong, nonatomic) NSString *current_add_cat5e75;

@property (strong, nonatomic) NSString *current_add_cat5e100;

@property (strong, nonatomic) NSString *current_add_vgamf6;

@property (strong, nonatomic) NSString *current_add_vgamf15;

@property (strong, nonatomic) NSString *current_add_vgamf25;

@property (strong, nonatomic) NSString *current_add_vgamf35;

@property (strong, nonatomic) NSString *current_add_vgamf50;

@property (strong, nonatomic) NSString *current_add_vgamf75;

@property (strong, nonatomic) NSString *current_add_hdmisplitter_2port;

@property (strong, nonatomic) NSString *current_add_usbxt16;

@property (strong, nonatomic) NSString *current_add_cat5xt25;

@property (strong, nonatomic) NSString *current_add_cat5xt50;

@property (strong, nonatomic) NSString *current_add_cat5xt75;

@property (strong, nonatomic) NSString *current_plenum_rating_required;

@property (strong, nonatomic) NSString *current_nyc_cable_bundle;

@property (strong, nonatomic) NSString *current_custom_build_rail;

@property (strong, nonatomic) NSString *current_existing_board_other;

@property (strong, nonatomic) NSString *current_vgamm_plenum;

@property (strong, nonatomic) NSString *current_hdmi_plenum;

@property (strong, nonatomic) NSString *current_rca_comp_plenum;

@property (strong, nonatomic) NSString *current_35audiomm_plenum;

@property (strong, nonatomic) NSString *current_cat5xt_plenum;

@property (strong, nonatomic) NSString *current_cat5xt_sbx800_plenum;

@property (strong, nonatomic) NSString *current_add_cat5e_plenum;

@property (strong, nonatomic) NSString *current_add_vgamf_plenum;

@property (strong, nonatomic) NSMutableDictionary *current_speaker;

@property (strong, nonatomic) NSString *current_audio_package;

@property (strong, nonatomic) NSMutableArray *current_audio_accessories;

@property (strong, nonatomic) NSString *current_internal_notes;

@property (strong, nonatomic) NSString *current_port_desc;

@property (strong, nonatomic) NSString *current_cat5xt25for800s;

@property (strong, nonatomic) NSString *current_cat5xt50for800s;

@property (strong, nonatomic) NSString *current_cat5xt75for800s;

@property (strong, nonatomic) NSString *current_flat_panel;

@property (strong, nonatomic) NSString *current_cork_penetrated;

@property (strong, nonatomic) NSString *current_audio_accessories_other;

@property (strong, nonatomic) NSString *current_flat_panel_other;

@property (strong, nonatomic) NSString *current_installation_vans;

@property (strong, nonatomic) NSString *current_existing_projector_serial;

@property (strong, nonatomic) NSString *current_dest_latitude;

@property (strong, nonatomic) NSString *current_dest_longitude;

@property (strong, nonatomic) NSString *current_wall_number;


@end
