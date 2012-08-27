//
//  FortuneTweetSettingViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/25.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//
// http://support.apple.com/kb/PH3871
// 'Enter special characters and symbols'
//
#import "FortuneTweetSettingDocumentViewController.h"
#import "FortuneTweetSettingViewController.h"

@interface FortuneTweetSettingViewController ()
@property (strong, nonatomic) NSArray *documents;
@end

@implementation FortuneTweetSettingViewController
@synthesize documents=_documents;

- (NSArray *) documents
{
    if( !_documents ){
        NSDictionary *doc = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"copyright", @"filename",
                             @"txt", @"ext",
                             @"Copyright", @"title",
                             nil];
        _documents = [[NSArray alloc] initWithObjects:doc, nil];
    }
    return _documents;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.documents count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Setting Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[self.documents objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // [self performSegueWithIdentifier:@"Copyright Show" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
// http://stackoverflow.com/questions/6918210/how-to-disable-qlpreviewcontroller-print-button
// https://github.com/rob-brown/RBFilePreviewer.git


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Copyright Show"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSLog(@"indexPath %@", indexPath);
        [segue.destinationViewController setFile:[self.documents objectAtIndex:indexPath.row]];
    }
}


@end
