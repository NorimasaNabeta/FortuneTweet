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

@interface TWListTableViewController ()

@end

@implementation TWListTableViewController
@synthesize fortuneDatabase=_fortuneDatabase;

@synthesize accounts=_accounts;
@synthesize accountStore=_accountStore;

- (ACAccountStore*) accountStore
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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterList"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.fortuneDatabase.managedObjectContext
                                                                          sectionNameKeyPath:nil
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
                                            [self useDocument];
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

- (void)useDocument
{
    NSLog(@"useDocument: %@", [self.fortuneDatabase.fileURL path]);
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.fortuneDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.fortuneDatabase saveToURL:self.fortuneDatabase.fileURL
                       forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                           [self setupFetchedResultsController];
                           [self fetchTwitterDataIntoDocument:self.fortuneDatabase];
                           
                       }];
    } else if (self.fortuneDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.fortuneDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
    } else if (self.fortuneDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self setupFetchedResultsController];
    }
}
- (void)setFortuneDatabase:(UIManagedDocument *)fortuneDatabase
{
    if (_fortuneDatabase != fortuneDatabase) {
        _fortuneDatabase = fortuneDatabase;
        [self checkAccount];
    }
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
    TwitterList *twlist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setTwitterList:)]) {
        // use performSelector:withObject: to send without compiler checking
        // (which is acceptable here because we used introspection to be sure this is okay)
        [segue.destinationViewController performSelector:@selector(setTwitterList:) withObject:twlist];
    }
}


@end
