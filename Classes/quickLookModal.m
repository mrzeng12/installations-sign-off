//
//  quickLookModal.m
//  Site Survey
//
//  Created by Chao Zeng on 10/23/12.
//
//

#import "quickLookModal.h"
#import "CompletePDFRenderer.h"

@interface quickLookModal ()

@end

@implementation quickLookModal

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Preview Controller

/*---------------------------------------------------------------------------
 *
 *--------------------------------------------------------------------------*/
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	return 1;
}

/*---------------------------------------------------------------------------
 *
 *--------------------------------------------------------------------------*/
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	// Break the path into it's components (filename and extension)
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    
    NSString * pdfFileName = [renderer getPDFFileName];
    
	NSArray *fileComponents = [pdfFileName componentsSeparatedByString:@"."];
    
	// Use the filename (index 0) and the extension (index 1) to get path
    NSString *path = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
	return [NSURL fileURLWithPath:path];
}

@end
