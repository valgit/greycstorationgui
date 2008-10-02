#import "GreycstorationController.h"

@implementation GreycstorationController

#pragma mark -
#pragma mark TaskWrapper

// This callback is implemented as part of conforming to the ProcessController protocol.
// It will be called whenever there is output from the TaskWrapper.
- (void)appendOutput:(NSString *)output
{
    // add the string (a chunk of the results from locate) to the NSTextView's
    // backing store, in the form of an attributed string
    //NSLog(@"output is : [%@]",output);
	[mProgress incrementBy:1.0];
    //[[resultsTextField textStorage] appendAttributedString: [[[NSAttributedString alloc]
    //                         initWithString: output] autorelease]];
    // setup a selector to be called the next time through the event loop to scroll
    // the view to the just pasted text.  We don't want to scroll right now,
    // because of a bug in Mac OS X version 10.1 that causes scrolling in the context
    // of a text storage update to starve the app of events
    //[self performSelector:@selector(scrollToVisible:) withObject:nil afterDelay:0.0];
}

// A callback that gets called when a TaskWrapper is launched, allowing us to do any setup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processStarted
{
    findRunning=YES;
    // clear the results
    //[resultsTextField setString:@""];
    // change the "Sleuth" button to say "Stop"
    //[mRestoreButton setTitle:@"Stop"];
	[mRestoreButton setEnabled:NO];
	[mProgress startAnimation:self];
}

// A callback that gets called when a TaskWrapper is completed, allowing us to do any cleanup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processFinished
{
	[mProgress stopAnimation:self];
	[mProgress setDoubleValue:0];
	
    findRunning=NO;
    // change the button's title back for the next search
    //[mRestoreButton setTitle:@"Restore"];
	[mRestoreButton setEnabled:YES];
}

// If the user closes the search window, let's just quit
-(BOOL)windowShouldClose:(id)sender
{
    if (findRunning == YES) {
		[greycstorationTask stopProcess];
		// Release the memory for this wrapper object
		[greycstorationTask release];
		greycstorationTask=nil;
    }
	
    [NSApp terminate:nil];
    return YES;
}

#pragma mark -
#pragma mark init & dealloc

// when first launched, this routine is called when all objects are created
// and initialized.  It's a chance for us to set things up before the user gets
// control of the UI.
-(void)awakeFromNib
{
    findRunning=NO;
    greycstorationTask=nil;
#if 0
	// check for greycstoration binaries...
	if([fm isExecutableFileAtPath:find]==NO){ 
        [NSException raise:NSGenericException 
					format:@"bad_find_binary:_%@", find]; 
    } 
#endif
	
	[window center];
	[window makeKeyAndOrderFront:nil];
}

- (id)init 
{
	if ( ! [super init])
        return nil;
	
	return self;
}

- (void)dealloc 
{
    [super dealloc];
}

- (NSString *)nextUniqueNameUsing:(NSString *)templatier withFormat:(NSString *)format appending:(NSString *)append
{
    static int unique = 1;
    NSString *tempName = nil;
	
    if ([format isEqualToString:@""]) 
		format = [templatier pathExtension];
	
    NSLog(@"format is : %@",format);
	
    tempName =[NSString stringWithFormat:@"%@%@.%@",
		[templatier stringByDeletingPathExtension],append,
		//[templatier pathExtension]];
		format];
		if ([[NSFileManager defaultManager] fileExistsAtPath:tempName]) {
			do {
				tempName =[NSString stringWithFormat:@"%@%@_%d.%@",
					[templatier stringByDeletingPathExtension],append,unique++,
					//[templatier pathExtension]];
					format];
	    } while ([[NSFileManager defaultManager] fileExistsAtPath:tempName]);
    }
		return tempName;
}

#pragma mark -
#pragma mark User Action
//
- (IBAction)about:(id)sender
{
	NSLog(@"the user just click on info");
}

