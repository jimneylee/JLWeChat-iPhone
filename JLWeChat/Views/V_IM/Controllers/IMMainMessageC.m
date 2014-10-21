//
//  JLFirstViewController.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-17.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMMainMessageC.h"
#import "IMManager.h"

#import "IMSimpleLoginC.h"
#import "IMChatC.h"
#import "IMSearchDisplayController.h"
#import "IMRecentContactCell.h"
#import "IMMainMessageViewModel.h"
#import "IMManager.h"

@interface IMMainMessageC ()<NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) IMSearchDisplayController *searchController;

@end

@implementation IMMainMessageC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"消息";
        self.viewModel = [IMMainMessageViewModel sharedViewModel];
        
        [[IMManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        @weakify(self);
        [self.viewModel.updatedContentSignal subscribeNext:^(id x) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetCurrentContactUnreadMessagesCountNofity:)
                                                     name:@"RESET_CURRENT_CONTACT_UNREAD_MESSAGES_COUNT"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tableView.rowHeight = MESSAGE_MAIN_ROW_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                           self.view.width, TT_TOOLBAR_HEIGHT)];
    searchBar.tintColor = APP_MAIN_COLOR;
    self.tableView.tableHeaderView = searchBar;
    
    IMSearchDisplayController *searchDisplayController = [[IMSearchDisplayController alloc] initWithSearchBar:searchBar
                                                                                           contentsController:self];
    self.searchController = searchDisplayController;

    // check login
    IMSimpleLoginC *loginC = [[IMSimpleLoginC alloc] initWithNibName:NSStringFromClass([IMSimpleLoginC class])
                                                              bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginC];
    [IMUIHelper configAppearenceForNavigationBar:nav.navigationBar];
    [self.navigationController presentViewController:nav animated:NO completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Private

- (void)resetCurrentContactUnreadMessagesCountNofity:(NSNotification *)nofify
{
    id object = nofify.object;
    if ([object isKindOfClass:[XMPPJID class]]) {
        XMPPJID *contactJid = (XMPPJID *)object;
        [self.viewModel resetUnreadMessagesCountForCurrentContact:contactJid];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self.viewModel numberOfItemsInSection:sectionIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"MKRecentContactCell";
	
	IMRecentContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[IMRecentContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:CellIdentifier];
	}
	
    XMPPMessageArchiving_Contact_CoreDataObject *contact = [self.viewModel objectAtIndexPath:indexPath];
	[cell shouldUpdateCellWithObject:contact];
	
	return cell;
  
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.viewModel deleteObjectAtIndexPath:indexPath];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDataDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Contact_CoreDataObject *contact = [self.viewModel objectAtIndexPath:indexPath];
    IMChatC *chatC = [[IMChatC alloc] initWithBuddyJID:contact.bareJid
                                                           buddyName:contact.displayName];
    [self.navigationController pushViewController:chatC animated:YES];
    
    // reset unread message count
    if ([self.viewModel resetUnreadMessagesCountForCurrentContact:contact.bareJid]) {
        if ([self.tableView numberOfSections] > indexPath.section
            && [self.tableView numberOfRowsInSection:indexPath.section] > indexPath.row) {
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}

@end
