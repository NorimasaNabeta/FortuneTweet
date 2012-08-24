//
//  TWListTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TWListTableViewController.h"
#import "TwitterList.h"
#import "TwitterAPI.h"
#import "TwitterList+Twitter.h"
#import "ManagedDocumentHelper.h"

@interface TWListTableViewController ()

@end

@implementation TWListTableViewController
@synthesize accountStore=_accountStore;
@synthesize accounts=_accounts;

- (ACAccountStore *) accountStore
{
    if (_accountStore == nil) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterList"];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *owner = [[NSSortDescriptor alloc] initWithKey:@"owner" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sort1, owner, nil];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:sharedDocument.managedObjectContext
                                                                          sectionNameKeyPath:@"owner"
                                                                                   cacheName:nil];
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


- (void)fetchTwitterDataIntoDocument:(UIManagedDocument *)document
{
    NSLog(@"fetchTwitterDataIntoDocument");
    if (self.accounts == nil) {
        NSLog(@"fetchTwitterDataIntoDocument:failed");
        return;
    }
    dispatch_queue_t fetchQ = dispatch_queue_create("Twitter fetcher", NULL);
    for(ACAccount *account in self.accounts) {
        dispatch_async(fetchQ, ^{
            TWRequest *request=[TwitterAPI getListsAll:account];
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                NSLog(@"Result");
                if ([urlResponse statusCode] == 200) {
                    NSError *jsonError = nil;
                    id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    if (jsonResult != nil) {
                        NSLog(@"ADD ENTITIES");
                        for (id tweet in jsonResult){
                        [document.managedObjectContext performBlock:^{
                            [TwitterList listWithTwitterAccount:account listAll:tweet inManagedObjectContext:document.managedObjectContext];
                            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
                        }];
                        }
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
        });
    }
    dispatch_release(fetchQ);
    
 }

- (void)useDocument:(UIManagedDocument*) sharedDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[sharedDocument.fileURL path]]) {
        NSLog(@"useDocument:New %@", [sharedDocument.fileURL path]);
        // does not exist on disk, so create it
        [sharedDocument saveToURL:sharedDocument.fileURL
                       forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                           [self setupFetchedResultsController];
                           [self fetchTwitterDataIntoDocument:sharedDocument];                           
                       }];
    } else if (sharedDocument.documentState == UIDocumentStateClosed) {
        NSLog(@"useDocument:Open %@", [sharedDocument.fileURL path]);
        // exists on disk, but we need to open it
        [sharedDocument openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
    } else if (sharedDocument.documentState == UIDocumentStateNormal) {
        NSLog(@"useDocument:Ready %@", [sharedDocument.fileURL path]);
        // already open and ready to use
        [self setupFetchedResultsController];
        // [self fetchTwitterDataIntoDocument:sharedDocument];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkAccount];
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Twitter List Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TwitterList *twlist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = twlist.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] %@ by %@", twlist.mode, twlist.descriptions, twlist.owner];
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    ACAccount *account = [self.accounts objectAtIndex:0];
    TwitterList *twlist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setTwitterList:)]) {
        [segue.destinationViewController performSelector:@selector(setTwitterList:) withObject:twlist];
        [segue.destinationViewController performSelector:@selector(setAccount:) withObject:account];

    }
}


@end
