//
//  CompletePDFRenderer.h
//  Site Survey
//
//  Created by Helpdesk on 8/23/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CompletePDFRenderer : NSObject {
    
    float factor;
    NSString *normalFont;
    NSString *boldFont;
    /*** Variables group 1 ***/
    NSMutableArray *classroom_number;
    NSMutableArray *classroom_floor;
    NSMutableArray *classroom_grade;
    NSMutableArray *classroom_notes;
    NSMutableArray *smartboard;
    NSMutableArray *smartboard_other;
    NSMutableArray *projector;
    NSMutableArray *projector_type;
    NSMutableArray *projector_notes;
    NSMutableArray *mounting;
    NSMutableArray *mounting_notes;
    NSMutableArray *CMP_mounting;
    NSMutableArray *CMP_mouting_notes;
    
    NSMutableArray *audios;
    NSMutableArray *audio_notes;
    NSMutableArray *audio_ceilingSpeakers;
    NSMutableArray *audio_wallMountedSpeakers;
    NSMutableArray *audio_includeReceiver;
    NSMutableArray *audio_ceiling_sensor;
    NSMutableArray *audio_wall_sensor;
    
    NSMutableArray *cable_type;
    NSMutableArray *cable_type_notes;
    NSMutableArray *peripherals;
    NSMutableArray *peripherals_others;
    
    NSMutableArray *client_agrees_to_remove;
    NSMutableArray *client_agrees_to_remove_other;
    NSMutableArray *client_will_provide_power;
    NSMutableArray *client_will_provide_power_notes;
    NSMutableArray *power_within_three_feet;
    
    NSMutableArray *general_notes;
    NSMutableArray *diagram_file_directory;
    
    NSMutableArray *Cables_other;
    
    /*** Variables group 2 ***/
    
    NSMutableArray *Projection_availability;
    NSMutableArray *New_projection_type;
    NSMutableArray *Existing_projection_type;
    NSMutableArray *No_projection_type;
    
    NSMutableArray *Existing_board_notes;
    NSMutableArray *Existing_projector_notes;
    NSMutableArray *Projectors_include_mounts;
    
    NSMutableArray *Existing_cmp_notes;
    NSMutableArray *Existing_projector_serial;
    NSMutableArray *Existing_CMP_throw_distance;
    NSMutableArray *Existing_CMP_remount;
    
        
    NSMutableArray *Cmp_mounting_location;
    NSMutableArray *Cmp_poleLength;
    NSMutableArray *Cmp_poleLength_notes;
    
    NSMutableArray *Cable_ports;
    
    NSMutableArray *Height_of_smartboard;
    NSMutableArray *Height_of_smartboard_notes;
    NSMutableArray *Height_of_smartboard_classroom_type;
    
    NSMutableArray *Ceiling_height;
    NSMutableArray *Ceiling_structure;
    NSMutableArray *Ceiling_structure_other;
    
    NSMutableArray *Wall_structure;
    NSMutableArray *Wall_structure_notes;
    NSMutableArray *Wall_structure_board;
    NSMutableArray *Wall_structure_board_notes;
    
    NSMutableArray *Photo_file_directory_1;
    NSMutableArray *Photo_file_directory_2;
    NSMutableArray *Photo_file_directory_3;
    NSMutableArray *Photo_file_directory_4;
    NSMutableArray *Photo_file_directory_5;
    NSMutableArray *Photo_file_directory_6;
    NSMutableArray *Photo_file_directory_7;
    NSMutableArray *Photo_file_directory_8;
    
    NSMutableArray *Raceway_part_1;
    NSMutableArray *Raceway_part_2;
    NSMutableArray *Raceway_part_3;
    NSMutableArray *Raceway_part_4;
    NSMutableArray *Raceway_part_5;
    NSMutableArray *Raceway_part_6;
    NSMutableArray *Raceway_part_7;
    NSMutableArray *Raceway_part_8;
    NSMutableArray *Raceway_part_9;
    NSMutableArray *Raceway_part_10;
    
    //group3
    NSMutableArray *Speaker;
    NSMutableArray *Audio_package;
    NSMutableArray *Audio_accessories;
    NSMutableArray *Internal_notes;
    NSMutableArray *Port_desc;
    NSMutableArray *Nyc_cable_bundle;
    NSMutableArray *Existing_board_other;
    NSMutableArray *Custom_build_rail;
    NSMutableArray *CMP_mounting_other;
    NSMutableArray *Mounting_location;
    NSMutableArray *Flat_panel;
    NSMutableArray *Flat_panel_other;
    NSMutableArray *Cork_penetrated;
    NSMutableArray *Audio_accessories_other;
    NSMutableArray *Wall_number;
    
    /*** PDF group 1 ***/
    
    NSMutableArray *PDF_room;
    NSMutableArray *PDF_board;
    NSMutableArray *PDF_projection;
    NSMutableArray *PDF_mounting;
    NSMutableArray *PDF_projector_mounting;
    
    NSMutableArray *PDF_audio;
    NSMutableArray *PDF_ceiling_speakers;
    NSMutableArray *PDF_wall_speakers;
    
    NSMutableArray *PDF_mounting_bracket;
    NSMutableArray *PDF_ceiling_sensors;
    NSMutableArray *PDF_wall_sensors;
    
    NSMutableArray *PDF_cables;
    NSMutableArray *PDF_device_plate;
    
    NSMutableArray *PDF_peripherals;
    
    NSMutableArray *PDF_client_remove;
    NSMutableArray *PDF_client_provide_power;
    NSMutableArray *PDF_power_within_three_feet;
    
    NSMutableArray *PDF_comments;
    NSMutableArray *PDF_drawing;
    
    /*** PDF group 2 ***/
    
    NSMutableArray *PDF_existing_board;
    NSMutableArray *PDF_existing_projector;
    NSMutableArray *PDF_existing_cmp_model;
    NSMutableArray *PDF_existing_projector_serial;
    NSMutableArray *PDF_existing_cmp_throw_distance;
    NSMutableArray *PDF_existing_cmp_remount;
    
    //NSMutableArray *PDF_audio_raceway_length;
        
    //NSMutableArray *PDF_cmp_raceway;
    NSMutableArray *PDF_cmp_polelength;
    
    NSMutableArray *PDF_ports;
    
    NSMutableArray *PDF_height_of_smartboard;
    NSMutableArray *PDF_height_of_smartboard_classroom_type;
    
    NSMutableArray *PDF_ceiling_height;
    NSMutableArray *PDF_ceiling_structure;
    
    NSMutableArray *PDF_wall_structure;
    NSMutableArray *PDF_wall_structure_board;
    
    NSMutableArray *PDF_photo_file_directory_1;
    NSMutableArray *PDF_photo_file_directory_2;
    NSMutableArray *PDF_photo_file_directory_3;
    NSMutableArray *PDF_photo_file_directory_4;
    NSMutableArray *PDF_photo_file_directory_5;
    NSMutableArray *PDF_photo_file_directory_6;
    NSMutableArray *PDF_photo_file_directory_7;
    NSMutableArray *PDF_photo_file_directory_8;
        
    NSMutableArray *PDF_Raceway_parts;
    NSMutableString *PDF_room_number;
    
    NSMutableArray *PDF_speaker;
    NSMutableArray *PDF_audio_package;
    NSMutableArray *PDF_audio_accessories;
    NSMutableArray *PDF_internal_notes;
    NSMutableArray *PDF_port_desc;
    NSMutableArray *PDF_nyc_cable_bundle;
    NSMutableArray *PDF_mounting_location;
    NSMutableArray *PDF_flat_panel;
    NSMutableArray *PDF_cork_penetrated;
    NSMutableArray *PDF_wall_number;
}

@property (strong, nonatomic) NSString *callBackFunction;

- (void) loadVariablesForPDF;
- (void) rewriteVariablesToReadablePDFFields;
- (void) drawPDF:(NSString*)fileName;
- (UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;
- (NSString*) getPDFFileName;

@end