- (IBAction)chooseInputFile:(id)sender
{
	// Create the File Open Panel class.
	NSOpenPanel* oPanel = [NSOpenPanel openPanel];
	NSArray *fileTypes = [NSArray arrayWithObjects:@"jpg", @"jpeg",@"png",@"tif", @"tiff", nil];
	
	[oPanel setCanChooseDirectories:NO];
	[oPanel setCanChooseFiles:YES];
	[oPanel setCanCreateDirectories:NO];
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setAlphaValue:0.95];
	[oPanel setTitle:@"Select a file to process"];
	
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	//	if ( [oPanel runModalForDirectory:nil file:nil types:fileTypes]
	if ( [oPanel runModalForDirectory:nil file:nil types:fileTypes]
		 == NSOKButton )
	{
		// Get an array containing the full filenames of all
		// files and directories selected.
		NSArray* files = [oPanel filenames];
		
		NSString* fileName = [files objectAtIndex:0];
		NSLog(fileName);
		[mInputFile setStringValue:fileName];
		
		// display image in a preview window ...
		NSImage *Inputimage = [[NSImage alloc] initWithContentsOfFile:fileName];		
		if (Inputimage!=nil) {
			if ([mInputImage image]!=nil)
				[[mInputImage image] release];
			
			[mInputImage setImage: Inputimage];
			//[mInputImage setNeedsDisplay:YES];
			//[Inputimage release];
	    }
	}
	
}

- (IBAction)chooseOutputFile:(id)sender
{
	// Create the File Open Panel class.
	NSOpenPanel* oPanel = [NSOpenPanel openPanel];
	
	[oPanel setCanChooseDirectories:YES];
	[oPanel setCanChooseFiles:NO];
	[oPanel setCanCreateDirectories:YES];
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setAlphaValue:0.95];
	[oPanel setTitle:@"Select a directory for output"];
	
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	//	if ( [oPanel runModalForDirectory:nil file:nil types:fileTypes]
	if ( [oPanel runModalForDirectory:nil file:nil types:nil]
		 == NSOKButton )
	{
		// Get an array containing the full filenames of all
		// files and directories selected.
		NSArray* files = [oPanel filenames];
		
		NSString* fileName = [files objectAtIndex:0];
		NSLog(fileName);
		[mOuputFile setStringValue:fileName];
		
	}
	
}

// user stop the process ...
//
- (IBAction)quit:(id)sender
{
	//NSLog(@"the user just clicked on close");
	//[NSApp terminate:nil];
	if (findRunning) { 
		[greycstorationTask stopProcess];
		// Release the memory for this wrapper object
		[greycstorationTask release];
		greycstorationTask=nil;
	}
	[mRestoreButton setEnabled:YES];
}

// This action kicks off a greycstoration task
- (IBAction)restore:(id)sender
{
    if (findRunning) {
		NSLog(@"already running");
        // This stops the task and calls our callback (-processFinished)
        //[greycstorationTask stopProcess];
        // Release the memory for this wrapper object
        //[greycstorationTask release];
        //greycstorationTask=nil;
        return;
    } else {
        // If the task is still sitting around from the last run, release it
        if (greycstorationTask!=nil)
			[greycstorationTask release];
        // Let's allocate memory for and initialize a new TaskWrapper object, passing
        // in ourselves as the controller for this TaskWrapper object, the path
        // to the command-line tool, and the contents of the text field that 
        // displays what the user wants to search on
		NSMutableArray *args = [NSMutableArray array];
		
		NSString *filename = [[mInputFile stringValue] lastPathComponent];
		//NSString *extension = [[filename pathExtension] lowercaseString];
		//NSLog(filename);
		NSString* outputfile;
		
		switch ([[mOutputType selectedCell] tag]) {
			case 0 : /* absolute */
				outputfile = [[mOuputFile stringValue] 
						stringByAppendingPathComponent:[self nextUniqueNameUsing:[mOutFile stringValue]
															  withFormat:[[mOutFormat titleOfSelectedItem] lowercaseString]  
															  appending:[mAppendTo stringValue] ]]; 
				break;
			case 1: /* append */
				outputfile = [[mOuputFile stringValue] 
						stringByAppendingPathComponent:[self nextUniqueNameUsing:filename 
															  withFormat:[[mOutFormat titleOfSelectedItem] lowercaseString] 
															  appending:[mAppendTo stringValue] ]];
				break;
			default:
				NSLog(@"bad selected tag is %d",[[mOutputType selectedCell] tag]);
		}
		
		NSLog(outputfile);
		
#ifndef GNUSTEP	
		NSString *path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] bundlePath],
			/*@"/greycstoration.app/Contents/MacOS/greycstoration"*/
			@"/greycstoration/greycstoration"];
		//[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"greycstoration"];
		//NSLog(@"path is %@ -> %@",path,[[ NSBundle mainBundle ] bundlePath]);
		//[args addObject:[ [ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"greycstoration" ]];
		[args addObject:path];
		//[args addObject:@"/Users/vbr/Source/CImg-1.2.9/examples/greycstoration"];
		// NSString *pathToFfmpeg = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/ffmpeg"];
