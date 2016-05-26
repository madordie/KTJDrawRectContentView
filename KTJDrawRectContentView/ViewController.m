//
//  ViewController.m
//  KTJDrawRectContentView
//
//  Created by 孙继刚 on 16/5/26.
//  Copyright © 2016年 Keith. All rights reserved.
//

#import "ViewController.h"
#import "KTJDrawRectContentView.h"

@interface ViewController ()

@property (nonatomic, strong) KTJDrawRectContentView *linesView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.linesView = [[KTJDrawRectContentView alloc] init];
    [self.view addSubview:self.linesView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)formatSourceData {

}

@end
