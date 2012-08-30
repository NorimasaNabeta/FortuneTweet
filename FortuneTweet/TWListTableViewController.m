//
//  TWListTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "TWListTableViewController.h"
#import "AppDelegate.h"
#import "TwitterAPI.h"
#import "TwitterList.h"
#import "TwitterList+Twitter.h"
#import "TwitterUser.h"
#import "TwitterUser+Twitter.h"
#import "FortuneBook.h"
#import "FortuneBook+Twitter.h"

#import "ManagedDocumentHelper.h"
// #import "UserListTableViewController.h"

@interface TWListTableViewController () // <UserListTableViewControllerDelegate>
@property (nonatomic,strong) NSMutableDictionary *threadList;
@end

@implementation TWListTableViewController
@synthesize accountStore=_accountStore;
@synthesize accounts=_accounts;
@synthesize threadList=_threadList;

- (ACAccountStore *) accountStore
{
    if (_accountStore == nil) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}


// attaches an NSFetchRequest to this UITableViewController
- (void)setupFetchedResultsController
{
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterList"];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES
                                                             selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *owner = [NSSortDescriptor sortDescriptorWithKey:@"ownername" ascending:YES
                                                             selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObjects:owner, sort1, nil];
    // no predicate because we want ALL the Photographers
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:sharedDocument.managedObjectContext
                                                                          sectionNameKeyPath:@"ownername"
                                                                                   cacheName:nil];
}


- (void) checkAccount
{
    if (_accounts == nil) {
        [self spinnerAction:YES];
        ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter
                                     withCompletionHandler:^(BOOL granted, NSError *error) {
                                         if(granted) {
                                             self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
                                             UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
                                             /// [self useDocument:sharedDocument];
                                             [ManagedDocumentHelper useDocument:sharedDocument usingBlock: ^(BOOL success){
                                                 [self setupFetchedResultsController];
                                                 [self fetchTwitterDataIntoDocument:sharedDocument];}
                                                                   debugComment:@"TW"];
                                         } else {
                                             NSLog(@"ACCOUNT FAILED OR NOT GRANTED.");
                                         }
                                     }];
    }
}


- (void) fetchListMembers:(NSDictionary *) jsonResult
{
    dispatch_queue_t fetchQ2 = dispatch_queue_create("Twitter fetcher2", NULL);
    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
    ACAccount *account = [self.accounts objectAtIndex:0];
    
    dispatch_async(fetchQ2, ^{
        for (id listResult in jsonResult) {
            NSString *screen_name = [listResult valueForKeyPath:@"user.screen_name"];
            NSString *slug = [listResult objectForKey:@"slug"];
            TWRequest *request = [TwitterAPI getListsMembers:account slug:slug owner:screen_name];
            // NSLog(@"[1] List: %@ %@ %@", screen_name, slug, account.username);
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                // NSLog(@"[2] List: %d %@", [urlResponse statusCode],[error localizedDescription]);
                if ([urlResponse statusCode] == 200) {
                    NSError *error;
                    id result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                    if (result != nil) {
                        // NSLog(@"MEMBER[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), result);
                        NSDictionary *chk = [result valueForKeyPath:@"users"];
                        // NSLog(@"[3] List: %@ %@%d", account.username, slug, [chk count]);
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [sharedDocument.managedObjectContext performBlock:^{
                                
                                // TODO: Resident user accounts and default list(a.k. TimeLine) will be added into the database.
                                // list:                                
                                [TwitterList listWithTwitterAccount:listResult members:chk inManagedObjectContext:sharedDocument.managedObjectContext];
                                [sharedDocument saveToURL:sharedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
                            }];
                            [self spinnerAction:NO];
                            // [self.tableView reloadData];
                        });
                    } else {
                        [self spinnerAction:NO];
                        NSString *message = [NSString stringWithFormat:@"Could not parse your timeline: %@", [error localizedDescription]];
                        [[[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil] show];
                        
                    }
                    
                } else {
                }
            }];
        }
    });
    dispatch_release(fetchQ2);
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
                if ([urlResponse statusCode] == 200) {
                    NSError *jsonError = nil;
                    id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    if (jsonResult != nil) {
                        // NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), jsonResult);
                        [self fetchListMembers:jsonResult];
                    }
                    else {
                        [self spinnerAction:NO];
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

- (void) spinnerAction: (BOOL) start
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(start){
            // NSLog(@"Spinner Start");
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinner startAnimating];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        } else {
            // NSLog(@"Spinner End");
            self.navigationItem.leftBarButtonItem = nil;
            [self.tableView reloadData];
        }
    });
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@ [%d]", twlist.title, [twlist.users count]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] %@ by %@", twlist.mode, twlist.descriptions, twlist.ownername];
  
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    UIImage *image = [[appDelegate imageCache] objectForKey:twlist.ownername];
    
    // UIImage *image = [UIImage imageWithData:user.profileImageBob];
    if (image) {
        // NSLog(@"Hit: %@", account.username);
        cell.imageView.image = image;
    }
    else {
        NSString *valid = [self.threadList objectForKey:twlist.ownername];
        if (valid == nil) {
            [self.threadList setObject:@"ON" forKey:twlist.ownername];
            ACAccount *account;
            TWRequest *fetchUserImageRequest = [TwitterAPI getUsersProfileImage:account screenname:twlist.ownername];
            [fetchUserImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if ([urlResponse statusCode] == 200) {
                    UIImage *image = [UIImage imageWithData:responseData];
                    [[appDelegate imageCache] setObject:image forKey:twlist.ownername];
                    // NSData *imageBob = UIImagePNGRepresentation(image);
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        // user.profileImageBob = imageBob;
                        [self.threadList removeObjectForKey:twlist.ownername];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
                    });
                }
            }];
        }
    }

    return cell;
}



 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 

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

// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source

        // following code should be executed after Twitter reqest return successfully.
        // -->>
        TwitterList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[ManagedDocumentHelper sharedManagedDocumentFortuneTweet].managedObjectContext performBlock:^{
            [self.fetchedResultsController.managedObjectContext deleteObject:list];
        }];
        // --<<
        
        // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    TwitterList *twlist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setTwitterList:)]) {
        [segue.destinationViewController performSelector:@selector(setTwitterList:) withObject:twlist];
    }
}

/*
#pragma mark - UserListTableViewControllerDelegate
- (UIImage *)userListController:(UserListTableViewController *)sender imageForUser:(TwitterUser *)user
{
//    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
//    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
//    NSData *data = [NSData dataWithContentsOfURL:url];
    
    return data ? [UIImage imageWithData:data] : nil;
}
*/

@end
