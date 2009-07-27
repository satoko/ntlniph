#import "NTLNUserViewController.h"
#import "NTLNLinkTweetCell.h"
#import "NTLNRoundedIconView.h"
#import "NTLNColors.h"
#import "NTLNConfiguration.h"
#import "NTLNIconTextCell.h"
#import "NTLNUserTimelineViewController.h"
#import "NTLNFavoriteViewController.h"
#import "NTLNUserListViewController.h"
#import "NTLNHttpClientPool.h"
#import "NTLNAccount.h"

#define FOLLOWBUTTON_UN_FOLLOW	@"Remove"
#define FOLLOWBUTTON_FOLLOW		@"Follow"
#define followButtonWidth		65
#define followButtonHeight		25
#define followAISize			18

@interface NTLNUserViewController(Private)
- (void)getUserInfo;
- (void)updateFollowButton;
@end


@implementation NTLNUserViewController

@synthesize message;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)setupTableView {
	UITableView *tv = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
													style:UITableViewStylePlain] autorelease];	
	tv.delegate = self;
	tv.dataSource = self;
	tv.autoresizesSubviews = YES;
	tv.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.view = tv;
}

- (void)viewDidLoad {
	[self setupTableView];
	((UITableView*)self.view).autoresizesSubviews = YES;
	[self.navigationItem setTitle:@"User"];
}

