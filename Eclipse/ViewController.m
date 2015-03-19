#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>


@interface ViewController ()
{
	AVCaptureSession			*_session;
	AVCaptureVideoPreviewLayer	*_preview;
	
	CGFloat		_beginGestureScale;
	CGFloat		_effectiveScale;
}

@end


@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_session = [[AVCaptureSession alloc] init];
	_preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	if (!device)
		return;
	
	[_session addInput:[AVCaptureDeviceInput deviceInputWithDevice:device error:nil]];
	[_session startRunning];
	
	_preview.frame = self.view.frame;
	
	[self.view.layer addSublayer:_preview];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
	// Bounds
	CGRect bounds = self.view.layer.bounds;
	
	_preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
	_preview.bounds = bounds;
	_preview.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
	
	// Orientation
	if ([UIDevice currentDevice].orientation < UIDeviceOrientationPortrait || [UIDevice currentDevice].orientation > UIDeviceOrientationLandscapeRight)
		return;
	
	[_preview.connection setVideoOrientation:(NSInteger)[UIDevice currentDevice].orientation];
}


#pragma mark - Pinch to Zoom gestures

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
	if (recognizer.state != UIGestureRecognizerStateBegan && recognizer.state != UIGestureRecognizerStateChanged)
		return;
	
	if (recognizer.state == UIGestureRecognizerStateBegan)
	{
		_beginGestureScale = (_effectiveScale == 0) ? recognizer.scale : _effectiveScale;
	}
	
	if (recognizer.state == UIGestureRecognizerStateChanged)
	{
		_effectiveScale = MAX(_beginGestureScale * recognizer.scale, 1.0);
		
		[CATransaction begin];
		[CATransaction setAnimationDuration:.025];
		
		[_preview setAffineTransform:CGAffineTransformMakeScale(_effectiveScale, _effectiveScale)];
		
		[CATransaction commit];
	}
}


@end
