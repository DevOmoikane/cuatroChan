//
//  AppDelegate.m
//  cuatroChan
//
//  Created by Israel Cabrera on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define restrict
#import <RegexKit/RegexKit.h>
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"


@interface AppDelegate ()
-(void)mainPageDataDownloadSucceded:(ASIHTTPRequest*)request;
-(void)subPageDataDownloadSucceded:(ASIHTTPRequest*)request;
-(void)thumbDataDownloadSucceded:(ASIHTTPRequest*)request;
-(void)thumbDataDownloadFailed:(ASIHTTPRequest*)request;
-(void)imageDataDownloadSucceded:(ASIHTTPRequest*)request;
-(void)loadPrevImageSucceded:(ASIHTTPRequest*)request;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize prefControl;

-(id)init{
    self = [super init];
    if(self){
        generalPath = [[NSUserDefaults standardUserDefaults] valueForKey:@"standardPath"];
        pronPath = [[NSUserDefaults standardUserDefaults] valueForKey:@"pronPath"];
    }
    return self;
}

- (void)dealloc
{
    [prefControl release];
    [content release];
    [categLinks release];
    [categNames release];
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    categNames = [[NSArray alloc] initWithObjects:@"Anime & Manga", @"Random", @"Anime/Cute", @"Hentai/Alternative", @"Ecchi", @"Animated GIF", @"Hentai", @"High Resolution", @"Weapons", @"Mecha", @"Auto", @"Photo", @"Request", @"Sexy Beautiful Women", @"Yuri", @"Video Games", @"Video Game Generals", @"Anime/Wallpapers", @"Wallpapers/General", nil];
    categLinks = [[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"gif", @"h", @"hr", @"k", @"m", @"o", @"p", @"r", @"s", @"u", @"v", @"vg", @"w", @"wg", nil];
    
    [cbcCategories addItemsWithObjectValues:categNames];
    content = [[NSMutableArray alloc] init];
    
    //[content addObject:[NSImage imageNamed:NSImageNameUser]];
    
    [collView reloadData];
    [collView setCellSize:NSMakeSize(60.0, 60.0)];
    [collView setPadSize:10];
    
    operationQueue = [[NSOperationQueue alloc] init];
}

- (IBAction)showPreferences:(id)sender{
    if(!self.prefControl){
        self.prefControl = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
    }
    [self.prefControl showWindow:self];
}

- (NSUInteger) numberOfCellsInCollectionView:(JUCollectionView *)collectionView {
    return [content count];
}

- (JUCollectionViewCell*)collectionView:(JUCollectionView *)cview cellForIndex:(NSUInteger)index {
    JUCollectionViewCell *cell = [cview dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell) cell=[[[JUCollectionViewCell alloc] initWithReuseIdentifier:@"cell"] autorelease];
    NSDictionary *dic = [content objectAtIndex:index];
    NSImage *img = [dic objectForKey:@"image"];
    [cell setImage:img];
    return cell;
}

- (void)collectionView:(JUCollectionView*)cview didSelectCellAtIndex:(NSUInteger)index {
    NSDictionary *dic = [content objectAtIndex:index];
    [prevImage setImage:[dic objectForKey:@"image"]];
    currIdxSelected = index;
}

- (void)collectionView:(JUCollectionView*)cview didDoubleClickedCellAtIndex:(NSUInteger)index {
    NSDictionary *dic = [content objectAtIndex:index];
    NSString *downloadURL = [dic objectForKey:@"fullURL"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(imageDataDownloadSucceded:)];
    [operationQueue addOperation:request];
}

- (IBAction)selectCategory:(id)sender {
    [content removeAllObjects];
    selectedCategory = [categLinks objectAtIndex:([cbcCategories indexOfSelectedItem])];
    [priProgress setMaxValue:1.0];
    [priProgress setDoubleValue:0.0];
    currIdxSelected = -1;
    NSString *downloadURL;
    for(int i=NUMBER_OF_SUBPAGES; i>=0; i--){
        downloadURL = [NSString stringWithFormat:@"%@/%@/%d",MAIN_4CHAN_URL,selectedCategory,i ];
        //NSLog(@"Downloading: %@",downloadURL);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:downloadURL]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(mainPageDataDownloadSucceded:)];
        [operationQueue addOperation:request];
    }
}

-(void)mainPageDataDownloadSucceded:(ASIHTTPRequest*)request{
    //NSLog(@"%@",[request responseString]);
    NSString *downURL;
    NSString *regexString = @"\\[<a href=\"(res\\/\\d+)\">Reply<\\/a>\\]";
    RKEnumerator *matches = [[request responseString] matchEnumeratorWithRegex:regexString];
    while([matches nextRanges] != NULL){
        NSString *obtained;
        [matches getCapturesWithReferences:@"${1}", &obtained, nil];
        //NSLog(@"Found: %@",obtained);
        downURL = [NSString stringWithFormat:@"%@/%@/%@",MAIN_4CHAN_URL,selectedCategory,obtained];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:downURL]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(subPageDataDownloadSucceded:)];
        [operationQueue addOperation:request];
    }
}
-(void)subPageDataDownloadSucceded:(ASIHTTPRequest*)request{
    NSString *fullRegexString = @"File: <a href=\"(.+)\" target=\"_blank\">";
    NSString *prevRegexString = @"target=_blank><img src=(.+s\\..+) border=0";
    NSMutableArray *fullURLs = [[NSMutableArray alloc] init];
    NSMutableArray *thumURLs = [[NSMutableArray alloc] init];
    RKEnumerator *prevM = [[request responseString] matchEnumeratorWithRegex:prevRegexString];
    while([prevM nextRanges]!=NULL){
        NSString *prevURL;
        [prevM getCapturesWithReferences:@"${1}",&prevURL, nil];
        [thumURLs addObject:prevURL];
        //NSLog(@"Added thumb: %@",prevURL);
    }
    RKEnumerator *fullM = [[request responseString] matchEnumeratorWithRegex:fullRegexString];
    while([fullM nextRanges]!=NULL){
        NSString *fullURL;
        [fullM getCapturesWithReferences:@"${1}",&fullURL, nil];
        [fullURLs addObject:fullURL];
        //NSLog(@"Added full Image: %@",fullURL);
    }
    unsigned long numImgs = [thumURLs count];
    [priProgress setMaxValue:[priProgress maxValue]+numImgs];
    //NSLog(@"Number of images: %ld",numImgs);
    for(int i=0; i < numImgs; i++){
        NSString *prevURL = [thumURLs objectAtIndex:i];
        NSNumber *num = [NSNumber numberWithInt:i];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[fullURLs objectAtIndex:i] forKey:@"fullURL"];
        [dic setObject:prevURL forKey:@"thumbURL"];
        [dic setObject:num forKey:@"index"];
        
        //NSLog(@"Going to Download: %@",prevURL);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:prevURL]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(thumbDataDownloadSucceded:)];
        [request setDidFailSelector:@selector(thumbDataDownloadFailed:)];
        [request setUserInfo:dic];
        [operationQueue addOperation:request];
    }
    [fullURLs release];
    [thumURLs release];
}
-(void)thumbDataDownloadSucceded:(ASIHTTPRequest*)request{
    NSImage *img = [[NSImage alloc] initWithData:[request responseData]];
    if(img!=nil){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[request userInfo]];
        [dic setObject:img forKey:@"image"];
        //NSLog(@"Downloaded: %@",[dic objectForKey:@"thumbURL"]);
        [content addObject:dic];
        [collView reloadData];
    }
    [priProgress incrementBy:1.0];
}
-(void)thumbDataDownloadFailed:(ASIHTTPRequest*)request{
    [priProgress incrementBy:1.0];
}
-(void)imageDataDownloadSucceded:(ASIHTTPRequest*)request{
    //NSImage *img = [[NSImage alloc] initWithData:[request responseData]];
    NSString *url = [[request url] absoluteString];
    NSArray *parts = [url componentsSeparatedByString:@"/"];
    NSString *filename = [parts objectAtIndex:[parts count]-1];
    NSString *fullPath;
    generalPath = [[NSUserDefaults standardUserDefaults] valueForKey:@"standardPath"];
    pronPath = [[NSUserDefaults standardUserDefaults] valueForKey:@"pronPath"];
    if([cbxPron state] == NSOnState)
        fullPath = [NSString stringWithFormat:@"%@/%@",pronPath,filename];
    else
        fullPath = [NSString stringWithFormat:@"%@/%@",generalPath,filename];
    [[request responseData] writeToFile:fullPath atomically:FALSE];
}

-(void)loadPrevImageSucceded:(ASIHTTPRequest*)request {
    NSImage *img = [[NSImage alloc] initWithData:[request responseData]];
    [prevImage setImage:img];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)ShowHRPreview:(id)sender {
    NSDictionary *dic = [content objectAtIndex:currIdxSelected];
    NSString *downloadURL = [dic objectForKey:@"fullURL"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(loadPrevImageSucceded:)];
    [operationQueue addOperation:request];
}
@end
