//
//  PreferencesController.h
//  cuatroChan
//
//  Created by Israel Cabrera on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController {
    
    IBOutlet NSTabView *tabView;
    IBOutlet NSPathControl *generalPath;
    IBOutlet NSPathControl *pronPath;
    
    NSString *generalPathString;
    NSString *pronPathString;
}
- (IBAction)showPreferencesTab:(id)sender;
- (IBAction)showPathsTab:(id)sender;
- (IBAction)showAdvancedTab:(id)sender;
- (IBAction)changedValues:(id)sender;

@end
