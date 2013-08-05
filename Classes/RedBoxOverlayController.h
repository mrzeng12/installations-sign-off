//
//  RedBoxOverlayController.h
//  Installation
//
//  Created by Chao Zeng on 8/1/13.
//
//

#import <UIKit/UIKit.h>

#import "RedLaserSDK.h"

@interface RedBoxView : UIView
{
@public
	NSSet				*barcodes;
}

@property (retain) NSSet *barcodes;

@end

@interface RedBoxOverlayController : CameraOverlayViewController
{
	IBOutlet UIBarButtonItem	*torchButton;
	IBOutlet UIBarButtonItem	*frontBackCameraButton;
	IBOutlet UIBarButtonItem 	*captureButton;
	IBOutlet UILabel			*numBarcodesFoundLabel;
	IBOutlet UILabel			*guidanceLabel;
	IBOutlet UILabel			*inRangeLabel;
	IBOutlet UILabel 			*savingImageLabel;
	IBOutlet RedBoxView			*redBoxView;
	
	bool						imageSaveInProgress;
}

- (IBAction) cancelScan;
- (IBAction) captureImage;
- (IBAction) toggleTorch;
- (IBAction) toggleFrontBackCamera;

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error
   contextInfo: (void *) contextInfo;

@end