#else
		[args addObject:@"/home/vbr/perso/CImg-1.2.9/examples/greycstoration"];
#endif
		//[args addObject:@"greycstoration"];
		[args addObject:@"-restore"];
		[args addObject:[mInputFile stringValue]];
		[args addObject:@"-o"];
		[args addObject:outputfile];
		if ([mFast state]) {
			[args addObject:@"-fast"];
			[args addObject:@"true"];
		}
		
		[args addObject:@"-visu"];
		[args addObject:@"false"];
		
		[args addObject:@"-iter"];
		[args addObject:[mIteration stringValue]];
		
		[args addObject:@"-interp"];
		[args addObject:[NSString stringWithFormat:@"%d",[mInterpolationType indexOfSelectedItem] ]];
		
		NSLog(@"info jpeg : %@",[mOutQuality stringValue]);
		if ([[mOutFormat titleOfSelectedItem] isEqualToString:@"JPEG"] ) {
			[args addObject:@"-quality"]; // if jpeg !
			[args addObject:[mOutQuality stringValue]];
		}
		[args addObject:@"-dt"];  // Regularization strength
		[args addObject:[mStrength stringValue]];

		[args addObject:@"-p"];  // Contour preservation
		[args addObject:[mContour stringValue]];

		[args addObject:@"-a"];   // Smoothing anisotropy (0<=a<=1)
		[args addObject:[mAnisotropy stringValue]];

		[args addObject:@"-alpha"];  // Noise scale 
		[args addObject:[mNoiseScale stringValue]];

		[args addObject:@"-sigma"];  // Geometry regularity
		[args addObject:[mGeometry stringValue]];

		[args addObject:@"-dl"];   // Spatial integration step (0<=dl<=1)
		[args addObject:[mSpatialStep stringValue]];

		[args addObject:@"-da"];   // Angular integration step (0<=da<=90)
		[args addObject:[mAngularStep stringValue]];

		[args addObject:@"-sharp"]; // no sharpening ...
		[args addObject:@"0"];

		//[mRestoreButton setEnabled:NO];
		[mProgress setDoubleValue:0.0];
		[mProgress setMaxValue:(7.0+[mIteration intValue])];
		
        greycstorationTask=[[TaskWrapper alloc] initWithController:self arguments:args];
        // kick off the process asynchronously
        [greycstorationTask startProcess];
    }
	
}

#pragma mark -
#pragma mark IB action

- (IBAction)takeIter:(id)sender;
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	int theValue = [sender intValue];
	[mIterTextField setIntValue:theValue];
	[mIterStepper setIntValue:theValue];
	[mIteration setIntValue:theValue];
}

- (IBAction)takeStrength:(id)sender;
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	float theValue = [sender floatValue];
	[mStrengthTextField setFloatValue:theValue];
	[mStrengthStepper setFloatValue:theValue];
	[mStrength setFloatValue:theValue];
}

- (IBAction)takeNoise:(id)sender;
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	float theValue = [sender floatValue];
	[mNoiseScaleTextField setFloatValue:theValue];
	[mNoiseScaleStepper setFloatValue:theValue];
	[mNoiseScale setFloatValue:theValue];
}

