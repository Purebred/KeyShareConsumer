//
//  KeyDetailViewController.m
//  KeyShareConsumer

#import "KeyDetailViewController.h"

@interface KeyDetailViewController ()

@end

@implementation KeyDetailViewController
@synthesize keyChain;

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //always one section for the details view, with the possibility that there is one row per attribute or per group of attributes
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(keyChain)
        return [keyChain numAttrGroups:_itemIndex];
    else
        return 0;
}

#define FONT_SIZE 14.0f
#define CELL_CONTENT_MARGIN 10.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGRect frameRect = [self.tableView frame];
    CGSize constraint = CGSizeMake(frameRect.size.width - (CELL_CONTENT_MARGIN * 2) - 44, 20000.0f);
    
    NSString *detail = [keyChain getAttrValueAtSection:_itemIndex attrIndex:indexPath.row];

    CGSize detailSize = [detail sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    
    NSString *label = NSLocalizedString(@"Miscellaneous properties", @"Row label in key details view");
    CGSize labelSize = [label sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat height = MAX(detailSize.height + labelSize.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString* attrNameLabelString = [keyChain getAttrNameAtSection:_itemIndex attrIndex:indexPath.row];
    NSString* attrValueLabelString = [keyChain getAttrValueAtSection:_itemIndex attrIndex:indexPath.row];
    
    [cell.textLabel setText:attrNameLabelString];
    cell.detailTextLabel.numberOfLines = 0;
    [cell.detailTextLabel setText:attrValueLabelString];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)OnShareWithiTunes:(id)sender
{
    [_dpvc import:self.itemIndex];
}

- (IBAction)OnCancel:(id)sender
{
    [_dpvc dismissWithoutImporting:self.itemIndex];
}
@end
