//
//  TwitterLineTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/31.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TwitterLineTableViewController.h"
#import "TwitterAPI.h"

@interface TwitterLineTableViewController ()
- (void)fetchData;
@property (nonatomic,strong) NSMutableDictionary *threadList;
@end

@implementation TwitterLineTableViewController
@synthesize threadList=_threadList;

@synthesize account=_account;
@synthesize timeline=_timeline;
@synthesize slug=_slug;
@synthesize delegate=_delegate;

/*
 */
- (void) setSlug:(NSString *)slug
{
    if (_slug != slug) {
        _slug = slug;
    }
    [self fetchData];
}
- (void) setAccount:(ACAccount *)account
{
    if (_account != account) {
        _account = account;
        // NSLog(@"TL: %@", account.username);
    }
}

- (NSMutableDictionary*) threadList
{
    if(_threadList == nil){
        _threadList = [[NSMutableDictionary alloc] initWithObjectsAndKeys: nil];
    }
    return _threadList;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Data management

- (void)fetchData
{
    [_refreshHeaderView refreshLastUpdatedDate];
    TWRequest *request;
    if ([self.slug isEqualToString:@"timeline"]) {
        request = [TwitterAPI getStatusHomeTimeLine:self.account];
    } else {
        request = [TwitterAPI getListsStatuses:self.account slug:self.slug];
    }
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.timeline = jsonResult;
                    [self.tableView reloadData];
                });
            }
            else {
                NSString *message = [NSString stringWithFormat:@"Could not parse your timeline: %@", [jsonError localizedDescription]];
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:message
                                           delegate:nil
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:nil] show];
            }
        }
    }];
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];  // Need a delay here otherwise it gets called to early and never finishes.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.timeline count];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Line Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    id tweet = [self.timeline objectAtIndex:[indexPath row]];
    NSString* tweetscreenuser = [tweet valueForKeyPath:@"user.screen_name"];
    NSString* tweetuser = [tweet valueForKeyPath:@"user.name"];
    
    cell.textLabel.text = [tweet objectForKey:@"text"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ @%@",tweetuser, tweetscreenuser];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self.delegate lineViewController:self imageForTweet:tweet];
        
        // [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]]; // simulate 2 sec latency
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = image;
        });
    });
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
