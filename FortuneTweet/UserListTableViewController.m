//
//  UserListTableViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/23.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//


#import "UserListTableViewController.h"
#import "TwitterAPI.h"
#import "AppDelegate.h"
#import "TwitterUser.h"
@interface UserListTableViewController ()
// - (void)fetchData;
@end

@implementation UserListTableViewController
@synthesize twitterList=_twitterList;
@synthesize account=_account;


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TwitterUser"];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sort1];
    request.predicate = [NSPredicate predicateWithFormat:@"%@ in lists", self.twitterList];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.twitterList.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void) setTwitterList:(TwitterList *)twitterList
{
    if (_twitterList != twitterList){
        _twitterList = twitterList;
    }
    [self setupFetchedResultsController];
    
}
/*

- (void) fetchDataAux3:(ACAccount *)account userid:(NSArray*) ids
{
    TWRequest *request = [TwitterAPI getUsersLookup:account userids:[ids componentsJoinedByString:@","]];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *error;
            id result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (result != nil) {
                NSLog(@"[3] Friends: %@ %d", account.username, [result count]);
                // NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), result);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.friends setObject:result forKey:account.username];
                    NSMutableDictionary *dict = [self.ids mutableCopy];
                    for (int idx = 0; idx< [result count]; idx++) {
                        NSString* screen_name = [[result objectAtIndex:idx] objectForKey:@"screen_name"];
                        if (! [[dict allKeys] containsObject:screen_name]) {
                            [dict setObject:[result objectAtIndex:idx] forKey:screen_name];
                        } else {
                            // NSLog(@"Skip: %@", screen_name);
                        }
                    }
                    self.ids = dict;
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

// TODO: In case of over-100ids, you need the another procedure to handling this situtation.
//
- (void) fetchDataAux4:(ACAccount *)account userid:(NSArray*) ids
{
    TWRequest *request = [TwitterAPI getUsersLookup:account userids:[ids componentsJoinedByString:@","]];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *error;
            id result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (result != nil) {
                // NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), result);
                NSLog(@"[4] Followers: %@ %d", account.username, [result count]);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.followers setObject:result forKey:account.username];
                    NSMutableDictionary *dict = [self.ids mutableCopy];
                    for (int idx = 0; idx< [result count]; idx++) {
                        NSString* screen_name = [[result objectAtIndex:idx] objectForKey:@"screen_name"];
                        if (! [[dict allKeys] containsObject:screen_name]) {
                            [dict setObject:[result objectAtIndex:idx] forKey:screen_name];
                        } else {
                            // NSLog(@"Skip: %@", screen_name);
                        }
                    }
                    self.ids = dict;
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

// TODO: set this result into NSUserDefaults, as the dictionary for key screen_name.
-(void) fetchDataAux1:(ACAccount*) account
{
    TWRequest *request=[TwitterAPI getFriendsIds:account screenname:account.username];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil) {
                NSLog(@"[1] Friends: %@ %d", account.username, [[jsonResult objectForKey:@"ids"] count]);
                if( [[jsonResult objectForKey:@"ids"] count] > 0){
                    [self fetchDataAux3:account userid:[jsonResult objectForKey:@"ids"]];
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
    
}

// TODO: set this result into NSUserDefaults, as the dictionary for key screen_name.
- (void)fetchDataAux2:(ACAccount*)account
{
    TWRequest *request=[TwitterAPI getFollowersIds:account screenname:account.username];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil) {
                // [self.followerslist setObject:jsonResult forKey:account.username];
                NSLog(@"[2] Followers: %@ %d", account.username, [[jsonResult objectForKey:@"ids"] count]);
                if( [[jsonResult objectForKey:@"ids"] count] > 0 ){
                    [self fetchDataAux4:account userid:[jsonResult objectForKey:@"ids"]];
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
}


- (void)fetchData
{
    if (_accountStore == nil) {
        self.accountStore = [[ACAccountStore alloc] init];
        if (_accounts == nil) {
            ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter
                                         withCompletionHandler:^(BOOL granted, NSError *error) {
                                             if(granted) {
                                                 self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
                                                 for(ACAccount *account in self.accounts) {
                                                     [self fetchDataAux1:account];
                                                     [self fetchDataAux2:account];
                                                 }
                                             } else {
                                                 NSLog(@"ACCOUNT FAILED OR NOT GRANTED.");
                                             }
                                         }];
        }
    }
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
//     [self fetchData];
    
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
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Twitter User Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TwitterUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", user.screenname];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    TwitterUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setTwitterUser:)]) {
        [segue.destinationViewController performSelector:@selector(setTwitterUser:) withObject:user];
    }
}


@end
