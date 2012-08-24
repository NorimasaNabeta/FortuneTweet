//
//  HistoryListTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//
#import <Accounts/Accounts.h>
#import "HistoryListTableViewController.h"
#import "History.h"
#import "History+CLLocation.h"
#import "ManagedDocumentHelper.h"

@interface HistoryListTableViewController ()
@end

@implementation HistoryListTableViewController
@synthesize accountStore=_accountStore;
@synthesize accounts=_accounts;

- (void)setupFetchedResultsController
{
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sort1];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:sharedDocument.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


- (void)locationDataIntoDocument:(UIManagedDocument *)document
{
    NSLog(@"locationDataIntoDocument");
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
//    dispatch_queue_t fetchQ = dispatch_queue_create("Twitter fetcher", NULL);
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:37.733 longitude:-122.41];
    [sharedDocument.managedObjectContext performBlock:^{
        [History historyWithCLLocation:newLocation inManagedObjectContext:sharedDocument.managedObjectContext];
        [sharedDocument saveToURL:sharedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }];
//    dispatch_release(fetchQ);
    
}

- (void)useDocument:(UIManagedDocument*) sharedDocument
{
    //NSLog(@"useDocument: %@", [self.fortuneDatabase.fileURL path]);
    if (![[NSFileManager defaultManager] fileExistsAtPath:[sharedDocument.fileURL path]]) {
        // does not exist on disk, so create it
        [sharedDocument saveToURL:sharedDocument.fileURL
                       forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                           NSLog(@"[H]New: useDocument %@", [sharedDocument.fileURL path]);
                           [self setupFetchedResultsController];
                           //[self locationDataIntoDocument:self.fortuneDatabase];
                           
                       }];
    } else if (sharedDocument.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [sharedDocument openWithCompletionHandler:^(BOOL success) {
            NSLog(@"[H]Open: useDocument %@", [sharedDocument.fileURL path]);
            [self setupFetchedResultsController];
            //[self locationDataIntoDocument:self.fortuneDatabase];
        }];
    } else if (sharedDocument.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        NSLog(@"[H]Ready: useDocument %@", [sharedDocument.fileURL path]);
        [self setupFetchedResultsController];
        //[self locationDataIntoDocument:self.fortuneDatabase];
    }
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

- (ACAccountStore *) accountStore
{
    if (_accountStore == nil) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (void) checkAccount
{
    if (_accounts == nil) {
        ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter
                                     withCompletionHandler:^(BOOL granted, NSError *error) {
                                         if(granted) {
                                             self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
                                             [self useDocument:[ManagedDocumentHelper sharedManagedDocumentFortuneTweet]];
                                         } else {
                                             NSLog(@"ACCOUNT FAILED OR NOT GRANTED.");
                                         }
                                     }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkAccount];
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        History *hist = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:hist];
        // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