- (IBAction)takeContour:(id)sender;
{
	float theValue = [sender floatValue];
	//NSLog(@"%s -> %f",__PRETTY_FUNCTION__,theValue);
	   [mContourTextField setFloatValue:theValue];
       [mContourStepper setFloatValue:theValue];
       [mContour setFloatValue:theValue];
}

- (IBAction)takeAngular:(id)sender;
{       
	float theValue = [sender floatValue];
	//NSLog(@"%s -> %f",__PRETTY_FUNCTION__,theValue);
	   [mAngularStepTextField setFloatValue:theValue];
       [mAngularStepStepper setFloatValue:theValue];
       [mAngularStep setFloatValue:theValue];
}

- (IBAction)takeAnisotropy:(id)sender;
{       
	float theValue = [sender floatValue];
	//NSLog(@"%s -> %f",__PRETTY_FUNCTION__,theValue);
	   [mAnisotropyTextField setFloatValue:theValue];
       [mAnisotropyStepper setFloatValue:theValue];
       [mAnisotropy setFloatValue:theValue];
}

- (IBAction)takeCurve:(id)sender;
{       
	float theValue = [sender floatValue];
	//NSLog(@"%s -> %f",__PRETTY_FUNCTION__,theValue);
	   [mCurveTextField setFloatValue:theValue];
       [mCurveStepper setFloatValue:theValue];
       [mCurve setFloatValue:theValue];
}

- (IBAction)takeSpatial:(id)sender;
{       
	float theValue = [sender floatValue];
	//NSLog(@"%s -> %f",__PRETTY_FUNCTION__,theValue);
	   [mSpatialStepTextField setFloatValue:theValue];
       [mSpatialStepStepper setFloatValue:theValue];
       [mSpatialStep setFloatValue:theValue];
}

- (IBAction)takeGeometry:(id)sender;
{       
	float theValue = [sender floatValue];
	//NSLog(@"%s -> %f",__PRETTY_FUNCTION__,theValue);
	   [mGeometryTextField setFloatValue:theValue];
       [mGeometryStepper setFloatValue:theValue];
       [mGeometry setFloatValue:theValue];
}

// Display the release notes, as chosen from the menu item in the Help menu.
- (IBAction)displayReleaseNotes:(id)sender
{
    // Grab the release notes from the Resources folder in the app bundle, and stuff 
    // them into the proper text field
  //  [relNotesTextField readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"ReadMe" ofType:@"rtf"]];
    //[relNotesWin makeKeyAndOrderFront:self];
}

- (IBAction)resetDefaults:(id)sender;
{
      //NSLog(@"%s",__PRETTY_FUNCTION__);
#if 0
        .sp_gh set 100
        .sp_gv set 100
        .sp_pdt set 20
        .sc_pp set 0.8
        .sp_psdt set 10
        .sp_psp set 3
        .sp_ptile set 0
        .sp_pbtile set 4

  false, // patch_based
  4,     // patch_size
  10.0f, // sigma_p
  15.0f, // sigma_s
  7,     // Lookup size
  2.0,   // gauss_prec

    interpolation algorithm :: -interp    -interp 0 Interpolation type (0=Nearest-neighbor, 1=Linear, 2=Runge-Kutta)

#endif
	[mIteration setIntValue:1];
	[self takeIter:mIteration];

	[mStrength setFloatValue:40.0];
	[self takeStrength:mStrength];

	[mNoiseScale setFloatValue:0.6];
	[self takeNoise:mNoiseScale];

	[mContour setFloatValue:0.9];
	[self takeContour:mContour];

	[mAngularStep setFloatValue:30.0];
	[self takeAngular:mAngularStep];

	[mAnisotropy setFloatValue:0.15];
	[self takeAnisotropy:mAnisotropy];

	[mCurve setFloatValue:0.15];
	[self takeCurve:mCurve];

	[mSpatialStep setFloatValue:0.8];
	[self takeSpatial:mSpatialStep];

	[mGeometry setFloatValue:1.1];
	[self takeGeometry:mGeometry];

	[mFast setState:YES];

	[mInterpolationType selectItemAtIndex:0];
}

@end