- (void)viewWillAppear:(BOOL)animated {
	[self getUserInfo];
	
	NSIndexPath *tableSelection = [(UITableView*)self.view indexPathForSelectedRow];
	[(UITableView*)self.view deselectRowAtIndexPath:tableSelection animated:NO];
	
//	[(UITableView*)self.view reloadData];
	
	((UITableView*)self.view).backgroundColor = [[NTLNColors instance] scrollViewBackground];
	if ([[NTLNConfiguration instance] darkColorTheme]) {
		((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleWhite;
	} else {
		((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleBlack;
	}
}


- (void)dealloc {
	[userInfo release];
	[followButton release];
	[followAI release];
    [super dealloc];
}

- (UITableViewCell *)nameCell {	
	NTLNLinkNameCell *cell = [[[NTLNLinkNameCell alloc] initWithFrame:CGRectZero] autorelease];
	[cell createCellWithName:message.name screenName:message.screenName];
	
	NTLNRoundedIconView *iconview = [[[NTLNRoundedIconView alloc] 
									  initWithFrame:CGRectMake(6.5, 6.5, 56.0, 56.0) 
									  image:message.iconContainer.iconImage 
									  round:8.0] autorelease];
	iconview.backgroundColor = [[NTLNColors instance] oddBackground];
//	[iconview addTarget:self action:@selector(replyButtonAction:)
//	   forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:iconview];	
	
	
	int y = 70 ;
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(13, y, 148, 36)];
		[b setBackgroundImage:[UIImage imageNamed:@"normal_01.png"] forState:UIControlStateNormal];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_01.png"] forState:UIControlStateHighlighted];
//		[b addTarget:self action:@selector(replyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(13+148, y, 149, 36)];
		[b setBackgroundImage:[UIImage imageNamed:@"normal_02.png"] forState:UIControlStateNormal];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_02.png"] forState:UIControlStateHighlighted];
//		[b addTarget:self action:@selector(retweetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;

	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		UIColor *color = [[NTLNColors instance] textForground];
		[b setFrame:CGRectMake(76.0 + 230.0 - followButtonWidth, 10.0, 
							   followButtonWidth, followButtonHeight)];
		[b setFont:[UIFont boldSystemFontOfSize:10]];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_04.png"] forState:UIControlStateHighlighted];
		[b addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[b setTitleColor:color forState:UIControlStateNormal];
		[cell addSubview:b];
		followButton = [b retain];
		[self updateFollowButton];
	}
	
	if(followAI) {
		[followAI removeFromSuperview];
	}
	UIActivityIndicatorView *ai = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(followButtonWidth/2-followAISize/2, followButtonHeight/2-followAISize/2, followAISize, followAISize)] autorelease];
	ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	ai.hidesWhenStopped = YES;
	followAI = [ai retain];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (userInfo) {
		switch ([indexPath row]) {
			case 0:
				return 120;
		}
	} else {
		if ([indexPath row] == 0) return 120;
	}
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (userInfo) {
		return 6;
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	NTLNCell *cell = nil;
	if (userInfo) {
		switch(row)
		{
			case 0:
				cell = (NTLNCell*)[self nameCell];
				break;
			default:
				{
					cell = [[[NTLNIconTextCell alloc] initWithFrame:CGRectZero] autorelease];
					switch (row) {
						case 1:
							[(NTLNIconTextCell*)cell createCellWithText:userInfo.url icon:[UIImage imageNamed:@"icons_02.png"]
																 isEven:NO];
							break;
						case 2:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d updates",userInfo.statuses_count] 
												icon:[UIImage imageNamed:@"icons_03.png"]
																 isEven:YES];
							break;
						case 3:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d favs",userInfo.favourites_count] 
												icon:[UIImage imageNamed:@"icons_05.png"]
																 isEven:NO];
							break;
						case 4:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d following",userInfo.friends_count]
												icon:[UIImage imageNamed:@"icons_01.png"]
																 isEven:YES];
							break;
						case 5:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d followers",userInfo.followers_count] 
												icon:[UIImage imageNamed:@"icons_01.png"]
																 isEven:NO];
							break;
					}
				}
				break;
				
		}
	} else {
		cell = (NTLNCell*)[self nameCell];
	}
	
	if (row == 1) {
		cell.cellType = NTLNCellTypeRoundTop;
	}
	int ROW_COUNT = 5;
	if (row >= ROW_COUNT ) {
		cell.cellType = NTLNCellTypeRoundBottom;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (userInfo) {
		switch (row){
			case 2:
			{
				NTLNUserTimelineViewController *vc = [[[NTLNUserTimelineViewController alloc] init] autorelease];
				vc.screenName = userInfo.screen_name;
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
			case 3:
			{
				NTLNFavoriteViewController *vc = [[[NTLNFavoriteViewController alloc] initWithScreenName:userInfo.screen_name] autorelease];
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
			case 4:
			{
				NTLNUserListViewController *vc = [[[NTLNUserListViewController alloc] init] autorelease];
				vc.screenName = userInfo.screen_name;
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
		}
	}
}

- (void)getUserInfo {
	NTLNTwitterUserClient *c = [[NTLNHttpClientPool sharedInstance] 
								idleClientWithType:NTLNHttpClientPoolClientType_TwitterUserClient];
	c.delegate = self;
	[c getUserInfoForScreenName:message.screenName];
}

#pragma mark NTLNTwitterUserClientDelegate
- (void)twitterUserClientSucceeded:(NTLNTwitterUserClient*)sender {
	[userInfo release];
	userInfo = nil;
	
	if ([sender.users count] > 0) {
		userInfo = [[sender.users objectAtIndex:0] retain];
	}
	[self.tableView reloadData];
	
//	LOG(@"twitterUserClientSucceeded: %d", userInfo.statuses_count);	
}

- (void)twitterUserClientFailed:(NTLNTwitterUserClient*)sender {
}

#pragma mark NTLNTwitterFriendshipsClientDelegate
- (void)twitterFriendshipsClientSucceeded:(NTLNTwitterFriendshipsClient*)sender {	
	if ([sender.users count] > 0) {
		userInfo.following = !userInfo.following;
 	}
	[self updateFollowButton];
	[followAI stopAnimating];
	[followAI removeFromSuperview];
}

- (void)twitterFriendshipsClientFailed:(NTLNTwitterFriendshipsClient*)sender {
	[self updateFollowButton];
	[followAI stopAnimating];
	[followAI removeFromSuperview];
}

#pragma mark followButton
- (void)followButtonAction:(id)sender {
	NTLNTwitterFriendshipsClient *c = [[NTLNHttpClientPool sharedInstance] 
									   idleClientWithType:NTLNHttpClientPoolClientType_TwitterFriendshipsClient];
	c.delegate = self;
	
	if(userInfo.following) {
		NSLog(@"destroyFriendshipsWithUserId");
		[c destroyFriendshipsWithUserId:userInfo.user_id];
	} else {
		NSLog(@"createFriendshipsWithUserId");
		[c createFriendshipsWithUserId:userInfo.user_id];
	}
	
	UIImage *buttonImage = nil;
	if ([[NTLNConfiguration instance] darkColorTheme]) {
		buttonImage = [UIImage imageNamed:@"pushed_black_04.png"];
	} else {
		buttonImage = [UIImage imageNamed:@"pushed_04.png"];
	}
	[followButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[followButton addSubview:followAI];
	[followAI startAnimating];
}

- (void)updateFollowButton {
	NSString *title = nil;
	if(!userInfo) {
		title = @"";
	} else if (userInfo.following) {
		title = FOLLOWBUTTON_UN_FOLLOW;
	} else {
		title = FOLLOWBUTTON_FOLLOW;
	}
	[followButton setTitle:title forState:UIControlStateNormal];
	[followButton setBackgroundImage:nil forState:UIControlStateNormal];
}

@end



