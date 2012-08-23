//
//  HistoryListTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "HistoryListTableViewController.h"
#import "History.h"
#import "History+CLLocation.h"

@interface HistoryListTableViewController ()

@end

@implementation HistoryListTableViewController
@synthesize fortuneDatabase=_fortuneDatabase;

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.fortuneDatabase.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


- (void)locationDataIntoDocument:(UIManagedDocument *)document
{
    NSLog(@"locationDataIntoDocument");
//    dispatch_queue_t fetchQ = dispatch_queue_create("Twitter fetcher", NULL);
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:37.733 longitude:-122.41];
    [self.fortuneDatabase.managedObjectContext performBlock:^{
        [History historyWithCLLocation:newLocation inManagedObjectContext:self.fortuneDatabase.managedObjectContext];
        [self.fortuneDatabase saveToURL:self.fortuneDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }];
//    dispatch_release(fetchQ);
    
}

- (void)useDocument
{
    //NSLog(@"useDocument: %@", [self.fortuneDatabase.fileURL path]);
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.fortuneDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.fortuneDatabase saveToURL:self.fortuneDatabase.fileURL
                       forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                           NSLog(@"[H]useDocument:New %@", [self.fortuneDatabase.fileURL path]);
                           [self setupFetchedResultsController];
                           [self locationDataIntoDocument:self.fortuneDatabase];
                           
                       }];
    } else if (self.fortuneDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.fortuneDatabase openWithCompletionHandler:^(BOOL success) {
            NSLog(@"[H]useDocument:Open %@", [self.fortuneDatabase.fileURL path]);
            [self setupFetchedResultsController];
            [self locationDataIntoDocument:self.fortuneDatabase];
        }];
    } else if (self.fortuneDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        NSLog(@"[H]useDocument:Ready %@", [self.fortuneDatabase.fileURL path]);
        [self setupFetchedResultsController];
        [self locationDataIntoDocument:self.fortuneDatabase];
    }
}
- (void)setFortuneDatabase:(UIManagedDocument *)fortuneDatabase
{
    if (_fortuneDatabase != fortuneDatabase) {
        _fortuneDatabase = fortuneDatabase;
    }
    [self useDocument];
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.fortuneDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"FortuneDatabase"];
        self.fortuneDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
}

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
    static NSString *CellIdentifier = @"History Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    History *hist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"[lat=%@, long=%@]", hist.latitude, hist.longitude];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", hist.timestamp];
    
    
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

// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}


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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    History *hist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setHistory:)]) {
        [segue.destinationViewController performSelector:@selector(setHistory:) withObject:hist];
    }
}

@end
