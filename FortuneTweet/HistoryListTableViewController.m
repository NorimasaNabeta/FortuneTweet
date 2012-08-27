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
#import "HistoryAnnotation.h"

@interface HistoryListTableViewController ()
@end

@implementation HistoryListTableViewController
@synthesize accountStore=_accountStore;
@synthesize accounts=_accounts;

- (void)setupFetchedResultsController
{
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort1];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:sharedDocument.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

/*
- (void)locationDataIntoDocument:(UIManagedDocument *)document
{
    NSLog(@"locationDataIntoDocument");
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
//    dispatch_queue_t fetchQ = dispatch_queue_create("Twitter fetcher", NULL);
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:37.733 longitude:-122.41];
    [sharedDocument.managedObjectContext performBlock:^{
        [History historyWithCLLocation:newLocation fortuneTweet:nil inManagedObjectContext:sharedDocument.managedObjectContext];
        [sharedDocument saveToURL:sharedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }];
//    dispatch_release(fetchQ);
    
}
*/

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
                                             UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
                                             /// [self useDocument:sharedDocument];
                                             [ManagedDocumentHelper useDocument:sharedDocument
                                                                     usingBlock: ^(BOOL success){
                                                                         [self setupFetchedResultsController];
                                                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                                                             [self.tableView reloadData];
                                                                         });

                                                                     }
                                                                   debugComment:@"HT"];
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    History *hist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // cell.textLabel.text = [NSString stringWithFormat:@"[lat=%@, long=%@]", hist.latitude, hist.longitude];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", hist.timestamp];

    //
    // address-fetching is required the network environment, but this application's purpose is outdoor environment,
    // mostly you cannot reatch any network.
    // because of this concern, eliminating unefficent network trafic, here.
    if( hist.address ){
        cell.detailTextLabel.text = hist.address;
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"[lat=%@, long=%@]", hist.latitude, hist.longitude];
        CLGeocoder *fgeo = [[CLGeocoder alloc] init];
        CLLocation *pnt = [[CLLocation alloc] initWithLatitude:[hist.latitude doubleValue] longitude:[hist.longitude doubleValue]];
        [fgeo reverseGeocodeLocation:pnt
               completionHandler:^(NSArray *placemarks, NSError *error){
                   if(!error){
                       NSString *address = [[placemarks objectAtIndex:0] description];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           cell.detailTextLabel.text = address;
                           [[ManagedDocumentHelper sharedManagedDocumentFortuneTweet].managedObjectContext performBlock:^{
                               hist.address = address;
                           }];
                       });
                   } else {
                       NSLog(@"There was a reverse geocoding error\n%@",[error localizedDescription]);
                       
                   }
               }];
    }
    
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
        [[ManagedDocumentHelper sharedManagedDocumentFortuneTweet].managedObjectContext performBlock:^{
            [self.fetchedResultsController.managedObjectContext deleteObject:hist];
        }];
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
    
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithObjects:nil];
    for (History* tweet in hist.fortune.tweets){
        HistoryAnnotation *annotation = [HistoryAnnotation annotationForHistory:hist];
        if (annotation){
            [annotations addObject:annotation];
        }
    }
    // HistoryAnnotation *annotation = [HistoryAnnotation annotationForHistory:hist];
    // NSArray *annotations = [[NSArray alloc] initWithObjects:annotation, nil ];
    if ([segue.destinationViewController respondsToSelector:@selector(setAnnotations:)]) {
        [segue.destinationViewController performSelector:@selector(setAnnotations:) withObject:annotations];
    }
}

@end
