//
//  AppDelegate.h
//  cuatroChan
//
//  Created by Israel Cabrera on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "collview/JUCollectionView.h"
#import "PreferencesController.h"

#define MAIN_4CHAN_URL @"http://boards.4chan.org"
#define NUMBER_OF_SUBPAGES 16

@interface AppDelegate : NSObject <NSApplicationDelegate, JUCollectionViewDataSource> {
    IBOutlet JUCollectionView *collView;
    IBOutlet NSComboBoxCell *cbcCategories;
    IBOutlet NSButton *cbxPron;
    IBOutlet NSProgressIndicator *priProgress;
    IBOutlet NSImageView *prevImage;
    NSMutableArray *content;
    NSInteger currIdxSelected;
    NSArray *categNames;
    NSArray *categLinks;
    NSOperationQueue *operationQueue;
    NSString *selectedCategory;
    NSString *generalPath;
    NSString *pronPath;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) PreferencesController *prefControl;

- (IBAction)selectCategory:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)ShowHRPreview:(id)sender;
@end
