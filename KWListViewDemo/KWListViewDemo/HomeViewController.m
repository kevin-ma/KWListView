//
//  ViewController.m
//  KWListViewDemo
//
//  Created by 凯文马 on 15/9/29.
//  Copyright © 2015年 凯文马. All rights reserved.
//

#import "HomeViewController.h"
#import "PlayViewController.h"

@interface HomeViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *data;
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBar];
    [self loadTableView];
}

- (void)initNavBar
{
    self.title = @"请选择演示类型";
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    NSString *title = @"KWListView\n请选择演示类型";
    NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]}];
    [attTitle addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],NSForegroundColorAttributeName:[UIColor redColor]} range:[title rangeOfString:@"KWListView"]];
    titleLabel.attributedText = attTitle;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}

- (void)loadTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

# pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"homeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    NSString *title = self.data[indexPath.row];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlayViewController *vc = [[PlayViewController alloc] initWithType:indexPath.row];
    vc.title = self.data[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

# pragma mark - getter
- (NSArray *)data
{
    if (!_data) {
        _data = @[
                  @"加载失败",@"数据为空",@"加载成功",
                  ];
    }
    return _data;
}
@end
