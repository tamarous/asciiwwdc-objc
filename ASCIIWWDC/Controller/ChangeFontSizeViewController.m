//
//  ChangeFontSizeViewController.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/6/2.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "ChangeFontSizeViewController.h"

@interface ChangeFontSizeViewController ()
@property (nonatomic, strong) UIButton *textButton;
@end

@implementation ChangeFontSizeViewController

- (instancetype) init {
    self = [super init];
    if (self) {
        self.textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.textButton setTitle:@"Hello World" forState:UIControlStateNormal];
        [self.view addSubview:self.textButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ChangeFontSizeViewController did load.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
