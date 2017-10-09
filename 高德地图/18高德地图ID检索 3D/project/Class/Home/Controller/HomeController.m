//
//  HomeController.m
//  project
//
//  Created by zhouyu on 2017/8/3.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "HomeController.h"


#define Title @"title"
#define vcName @"vcName"

@interface HomeController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sourceArr;
@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:KUIScreenBounds];
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:tableView];
}

//选择cell--跳转到对应的控制器--展示地图
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.sourceArr[indexPath.row];
    NSString *vcTitle = dict[Title];
    NSString *className = dict[vcName];
    Class vcClass = NSClassFromString(className);
    UIViewController *vcController = [[vcClass alloc] init];
    vcController.navigationItem.title = vcTitle;
    [self.navigationController pushViewController:vcController animated:YES];
}

//数据源和代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    NSDictionary *dict = self.sourceArr[indexPath.row];
    cell.textLabel.text = dict[Title];
    cell.detailTextLabel.text = dict[vcName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

//懒加载plist信息
- (NSArray *)sourceArr{
    if (_sourceArr == nil) {
        _sourceArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MapType.plist" ofType:nil]];
    }
    return _sourceArr;
}

@end
