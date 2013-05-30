//
//  FifteenthDetailView.h
//  MultipleDetailViews
//
//  Created by Helpdesk on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "photoEditor.h"

@interface FifteenthDetailView : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPopoverControllerDelegate>
{
    UIToolbar *toolbar;
    UIPopoverController *popoverController;
    UIBarButtonItem *cameraButton;
    UIBarButtonItem *cameraRollButton;
    UIImagePickerController *imagePicker;
    BOOL newMedia;
    
}
@property (nonatomic, strong) IBOutlet UIImageView *imageView1;
@property (nonatomic, strong) IBOutlet UIImageView *imageView2;
@property (nonatomic, strong) IBOutlet UIImageView *imageView3;
@property (nonatomic, strong) IBOutlet UIImageView *imageView4;
@property (strong, nonatomic) IBOutlet UIImageView *imageView5;
@property (strong, nonatomic) IBOutlet UIImageView *imageView6;
@property (strong, nonatomic) IBOutlet UIImageView *imageView7;
@property (strong, nonatomic) IBOutlet UIImageView *imageView8;

@property (strong, nonatomic) IBOutlet UIButton *imageButton1;
@property (strong, nonatomic) IBOutlet UIButton *imageButton2;
@property (strong, nonatomic) IBOutlet UIButton *imageButton3;
@property (strong, nonatomic) IBOutlet UIButton *imageButton4;
@property (strong, nonatomic) IBOutlet UIButton *imageButton5;
@property (strong, nonatomic) IBOutlet UIButton *imageButton6;
@property (strong, nonatomic) IBOutlet UIButton *imageButton7;
@property (strong, nonatomic) IBOutlet UIButton *imageButton8;


- (IBAction)imageButtonTouched:(id)sender;


@property (nonatomic, strong) NSData *imageData1;
@property (nonatomic, strong) NSData *imageData2;
@property (nonatomic, strong) NSData *imageData3;
@property (nonatomic, strong) NSData *imageData4;
@property (nonatomic, strong) NSData *imageData5;
@property (nonatomic, strong) NSData *imageData6;
@property (nonatomic, strong) NSData *imageData7;
@property (nonatomic, strong) NSData *imageData8;

@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *image4;
@property (nonatomic, strong) UIImage *image5;
@property (nonatomic, strong) UIImage *image6;
@property (nonatomic, strong) UIImage *image7;
@property (nonatomic, strong) UIImage *image8;

@property (nonatomic, strong) UIImage *defaultImage;

- (IBAction)deleteImage:(id)sender;

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) IBOutlet UIButton *deleteButton1;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton2;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton3;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton4;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton5;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton6;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton7;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton8;


@property (strong, nonatomic) IBOutlet UIButton *editButton1;
@property (strong, nonatomic) IBOutlet UIButton *editButton2;
@property (strong, nonatomic) IBOutlet UIButton *editButton3;
@property (strong, nonatomic) IBOutlet UIButton *editButton4;
@property (strong, nonatomic) IBOutlet UIButton *editButton5;
@property (strong, nonatomic) IBOutlet UIButton *editButton6;
@property (strong, nonatomic) IBOutlet UIButton *editButton7;
@property (strong, nonatomic) IBOutlet UIButton *editButton8;

@property (strong, nonatomic) NSURL *nsURL1;
@property (strong, nonatomic) NSURL *nsURL2;
@property (strong, nonatomic) NSURL *nsURL3;
@property (strong, nonatomic) NSURL *nsURL4;
@property (strong, nonatomic) NSURL *nsURL5;
@property (strong, nonatomic) NSURL *nsURL6;
@property (strong, nonatomic) NSURL *nsURL7;
@property (strong, nonatomic) NSURL *nsURL8;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@property (nonatomic) int touchedImageNumber;

@property (nonatomic, strong) photoEditor *photoEditorModal;

@property (nonatomic) int status; //0: nothing, 1: camera, 2: album

- (IBAction)useCamera: (id)sender;
- (IBAction)useCameraRoll: (id)sender;
//-(void)loadImageWithNSURL: (NSURL *)currentURL;
-(void)loadImageWithImage: (UIImage *)image atIndex: (int) index;

- (IBAction)editButtonClicked:(id)sender;


@end
