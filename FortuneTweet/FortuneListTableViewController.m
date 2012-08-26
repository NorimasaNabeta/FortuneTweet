//
//  FortuneListTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//
#import <Twitter/Twitter.h>

#import "FortuneListTableViewController.h"
#import "FortuneListTableCell.h"
#import "ManagedDocumentHelper.h"
#import "Fortune.h"
#import "History.h"
#import "History+CLLocation.h"

#import "SectionInfo.h"

@interface FortuneListTableViewController ()
@property (nonatomic, strong) NSIndexPath* pinchedIndexPath;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) CGFloat initialPinchHeight;
@property (nonatomic, assign) NSInteger uniformRowHeight;
@property (nonatomic, strong) NSMutableArray* sectionInfoArray;
@end

@implementation FortuneListTableViewController
@synthesize fortunebook=_fortunebook;

#define DEFAULT_ROW_HEIGHT 78
#define HEADER_HEIGHT 45

@synthesize pinchedIndexPath=_pinchedIndexPath;
@synthesize openSectionIndex=_openSectionIndex;
@synthesize initialPinchHeight=_initialPinchHeight;
@synthesize uniformRowHeight=_uniformRowHeight;
@synthesize sectionInfoArray=_sectionInfoArray;

-(void) setSectionInfoArray:(NSMutableArray *)sectionInfoArray
{
    if(_sectionInfoArray != sectionInfoArray){
        _sectionInfoArray = sectionInfoArray;
        [self.tableView reloadData];
    }
}


- (void)setFortunebook:(FortuneBook *)fortunebook
{
    if (_fortunebook != fortunebook){
        _fortunebook = fortunebook;
    }
    self.title = [NSString stringWithFormat:@"%@", fortunebook.title];
    [self setupFetchedResultsController];
    [self.tableView reloadData];
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    // UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Fortune"];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"character" ascending:YES
                                                             selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"act" ascending:YES
                                                             selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObjects:sort1, sort2, nil];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.fortunebook.managedObjectContext
                                                                          sectionNameKeyPath:@"character"
                                                                                   cacheName:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    // [self.tableView addGestureRecognizer:pinchRecognizer];
    self.tableView.sectionHeaderHeight = HEADER_HEIGHT;
    self.uniformRowHeight=DEFAULT_ROW_HEIGHT;
    self.openSectionIndex= NSNotFound;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//
//
//
-(BOOL)canBecomeFirstResponder {
     return YES;
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if ((self.sectionInfoArray == nil) ||
        ([self.sectionInfoArray count] != [self numberOfSectionsInTableView:nil])) {
        
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
        for (NSInteger sec = 0; sec <[self numberOfSectionsInTableView:nil]; sec++) {
			SectionInfo *sectionInfo = [[SectionInfo alloc] init];
			// sectionInfo.title = [self titleCookedForHeaderInSection:sec];
			// sectionInfo.titleRaw = [self tableView:nil titleForHeaderInSection:sec];
			sectionInfo.open = YES;
            NSNumber *defaultRowHeight = [NSNumber numberWithInteger:DEFAULT_ROW_HEIGHT];
            NSInteger countOfQuotations = [self.tableView numberOfRowsInSection:sec];
			for (NSInteger i = 0; i < countOfQuotations; i++) {
				[sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
			}
			// NSLog(@"%d: [%d/%d]", sec, countOfQuotations, sectionInfo.countOfRowHeights);
			[infoArray addObject:sectionInfo];
		}
		self.sectionInfoArray = infoArray;
        
	}
}

//
//
//

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Fortune Cell";
    FortuneListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[FortuneListTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // cell.textLabel.numberOfLines = 3;
        // cell.textLabel.adjustsFontSizeToFitWidth=NO;
    }
    
    Fortune *fortune = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // cell.textLabel.text = [NSString stringWithFormat:@"%@", fortune.quotation];
    // cell.detailTextLabel.text = [NSString stringWithFormat:@"-- %@ %@%d",
     //                             fortune.act, fortune.scene,
     //                             [fortune.tweets count]];
    NSString *html = [NSString stringWithFormat:@"<html><head><meta name=""viewport"" content=""width=300""/></head><body>%@<p><p>-- %@<p>%@</body</html>", fortune.quotation, fortune.act, fortune.scene];
    [cell.contentWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.apple.com"]];
    
    return cell;
}

#pragma mark - Table view delegate
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    //[tweetViewController addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
    //[tweetViewController addURL:[NSURL URLWithString:[NSString stringWithString:@"http:/MobileDeveloperTips.com/"]]];
    //[tweetViewController setInitialText:@"Tweet from iOS 5 app using the Twitter framework."];
    //[tweetViewController setInitialText:@"Hello. This is a tweet."];
    
    Fortune *fortune = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *preinput = [NSString stringWithFormat:@"  (%@ -- %@,%@)",
                          fortune.quotation, fortune.character, fortune.act];
    [tweetViewController setInitialText:preinput];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        if (result == TWTweetComposeViewControllerResultDone){
                CLLocation *location = [self.delegate locationOfTweetController:self];
                if (location) {
                    [self.fortunebook.managedObjectContext performBlock:^{
                        // Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
                        [History historyWithCLLocation:location fortuneTweet:fortune inManagedObjectContext:self.fortunebook.managedObjectContext];
                        // [sharedDocument saveToURL:sharedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
                    }];
                }
        }
        // -----
        // Show alert to see how things went...
        // UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        // [alertView show];
        // -----
        
        // Dismiss the controller
        [self dismissModalViewControllerAnimated:YES];
        // Dismiss the tweet composition view controller.
        [self dismissModalViewControllerAnimated:YES];
    }];
    [self presentModalViewController:tweetViewController animated:YES];

}


