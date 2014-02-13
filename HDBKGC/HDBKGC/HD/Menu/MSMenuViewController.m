//
//  MSMenuViewController.m
//  MSDynamicsDrawerViewController
//
//

#import "MSMenuViewController.h"
#import "MSMenuTableViewHeader.h"
#import "MSMenuCell.h"
#import "VPHostViewController.h"
#import "SecondViewController.h"

NSString * const MSMenuCellReuseIdentifier = @"Drawer Cell";
NSString * const MSDrawerHeaderReuseIdentifier = @"Drawer Header";

@interface MSMenuViewController ()

@property (nonatomic, strong) NSDictionary *paneViewControllerAppearanceTypes;

//@property (nonatomic, strong) UIBarButtonItem *paneStateBarButtonItem;
//@property (nonatomic, strong) UIBarButtonItem *paneRevealLeftBarButtonItem;
//@property (nonatomic, strong) UIBarButtonItem *paneRevealRightBarButtonItem;
@property (nonatomic, assign) NSUInteger paneViewControllerIdx;
@property (nonatomic,retain) NSArray *paneViewControllerTitles;
@property (nonatomic,retain) NSMutableArray *paneViewControllers;

@end

@implementation MSMenuViewController
@synthesize paneViewControllerTitles;
#pragma mark - NSObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

-(UIViewController *)findViewControllerByStoryId:(NSString *) storyId{
    return [self.storyboard instantiateViewControllerWithIdentifier:storyId];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[MSMenuCell class] forCellReuseIdentifier:MSMenuCellReuseIdentifier];
    [self.tableView registerClass:[MSMenuTableViewHeader class] forHeaderFooterViewReuseIdentifier:MSDrawerHeaderReuseIdentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.25];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - MSMenuViewController

- (void)initialize
{
    _paneViewControllerIdx = -1;
    paneViewControllerTitles = [NSArray arrayWithObjects:@"Index",@"Second", nil];
    _paneViewControllers = [NSMutableArray arrayWithObjects:[NSNull null],[NSNull null], nil];
    [_paneViewControllers count];
}

- (void)transitionToViewController:(int)idx
{
    // Close pane if already displaying the pane view controller
    if (idx == _paneViewControllerIdx) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:YES completion:nil];
        return;
    }
    
    BOOL animateTransition = self.dynamicsDrawerViewController.paneViewController != nil;
    
    UIViewController *paneViewController = [_paneViewControllers objectAtIndex:idx];
    
    if([[NSNull null] isEqual:paneViewController]){
        switch(idx){
            case 0:
            {
                paneViewController = [self findViewControllerByStoryId:@"mainNav"];
                UIViewController *rootNavViewController = [paneViewController.childViewControllers firstObject];
                
                if(rootNavViewController!=nil && [rootNavViewController isKindOfClass:[VPHostViewController class]]){
                        VPHostViewController *hvc = (VPHostViewController*)rootNavViewController;
                        hvc.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
                }
            }
                break;
            case 1:
            {
                paneViewController = [self findViewControllerByStoryId:@"secondNav"];
                UIViewController *rootNavViewController = [paneViewController.childViewControllers firstObject];
                
                if(rootNavViewController!=nil && [rootNavViewController isKindOfClass:[SecondViewController class]]){
                    SecondViewController *hvc = (SecondViewController*)rootNavViewController;
                    hvc.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
                }
            }
                break;
        }
        [_paneViewControllers replaceObjectAtIndex:idx withObject:paneViewController];
    }
    
    [self.dynamicsDrawerViewController setPaneViewController:paneViewController animated:animateTransition completion:nil];
    _paneViewControllerIdx = idx;
}

- (void)dynamicsDrawerRevealLeftBarButtonItemTapped:(id)sender
{
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}


- (void)dynamicsDrawerRevealRightBarButtonItemTapped:(id)sender
{
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionRight animated:YES allowUserInterruption:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [paneViewControllerTitles count];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new]; // Hacky way to prevent extra dividers after the end of the table from showing
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN; // Hacky way to prevent extra dividers after the end of the table from showing
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSMenuCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.paneViewControllerTitles objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    [self transitionToViewController:indexPath.row];
    
    // Prevent visual display bug with cell dividers
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    double delayInSeconds = 0.3;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self.tableView reloadData];
//    });
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)state
{
    // Ensure that the pane's table view can scroll to top correctly
    self.tableView.scrollsToTop = (state == MSDynamicsDrawerPaneStateOpen);
}

@end
