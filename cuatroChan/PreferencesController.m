//
//  PreferencesController.m
//  cuatroChan
//
//  Created by Israel Cabrera on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    generalPathString = [[NSUserDefaults standardUserDefaults] objectForKey:@"standardPath"];
    pronPathString = [[NSUserDefaults standardUserDefaults] objectForKey:@"pronPath"];
    [generalPath setURL:[[NSURL alloc] initFileURLWithPath:generalPathString isDirectory:TRUE]];
    [pronPath setURL:[[NSURL alloc] initFileURLWithPath:pronPathString isDirectory:TRUE]];
}

- (IBAction)showPreferencesTab:(id)sender {
    [tabView selectTabViewItemWithIdentifier:@"1"];
}

- (IBAction)showPathsTab:(id)sender {
    [tabView selectTabViewItemWithIdentifier:@"2"];
}

- (IBAction)showAdvancedTab:(id)sender {
    [tabView selectTabViewItemWithIdentifier:@"3"];
}

- (IBAction)changedValues:(id)sender {
    generalPathString = [[generalPath URL] path];
    pronPathString = [[pronPath URL] path];
    [[NSUserDefaults standardUserDefaults] setObject:generalPathString forKey:@"standardPath"];
    [[NSUserDefaults standardUserDefaults] setObject:pronPathString forKey:@"pronPath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
