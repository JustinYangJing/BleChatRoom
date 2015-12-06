//
//  BNRPeripheralTVC.m
//  BleChatRoom
//
//  Created by JustinYang on 11/29/15.
//  Copyright © 2015 JustinYang. All rights reserved.
//

#import "BNRPeripheralTVC.h"
#import "BNRBLECentral.h"
#import "BNRChatRoom.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface BNRPeripheralTVC ()<BNRBLECentralDelegate>
@property (nonatomic,weak) BNRBLECentral *manager;
@end

@implementation BNRPeripheralTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    self.manager = [BNRBLECentral sharedInstance];
    self.manager.delegate = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.manager scanPeripheralWithTimeOut:0];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BNRBLECentralDelegate
-(void)discoverPeripherals{
    [self.tableView reloadData];
}
-(void)didConnectToPeripheral{
    
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BNRChatRoom *chatRoomVC = [sb instantiateViewControllerWithIdentifier:@"chatRoom"];
    chatRoomVC.chatRoomType = ChatRoomTypeHost;
    [self.navigationController pushViewController:chatRoomVC animated:YES];
}

-(void)occurError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:NO];
    MBProgressHUD *loadHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    loadHUD.labelText = [NSString stringWithFormat:@"%@",error];
    [loadHUD hide:YES afterDelay:3];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.manager.peripherals.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *peripheralDic = self.manager.peripherals[indexPath.row];
    CBPeripheral *peripheral = peripheralDic[@"peripheral"];
    NSNumber *rssi = peripheralDic[@"rssi"];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",rssi];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:NO];
    MBProgressHUD *loadHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    loadHUD.labelText = @"connecting...";
    [self.manager connectPeralWithIndex:indexPath.row];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    BNRChatRoom *chatRoomVC = [segue destinationViewController];
//    chatRoomVC.chatRoomType = ChatRoomTypeHost;
//    NSIndexPath *path = [self.tableView indexPathForCell:sender];
//    [self.manager connectPeralWithIndex:path.row];
}

@end
