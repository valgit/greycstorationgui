/* GreycstorationController */

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"

//we conform to the ProcessController protocol, as defined in Process.h
@interface GreycstorationController : NSObject <TaskWrapperController>
{
    IBOutlet NSSlider *mAngularStep;
	IBOutlet NSStepper *mAngularStepStepper;
	IBOutlet NSTextField *mAngularStepTextField;
    IBOutlet NSSlider *mAnisotropy;
	IBOutlet NSStepper *mAnisotropyStepper;
	IBOutlet NSTextField *mAnisotropyTextField;
    IBOutlet NSSlider *mContour;
	IBOutlet NSStepper *mContourStepper;
	IBOutlet NSTextField *mContourTextField;
    IBOutlet NSButton *mFast;
    IBOutlet NSSlider *mGeometry;
	IBOutlet NSStepper *mGeometryStepper;
	IBOutlet NSTextField *mGeometryTextField;
    IBOutlet NSTextField *mInputFile;
    IBOutlet NSPopUpButton *mInterpolationType;
    IBOutlet NSSlider *mIteration;
    IBOutlet NSStepper *mIterStepper;
    IBOutlet NSTextField *mIterTextField;
    IBOutlet NSSlider *mNoiseScale;
	IBOutlet NSStepper *mNoiseScaleStepper;
	IBOutlet NSTextField *mNoiseScaleTextField;
    IBOutlet NSTextField *mOuputFile;
    IBOutlet NSSlider *mSpatialStep;
    IBOutlet NSTextField *mSpatialStepTextField;
	IBOutlet NSStepper *mSpatialStepStepper;
	IBOutlet NSSlider *mStrength;
	IBOutlet NSStepper *mStrengthStepper;
	IBOutlet NSTextField *mStrengthTextField;
    IBOutlet NSWindow *window;

	IBOutlet NSSlider *mCurve;
	IBOutlet NSStepper *mCurveStepper;
	IBOutlet NSTextField *mCurveTextField;
	
    IBOutlet NSPopUpButton *mOutFormat;
    IBOutlet NSTextField *mOutQuality;
	IBOutlet NSTextField *mOutFile;
	IBOutlet NSTextField *mAppendTo;
	IBOutlet NSMatrix *mOutputType;
	IBOutlet NSSlider *mOutputQualitySlider;

	
	IBOutlet NSButton *mRestoreButton;
	IBOutlet NSButton *mCancel;
	IBOutlet NSImageView *mInputImage;
	
	IBOutlet NSProgressIndicator *mProgress;
	
	@private
	BOOL findRunning;
    TaskWrapper *greycstorationTask;
}
- (IBAction)about:(id)sender;
- (IBAction)chooseInputFile:(id)sender;
- (IBAction)chooseOutputFile:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)restore:(id)sender;
- (IBAction)takeIter:(id)sender;
- (IBAction)takeStrength:(id)sender;
- (IBAction)takeContour:(id)sender;
- (IBAction)takeNoise:(id)sender;
- (IBAction)takeAngular:(id)sender;
- (IBAction)takeGeometry:(id)sender;
- (IBAction)takeAnisotropy:(id)sender;
- (IBAction)takeSpatial:(id)sender;
- (IBAction)takeCurve:(id)sender;
- (IBAction)resetDefaults:(id)sender;

// startup
- (void)awakeFromNib;
- (id)init;
- (void)dealloc;

@end
