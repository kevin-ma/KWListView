KWListView
===

## 前言

关于iOS数据加载的方法，网上可以找到很多方法，其中也不乏优秀的开源项目，但是就使用而言，还是有些难以达到事半功倍的效果，所以我决定写一个使用足够简单，效率更高的开源库。

## 简介

#### 用途

KWListView用于iOS开发中列表数据的加载，旨在让列表加载及显示变得简单容易。

#### 功能
+ cell高度自动计算
+ 由开发者提供具体数据转为提供数据获取方法
+ 集成下拉刷新及上拉加载更多

#### 集成方式

###### CocoaPods (推荐)
```
'KWListView', '~> 1.0.2'
```

## 效果展示
#### 加载成功
注：采用自动高度计算功能

![Mou icon](http://makaiwen.com/image/listview_load_success.png)

#### 加载失败
![Mou icon](http://makaiwen.com/image/listview_load_fail.png)

#### 数据为空
![Mou icon](http://makaiwen.com/image/listview_load_empty.png)

## 使用方法

#### 集成
导入文件，文件结构如下图所示：

![Mou icon](http://makaiwen.com/image/listview_files.png)

#### 配置
关于listView的一些配置信息都在 KWListViewConfig.m 文件中保存

#####建议除以下参数，其他不要修改 #####

|  参数								|         说明 |
|------------------------------------------------|
| KWRefreshFooterStateNoMoreDataText |没有更多数据 |
| KWListViewFailedText |  数据加载失败|
| KWListViewParamPage  |  网络请求中的请求页码 |
| KWListViewParamPageSize | 网络请求中请求数据量|

#### 使用

导入头文件，同UITableView一样创建，设置代理、数据源，设置的是KWListViewDelegate、KWListViewDataSource，并非UITableViewDelegate、UITableViewDataSource

```
	KWListView *listView = [[KWListView alloc] initWithFrame:self.view.bounds];
	listView.delegate = self;
	// 等同于 listView.listDelegate = self;
	listView.dataSource = self; 
	// 等同于 listView.listDataSource = self;
```

在配置文件中我们可以配置加载失败及加载不到数据的显示文字及图标，针对个别需要显示不同内容的列表页面，我们可以在ListView的方法中，方法如下：

```
	[listView setEmptyText:@"没有加载到数据哟~~" image:nil];
	[listView setFailedText:@"无法连接到KWListView服务器" image:nil];
```

** 重头戏 **  相关说明都写在代码注释中

```
    __weak __typeof(self) weakSelf = self;
```
```
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
            // 以下这段代码除了 done() ,都只是在模拟分页数据，真实请求数据不用这样
            NSInteger len = [parames[KWListViewParamPageSize] integerValue];
            if (len > safeSelf.successData.count - loc) {
                len = safeSelf.successData.count - loc;
            }
            NSRange range = NSMakeRange(loc, len);
            NSLog(@"%@",NSStringFromRange(range));
            done(YES,[safeSelf.successData subarrayWithRange:range]);
        }
    };
 ```
 
 以上操作执行后，将listView加到视图中，并且调用以下方法刷新界面。
 
 ```
 	[listView loadData];
 ```
 
 接下来就是实现数据源方法了，那么我们的KWListView只需要实现一个数据源方法就可以显示数据了，哪个呢? 如下：
 
 ```
 - (UITableViewCell *)listView:(KWListView *)listView cellForRow:(NSInteger)row;
 ```
 在系统的UITableView中我们需要至少实现两个数据源方法才能显示数据，这两个方法无非是 *numberOfRows* 及 *cellForRow*
 
 在我们这里我们只需要告诉它加载什么cell就可以了，建议使用工厂方法去创建cell，并且实现复用。
 我在下面展示了我刚才所描述的这些问题
 
 ```
	- (UITableViewCell *)listView:(KWListView *)listView cellForRow:(NSInteger)row
	{
    	PlaySuccessModel *model = listView.datas[row];
    	return [PlayViewCell cellWithTableView:listView model:model];
	}
```
 
 
 
 ```
 	// PlayViewCell.m
 	
	+ (instancetype)cellWithTableView:(UITableView *)tableView model:(PlaySuccessModel *)model
	{
   	static NSString *ID = @"PlayViewCell";
    	PlayViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    	if (!cell) {
        	cell = [[PlayViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        	[cell addBaseView];
    	}
    	cell.model = model;
    	return cell;
	}
	
	- (void)addBaseView
	{
    	UILabel *nameLabel = [[UILabel alloc] init];
    	nameLabel.font = [UIFont systemFontOfSize:14];
    	nameLabel.frame = CGRectMake(10, 10, 200, [nameLabel.font singleLineHeight]);
    	nameLabel.textColor = [UIColor redColor];
    	[self.contentView addSubview:nameLabel];
    	self.nameLabel = nameLabel;
    
    	UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.size.height + nameLabel.frame.origin.y + 10, [UIScreen mainScreen].bounds.size.width - 2 * nameLabel.frame.origin.x, 0)];
    	contentLabel.font = [UIFont systemFontOfSize:14];
    	contentLabel.numberOfLines = 0;
    	[self.contentView addSubview:contentLabel];
    	self.contentLabel = contentLabel;
    
    	UILabel *timeLabel = [[UILabel alloc] init];
    	timeLabel.font = [UIFont systemFontOfSize:12];
    	timeLabel.frame =  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - nameLabel.frame.origin.x, [timeLabel.font singleLineHeight]);
    	timeLabel.textAlignment = NSTextAlignmentRight;
    	timeLabel.textColor = [UIColor grayColor];
    	[self.contentView addSubview:timeLabel];
    	self.timeLabel = timeLabel;
	}

	- (void)setModel:(PlaySuccessModel *)model
	{
    	_model = model;
    	_nameLabel.text = model.userName;
    	_contentLabel.text = model.content;
    	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    	formatter.dateFormat = @"yyyy年MM月dd日 HH:mm";
    	_timeLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.time]];
    
    	// 位置移动
    	CGFloat height = [_contentLabel.text boundingRectWithSize:CGSizeMake(_contentLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_contentLabel.font} context:nil].size.height;
    	_contentLabel.frame = (CGRect){_contentLabel.frame.origin,{_contentLabel.frame.size.width,height}};
    
    	CGRect tempRect = _timeLabel.frame;
    	tempRect.origin.y = _contentLabel.frame.origin.y + _contentLabel.frame.size.height + 10;
    	_timeLabel.frame = tempRect;
	}
```

至于我们常用的其他数据源方法，同样我也有包装一下。

```
- (NSInteger)listViewHasNumberOfRows:(KWListView *)listView
```

```
- (CGFloat)listView:(KWListView *)listView heightForRow:(NSInteger)row
```

关于上一个方法，我们在上面 *listView.requestAction* 这段block中，已经将获取数据的方法传给了listView，所以listView会默认显示它所请求到的数据量，或者说是我们规定的一页请求量，如果你有特殊要求，那你可以按照UITableView处理。

对于下面这个关于高度的方法，我们有自动高度计算机制，所以可以不用实现，那高度自动计算到底怎么用呢？我们来说下

### **高度自动计算** ###

高度自动计算实现依赖于我在listView中封装的一个缓存池，无非就是根据cell工厂方法中cell的布局及数据对cell的高度进行计算。

在listView中有一个属性 **bottomMargin** ，这个属性是用来说明我们cell中最下面的视图与cell底部的距离的，如果不设置这个属性，那么listView将按照cell中最上面视图与cell顶部的距离进行计算。

还有一个值很重要，**KWUncountTag**，它用于忽视cell中的视图。 在cell中，更确切地说是cell.contentView中的所有视图，除了隐藏的视图或视图tag为KWUncountTag的视图不会被计算高度，剩下的都会。

**关于KWListView的东西还是有很多的，精力有限，不能一一说明，更多的内容还请下载代码参考Demo，或者查看源码去了解。

### **附言** ###

如果在使用过程中发现任何BUG，请联系我修改，谢谢~


GitHub:[kevin-ma](http://github.com/kevin-ma) | Blog:[kevin](http://www.makaiwen.com)

