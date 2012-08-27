//
//  FortuneTweetSettingDocumentViewController.m
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/25.
//  Copyright (c) 2012年 Norimasa Nabeta. All rights reserved.
//

#import "FortuneTweetSettingDocumentViewController.h"

@interface FortuneTweetSettingDocumentViewController ()

@end

@implementation FortuneTweetSettingDocumentViewController
@synthesize webView=_webView;
@synthesize file=_file;

- (void) setFile:(NSDictionary *)file
{
    if( _file != file){
        _file=file;
        // NSLog(@"file: %@ ext: %@", [_file objectForKey:@"filename"], [_file objectForKey:@"ext"]);
    }
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

    NSError *error = nil;
    NSString *html = [[NSString alloc]
                      initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[self.file objectForKey:@"filename"] ofType:[self.file objectForKey:@"ext"]]
                                                    encoding:NSUTF8StringEncoding error:&error];

    // NSString *html = [NSString stringWithFormat:@"<html><head><meta name=""viewport"" content=""width=300""/></head><body>%@<p><p>-- %@<p>%@</body</html>", fortune.quotation, fortune.act, fortune.scene];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.apple.com"]];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