-(CGFloat)      tableView:(UITableView*)tableView
  heightForRowAtIndexPath:(NSIndexPath*)indexPath {
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
    return [[sectionInfo objectInRowHeightsAtIndex:indexPath.row] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"sec=%d,row=%d", indexPath.section, indexPath.row);
    for (NSInteger sidx=0; sidx<[self.sectionInfoArray count]; sidx++) {
        SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sidx];
        for (NSInteger i = 0; i < sectionInfo.rowHeights.count; i++) {
            if((i == indexPath.row) && (sidx == indexPath.section)){
                if([[sectionInfo objectInRowHeightsAtIndex:i] doubleValue] != DEFAULT_ROW_HEIGHT){
                    [sectionInfo replaceObjectInRowHeightsAtIndex:i withObject:[NSNumber numberWithFloat:DEFAULT_ROW_HEIGHT]];
                } else {
                    [sectionInfo replaceObjectInRowHeightsAtIndex:i withObject:[NSNumber numberWithFloat:DEFAULT_ROW_HEIGHT*2]];
                }
            } else {
                [sectionInfo replaceObjectInRowHeightsAtIndex:i withObject:[NSNumber numberWithFloat:DEFAULT_ROW_HEIGHT]];
            }
        }
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark Handling pinches
-(void)handlePinch:(UIPinchGestureRecognizer*)pinchRecognizer
{
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint pinchLocation = [pinchRecognizer locationInView:self.tableView];
        NSIndexPath *newPinchedIndexPath = [self.tableView indexPathForRowAtPoint:pinchLocation];
		self.pinchedIndexPath = newPinchedIndexPath;
        
		SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:newPinchedIndexPath.section];
        self.initialPinchHeight = [[sectionInfo objectInRowHeightsAtIndex:newPinchedIndexPath.row] floatValue];
        // Alternatively, set initialPinchHeight = uniformRowHeight.
        
        [self updateForPinchScale:pinchRecognizer.scale atIndexPath:newPinchedIndexPath];
    }
    else {
        if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
            [self updateForPinchScale:pinchRecognizer.scale atIndexPath:self.pinchedIndexPath];
        }
        else if ((pinchRecognizer.state == UIGestureRecognizerStateCancelled) ||
                 (pinchRecognizer.state == UIGestureRecognizerStateEnded)) {
            self.pinchedIndexPath = nil;
        }
    }
}


-(void)updateForPinchScale:(CGFloat)scale
               atIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath && (indexPath.section != NSNotFound) && (indexPath.row != NSNotFound)) {
        
		CGFloat newHeight = round(MAX(self.initialPinchHeight * scale, DEFAULT_ROW_HEIGHT));
        
        if(newHeight < DEFAULT_ROW_HEIGHT *3){
            SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
            [sectionInfo replaceObjectInRowHeightsAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:newHeight]];
            // Alternatively, set uniformRowHeight = newHeight.
            
            /*
             Switch off animations during the row height resize,
             otherwise there is a lag before the user's action is seen.
             */
            BOOL animationsEnabled = [UIView areAnimationsEnabled];
            [UIView setAnimationsEnabled:NO];
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            [UIView setAnimationsEnabled:animationsEnabled];
        }
    }
}


@end
