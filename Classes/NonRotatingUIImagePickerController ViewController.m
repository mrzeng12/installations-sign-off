//
//  NonRotatingUIImagePickerController ViewController.m
//  Site Survey
//
//  Created by Chao Zeng on 9/27/12.
//
//

#import "NonRotatingUIImagePickerController ViewController.h"

@interface NonRotatingUIImagePickerController_ViewController ()

@end

@implementation NonRotatingUIImagePickerController_ViewController

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

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
