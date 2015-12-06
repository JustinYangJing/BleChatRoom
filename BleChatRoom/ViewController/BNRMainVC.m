//
//  BNRMainVC.m
//  BleChatRoom
//
//  Created by JustinYang on 11/29/15.
//  Copyright © 2015 JustinYang. All rights reserved.
//

#import "BNRMainVC.h"
#import "BNRChatRoom.h"
@interface BNRMainVC ()

@end

@implementation BNRMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pushClientVC:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BNRChatRoom *chatRoomVC = [sb instantiateViewControllerWithIdentifier:@"chatRoom"];
    chatRoomVC.chatRoomType = ChatRoomTypeClient;
    [self.navigationController pushViewController:chatRoomVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
