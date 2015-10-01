//
//  PlayViewController.m
//  KWListViewDemo
//
//  Created by 凯文马 on 15/10/1.
//  Copyright © 2015年 凯文马. All rights reserved.
//

#import "PlayViewController.h"
#import "KWListView.h"
#import "PlaySuccessModel.h"
#import "PlayViewCell.h"

@interface PlayViewController () <KWListViewDataSource,KWListViewDelegate>
@property (nonatomic, weak) KWListView *listView;

@property (nonatomic, strong) NSArray *successData;  // 模拟请求成功的数据
@end

@implementation PlayViewController

- (instancetype)initWithType:(PlayType)type
{
    if (self = [self init]) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBar];
    [self loadListView];
}

- (void)initNavBar
{
    UISwitch *switchBtn = [[UISwitch alloc] init];
    [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:switchBtn];
}

- (void)loadListView
{
    KWListView *listView = [[KWListView alloc] initWithFrame:self.view.bounds];
    listView.delegate = self;
    listView.dataSource = self;
    
    listView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    listView.tableFooterView = [[UIView alloc] init];
    
    // 这两项可以在KWListViewConfig.m中设置
    [listView setEmptyText:@"没有加载到数据哟~~" image:nil];
    [listView setFailedText:@"无法连接到KWListView服务器" image:nil];
    
    __weak __typeof(self) weakSelf = self;
    listView.requestAction = ^(NSDictionary *parames,void(^done)(BOOL , NSArray *)){
        /* 
        * parames 中为请求所用的分页信息
        * 包括 page、page_size，如果与您需要的不相符，请在配置中修改
        * KWListViewParamPage 、 KWListViewParamPageSize
        * bloack中一般写网络请求
        * 网络请求参数请在parames基础上添加. 例：
        *   NSMutableDictionary *newParames = [parames mutableCopy];
        *   newParames[@"id"] = @"1";
        */
        __strong __typeof(self) safeSelf = weakSelf;
        // done的两个参数传送网络请求返回的成功/失败及数据，以下仅为模拟
        if (safeSelf.type == PlayTypeEmpty) {
            done(YES,@[]);
        } else if (safeSelf.type == PlayTypeFail) {
            done(NO,@[]);
        } else {
            NSInteger loc = ([parames[KWListViewParamPage] integerValue] - 1) * [parames[KWListViewParamPageSize] integerValue];
            NSInteger len = [parames[KWListViewParamPageSize] integerValue];
            if (len > safeSelf.successData.count - loc) {
                len = safeSelf.successData.count - loc;
            }
            NSRange range = NSMakeRange(loc, len);
            NSLog(@"%@",NSStringFromRange(range));
            done(YES,[safeSelf.successData subarrayWithRange:range]);
        }
    };
    [self.view addSubview:listView];
    self.listView = listView;
    
    // 加载数据
    [self.listView loadData];
}

# pragma mark - KWListViewDataSource,KWListViewDelegate
// KWListView 自动计算高度机制，可以不写，默认所有视图居中显示
// PS: 高度自动计算仅在cell由类方法实现有效，请参考下面所用的cell类
//- (CGFloat)listView:(KWListView *)listView heightForRow:(NSInteger)row

// KWListView 自动计算行数机制，可以不写，默认请求成功返回数量
//- (NSInteger)listViewHasNumberOfRows:(KWListView *)listView

- (UITableViewCell *)listView:(KWListView *)listView cellForRow:(NSInteger)row
{
    PlaySuccessModel *model = listView.datas[row];
    PlayViewCell *cell = [PlayViewCell cellWithTableView:listView model:model];
    return cell;
}

# pragma mark - getter
- (NSArray *)successData
{
    if (!_successData) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TestData" ofType:@"plist"];
        _successData = [NSArray arrayWithContentsOfFile:path];
        _successData = [PlaySuccessModel modelsWithDicts:_successData];
    }
    return _successData;
}

# pragma mark - private
- (void)switchAction:(UISwitch *)sender
{
    if (sender.isOn) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
        label.text = @"这就是我自定义的加载数据为空的页面了，你可以自己随便设计，假象向self.view中添加视图一样设计尺寸和位置。";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor redColor];
        label.numberOfLines = 0;
        _listView.emptyView = label;
    } else {
        _listView.emptyView = nil;
    }
    if (_type != PlayTypeEmpty) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"返回选择“数据为空”才有效果哦~" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        [_listView loadData];
    }
}
@end
