//
//  ViewController.m
//  SKCityPickerView
//
//  Created by pactera on 2016/12/16.
//  Copyright © 2016年 songke. All rights reserved.
//

#import "ViewController.h"
#import "SKCityPickerView.h"

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) SKCityPickerView *cityPickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.delegate = self;
    
    self.cityPickerView = [[SKCityPickerView alloc]init];
    
//    self.cityPickerView.title = @"点击此处选择城市";
//    self.cityPickerView.font = [UIFont systemFontOfSize:20];
//    self.cityPickerView.titleColor = [UIColor redColor];
//    self.cityPickerView.borderButtonColor = [UIColor redColor];
//    self.cityPickerView.heightPickerComponent = 50;
    
    __weak typeof(self) weakSelf = self;
    self.cityPickerView.choiceBlock = ^(NSString *province, NSString *city, NSString *area) {
        NSLog(@"%@-----%@------%@", province,city,area);
        weakSelf.textField.text = [NSString stringWithFormat:@"%@ %@ %@",province,city,area];
    };
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.cityPickerView show];
    return NO;
}

@end
