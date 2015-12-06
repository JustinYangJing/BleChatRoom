//
//  BNRChatRoom.h
//  BleChatRoom
//
//  Created by JustinYang on 11/29/15.
//  Copyright © 2015 JustinYang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,ChatRoomType) {
    /**
     *  设备作为CBCentralManager端
     */
    ChatRoomTypeHost,
    /**
     *  设备作为CBPeripheralManager端
     */
    ChatRoomTypeClient
};

@interface BNRChatRoom : UIViewController
@property (nonatomic) ChatRoomType chatRoomType;

@end
