//
//  BNRChatRoom.m
//  BleChatRoom
//
//  Created by JustinYang on 11/29/15.
//  Copyright © 2015 JustinYang. All rights reserved.
//

#import "BNRChatRoom.h"
#import "BNRBLECentral.h"
#import "BNRBLEPeripheral.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
@interface BNRChatRoom ()<BNRBLECentralDelegate,BNRBLEPeripheralDelegate,UITextViewDelegate>
@property (nonatomic,weak) id manager;
@property (weak, nonatomic) IBOutlet UITextView *receivedTextView;
@property (weak, nonatomic) IBOutlet UITextView *editTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendBrn;
@property (nonatomic) UIWindow *window;
@property (nonatomic,strong) NSTimer *tickTimer;
@end

@implementation BNRChatRoom
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    NSLog(@"%@",[self class]);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.chatRoomType == ChatRoomTypeHost) {
        self.manager = [BNRBLECentral sharedInstance];
        ((BNRBLECentral *)self.manager).delegate = self;
        self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(ask) userInfo:nil repeats:YES];
    }else if(self.chatRoomType == ChatRoomTypeClient){
        self.manager = [BNRBLEPeripheral sharedInstance];
        ((BNRBLEPeripheral *)self.manager).delegate = self;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [((BNRBLEPeripheral *)self.manager) startAdveritise];
        });
        MBProgressHUD *loadHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        loadHUD.labelText = @"广播中,等待Central连接";
        self.sendBrn.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.editTextView.delegate = self;
    
}
-(void)ask{
    [((BNRBLECentral *)self.manager) askRead];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)send:(id)sender {
    NSString *str = self.editTextView.text;
    if (str==nil||str.length < 1) {
        [self.editTextView resignFirstResponder];
        return;
    }
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (self.chatRoomType == ChatRoomTypeClient) {
        [((BNRBLEPeripheral *)self.manager) writeData:data];
    }else{
        [((BNRBLECentral *)self.manager) writeData:data];
    }
    [self.editTextView resignFirstResponder];
    self.editTextView.text = @"";
}
#pragma mark --
-(void)occurError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.window animated:NO];
    MBProgressHUD *loadHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    loadHUD.labelText = [NSString stringWithFormat:@"%@",error];
    [loadHUD show:YES];
    [loadHUD hide:YES afterDelay:4];
}

-(void)receivedData:(NSData *)data{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.receivedTextView.text = [self.receivedTextView.text stringByAppendingFormat:@"\n %@",str];
}
-(void)didConnectService{
    self.sendBrn.enabled = YES;
    [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
}
#pragma mark - keyboard handle
- (void)keyboardWillAppear:(NSNotification *)aNotification{
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = CGRectMake(self.view.frame.origin.x, 0 - keyboardRect.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame = frame;
    }];
}


- (void)keyboardWillHide:(NSNotification *)aNotification
{
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardRect.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame = frame;
    }];
}

- (void)textViewDidChange:(UITextView *)textView{
    CGSize size  = textView.frame.size;
    if (textView.contentSize.height < 88) {
        return;
    }
    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y-(textView.contentSize.height-size.height), textView.contentSize.width, textView.contentSize.height);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(UIWindow *)window{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    return app.window;
}
@end
