//
//  FortuneListTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneListTableViewController.h"
#import "ManagedDocumentHelper.h"
#import "Fortune.h"

@interface FortuneListTableViewController ()

@end

@implementation FortuneListTableViewController
@synthesize fortunebook=_fortunebook;

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Fortune Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Fortune *fortune = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", fortune.quotation];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"-- %@ %@%d",
                                 fortune.act, fortune.scene,
                                 [fortune.tweets count]];

    return cell;
}

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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
