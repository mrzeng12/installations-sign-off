//
//  RedBoxOverlayController.m
//  Installation
//
//  Created by Chao Zeng on 8/1/13.
//
//

#import "RedBoxOverlayController.h"


@implementation RedBoxOverlayController

/*******************************************************************************
 viewDidUnload
 
 
 */
- (void) viewDidUnload
{
	captureButton = nil;
	savingImageLabel = nil;
    frontBackCameraButton = nil;
}

/*******************************************************************************
 didReceiveMemoryWarning
 
 */
- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

/*******************************************************************************
 viewWillAppear:
 
 Sets up the initial state of UI elements in the overlay.
 */
- (void) viewWillAppear:(BOOL)animated
{
	inRangeLabel.hidden = true;
	numBarcodesFoundLabel.text = @"";
	
	torchButton.enabled = self.parentPicker.hasFlash;
	torchButton.style = self.parentPicker.torchState ?  UIBarButtonItemStyleDone :
    UIBarButtonItemStyleBordered;
}

#pragma mark Button Handlers

/*******************************************************************************
 cancelScan
 
 Action proc for the 'Done' button.
 */
- (IBAction) cancelScan
{
	[self.parentPicker doneScanning];
}

/*******************************************************************************
 captureImage
 
 Action proc for the 'Cap' button.
 Need to have reportCameraImage enabled for this.
 */
- (IBAction) captureImage
{
	if (!imageSaveInProgress)
	{
		[self.parentPicker requestCameraSnapshot:true];
		savingImageLabel.hidden = false;
		captureButton.enabled = false;
	}
}

/*******************************************************************************
 toggleFrontBackCamera
 
 Action proc for the 'Front/Back' button.
 */
- (IBAction) toggleFrontBackCamera
{
	self.parentPicker.useFrontCamera = !self.parentPicker.useFrontCamera;
}

/*******************************************************************************
 toggleTorch
 
 Action proc for the 'Light' button.
 */
- (IBAction) toggleTorch
{
	self.parentPicker.torchState = !self.parentPicker.torchState;
	torchButton.style = self.parentPicker.torchState ?  UIBarButtonItemStyleDone :
    UIBarButtonItemStyleBordered;
}

#pragma mark Status Updates

/*******************************************************************************
 barcodePickerController:statusUpdated:
 
 The RedLaser SDK will call this method repeatedly while scanning for barcodes.
 */
- (void)barcodePickerController:(BarcodePickerController*)picker statusUpdated:(NSDictionary*)status
{
	NSSet *foundBarcodes = [status objectForKey:@"FoundBarcodes"];
	
	// Report how many barcodes we've found so far
	numBarcodesFoundLabel.text = [NSString stringWithFormat:@"%d Barcodes found",
                                  [foundBarcodes count]];
    
	// Show the right guidance string for the guidance level
	// Guidance is used for detecting long Code 39 codes in parts.
	// See the documentation for more info.
	int guidanceLevel = [[status objectForKey:@"Guidance"] intValue];
	if (guidanceLevel == 1)
	{
		guidanceLabel.text = @"Try moving the camera close to each part of the barcode";
	} else if (guidanceLevel == 2)
	{
		guidanceLabel.text = [NSString stringWithFormat:@"%@…",
                              [status objectForKey:@"PartialBarcode"]];
	} else {
		guidanceLabel.text = @"";
	}
	
	// Show the in range label if we're in range of an EAN barcode
	inRangeLabel.hidden = ![[status objectForKey:@"InRange"] boolValue];
    
	// Tell the Red Box View to update its display
	redBoxView.barcodes = foundBarcodes;
	[redBoxView setNeedsDisplay];
	
	// If the user clicked the "Capture" button, this key will have a UIImage in it
	// on a subsequent statusUpdated call. Otherwise, the key won't be present.
	// If we have a camera image, save it to the device's photo album.
	UIImage *cameraImage = [status objectForKey:@"CameraSnapshot"];
	if (cameraImage)
	{
		imageSaveInProgress = true;
        
		UIImageWriteToSavedPhotosAlbum(cameraImage, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
	}
}


/*******************************************************************************
 image:didFinishSavingWithError:contextInfo:
 
 Called when UIImageWriteToSavedPhotosAlbum() has finished saving an image to
 the camera roll.
 
 Reenables the Capture button and hides the "Saving Image..." label.
 */
- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error
   contextInfo: (void *) contextInfo
{
	imageSaveInProgress = false;
	savingImageLabel.hidden = true;
	captureButton.enabled = true;
}

@end

@implementation RedBoxView

@synthesize barcodes;


/*******************************************************************************
 drawRect:
 
 RedBoxView is a UIView subclass that exists to override this method.
 
 When it redraws itself, it looks for any barcodes in the found barcode set that
 have been 'seen' in the last second, makes a UIBezierPath from the corner
 locations of the barcode, and then fills and strokes the path.
 */
- (void) drawRect:(CGRect)rect
{
	for (BarcodeResult *val in self.barcodes)
	{
		// Has this barcode been seen on-screen recently, or is it stale?
		if ([val.mostRecentScanTime timeIntervalSinceNow] < -1.0)
		{
			continue;
		}
		
		// Don't bother displaying a path that only has 2 points--this is rare but can happen
		if ([val.barcodeLocation count] < 2)
			continue;
        
		// Generate a UIBezierPath of the points, close it, and fill it
		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:[[val.barcodeLocation objectAtIndex:0] CGPointValue]];
		for (int index = 1; index < [val.barcodeLocation count]; ++index)
		{
			[path addLineToPoint:[[val.barcodeLocation objectAtIndex:index] CGPointValue]];
		}
		[path closePath];
        
		[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2] set];
    	[path fill];
        
		[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3] set];
    	[path stroke];
	}
    
	// Be sure to clear out the barcodes once we've drawn them
	self.barcodes = nil;
}

- (void) didMoveToSuperview
{
	CGRect superviewFrame = [[self superview] frame];
	superviewFrame.origin.x = superviewFrame.origin.y = 0;
	self.frame = superviewFrame;
	[super didMoveToSuperview];
}


@end
