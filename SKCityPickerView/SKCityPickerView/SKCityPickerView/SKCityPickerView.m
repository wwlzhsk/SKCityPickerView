//
//  SKCityPickerView.m
//  SKCityPickerView
//
//  Created by pactera on 2016/12/16.
//  Copyright © 2016年 songke. All rights reserved.
//

#import "SKCityPickerView.h"

//屏幕尺寸的宏
#define SKScreenWidth  CGRectGetWidth([UIScreen mainScreen].bounds)
#define SKScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

//颜色相关的宏
#define SKRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define SKRGB(r, g, b) SKRGBA(r, g, b, 1.0f)

//toolBar高度
static const CGFloat SKSystemHeight = 44;
//分割线宽度
static const CGFloat SKLineHeight = 0.5;
//较小间隙
static const CGFloat SKSmallPadding = 5;
//按钮距边宽度
static const CGFloat SKBigPadding = 15;

@interface SKCityPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>

/** 1.内容视图 */
@property (nonatomic, strong) UIView *contentView;
/** 2.top分割线 */
@property (nonatomic, strong)UIView *topLine;
/** 3.选择器 */
@property (nonatomic, strong)UIPickerView *pickerView;
/** 4.左边的按钮 */
@property (nonatomic, strong)UIButton *leftButton;
/** 5.右边的按钮 */
@property (nonatomic, strong)UIButton *righBtutton;
/** 6.标题label */
@property (nonatomic, strong)UILabel *labelTitle;
/** 7.bottom分割线*/
@property (nonatomic, strong)UIView *bottomLine;

/** 1.数据源数组 */
@property (nonatomic, strong)NSArray *dataArray;
/** 2.省数组 */
@property (nonatomic, strong)NSMutableArray *provinceArray;
/** 3.市数组 */
@property (nonatomic, strong)NSMutableArray *cityArray;
/** 4.地区数组 */
@property (nonatomic, strong)NSMutableArray *areaArray;
/** 5.选中数组 */
@property (nonatomic, strong)NSMutableArray *selectedArray;

/** 6.省 */
@property (nonatomic, strong)NSString *province;
/** 7.城 */
@property (nonatomic, strong)NSString *city;
/** 8.地区 */
@property (nonatomic, strong)NSString *area;

@end

@implementation SKCityPickerView

#pragma mark - 生命周期
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        [self loadData];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.showType == SKCityPickerViewShowTypeBottom) {
        return;
    }else {
        CGRect frameLeft = self.leftButton.frame;
        CGRect frameRight = self.righBtutton.frame;
        frameLeft.origin.y = self.bottomLine.frame.origin.y + self.bottomLine.frame.size.height + SKSmallPadding;
        frameRight.origin.y = frameLeft.origin.y;
        self.leftButton.frame = frameLeft;
        self.righBtutton.frame = frameRight;
    }
}

#pragma mark - 私有方法
/** 设置属性的默认值 */
- (void)setupUI {
    // 1.设置数据的默认值
    _title = @"请选择城市地区";
    _font = [UIFont systemFontOfSize:15];
    _titleColor = [UIColor blackColor];
    _borderButtonColor = SKRGB(143, 143, 143);
    _heightPicker = 255;
    _showType = SKCityPickerViewShowTypeBottom;
    _heightPickerComponent = 32;
    
    // 2.设置自身的属性
    self.bounds = [UIScreen mainScreen].bounds;
    self.backgroundColor = SKRGBA(0, 0, 0, 0.3);
    self.layer.opacity = 0.0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeView)];
    [self addGestureRecognizer:tap];
    
    // 3.添加子视图
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.topLine];
    [self.contentView addSubview:self.pickerView];
    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.righBtutton];
    [self.contentView addSubview:self.labelTitle];
    [self.contentView addSubview:self.bottomLine];
}

/** 设置UI */
- (void)loadData {
    // 1.获取数据
    [self.dataArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.provinceArray addObject:obj[@"state"]];
    }];
    
    NSMutableArray *citys = [NSMutableArray arrayWithArray:[self.dataArray firstObject][@"cities"]];
    [citys enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.cityArray addObject:obj[@"city"]];
    }];
    
    self.areaArray = [citys firstObject][@"area"];
    
    self.province = self.provinceArray[0];
    self.city = self.cityArray[0];
    if (self.areaArray.count != 0) {
        self.area = self.areaArray[0];
    }else{
        self.area = @"";
    }
}

//更新数据
- (void)reloadData
{
    NSInteger index0 = [self.pickerView selectedRowInComponent:0];
    NSInteger index1 = [self.pickerView selectedRowInComponent:1];
    NSInteger index2 = [self.pickerView selectedRowInComponent:2];
    self.province = self.provinceArray[index0];
    self.city = self.cityArray[index1];
    if (self.areaArray.count != 0) {
        self.area = self.areaArray[index2];
    }else{
        self.area = @"";
    }
    
    NSString *title = [NSString stringWithFormat:@"%@ %@ %@", self.province, self.city, self.area];
    [self setTitle:title];
    
}

//移除选择器
- (void)removeView
{
    if (self.contentMode == SKCityPickerViewShowTypeBottom) {
        CGRect frameContent =  self.contentView.frame;
        frameContent.origin.y += self.contentView.frame.size.height;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.layer setOpacity:0.0];
            self.contentView.frame = frameContent;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else {
        CGRect frameContent =  self.contentView.frame;
        frameContent.origin.y += (SKScreenHeight + self.contentView.frame.size.height) / 2;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.layer setOpacity:0.0];
            self.contentView.frame = frameContent;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

//点击事件
- (void)buttonRightClick:(UIButton *)buttonRight
{
    [self removeView];
    if (self.choiceBlock != nil) {
        self.choiceBlock(self.province, self.city, self.area);
    }
}

#pragma mark - 暴露在外的方法
- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self setCenter:[UIApplication sharedApplication].keyWindow.center];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    
    if (self.showType == SKCityPickerViewShowTypeBottom) {
        CGRect frameContent =  self.contentView.frame;
        frameContent.origin.y -= self.contentView.frame.size.height;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.layer setOpacity:1.0];
            self.contentView.frame = frameContent;
        } completion:^(BOOL finished) {
        }];
    }else {
        CGRect frameContent =  self.contentView.frame;
        frameContent.origin.y -= (SKScreenHeight + self.contentView.frame.size.height) / 2;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.layer setOpacity:1.0];
            self.contentView.frame = frameContent;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.provinceArray.count;
    }else if (component == 1) {
        return self.cityArray.count;
    }else{
        return self.areaArray.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.heightPickerComponent;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.selectedArray = self.dataArray[row][@"cities"];
        
        [self.cityArray removeAllObjects];
        [self.selectedArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.cityArray addObject:obj[@"city"]];
        }];
        
        self.areaArray = [NSMutableArray arrayWithArray:[self.selectedArray firstObject][@"areas"]];
        
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
    }else if (component == 1) {
        if (self.selectedArray.count == 0) {
            self.selectedArray = [self.dataArray firstObject][@"cities"];
        }
        
        self.areaArray = [NSMutableArray arrayWithArray:[self.selectedArray objectAtIndex:row][@"areas"]];
        
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
    }
    
    [self reloadData];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    NSString *text;
    if (component == 0) {
        text =  self.provinceArray[row];
    }else if (component == 1){
        text =  self.cityArray[row];
    }else{
        if (self.areaArray.count > 0) {
            text = self.areaArray[row];
        }else{
            text =  @"";
        }
    }
    
    UILabel *label = [[UILabel alloc]init];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:17]];
    [label setText:text];
    return label;
}

#pragma mark - 懒加载数据源属性
- (NSArray *)dataArray
{
    if (!_dataArray) {
        NSString *path = [[NSBundle bundleForClass:[SKCityPickerView class]] pathForResource:@"area" ofType:@"plist"];
        _dataArray = [[NSArray alloc] initWithContentsOfFile:path];
    }
    return _dataArray;
}

- (NSMutableArray *)provinceArray
{
    if (!_provinceArray) {
        _provinceArray = [NSMutableArray array];
    }
    return _provinceArray;
}

- (NSMutableArray *)cityArray
{
    if (!_cityArray) {
        _cityArray = [NSMutableArray array];
    }
    return _cityArray;
}

- (NSMutableArray *)areaArray
{
    if (!_areaArray) {
        _areaArray = [NSMutableArray array];
    }
    return _areaArray;
}

- (NSMutableArray *)selectedArray
{
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

#pragma mark - 懒加载控件属性
- (UIView *)contentView
{
    if (!_contentView) {
        CGFloat contentX = 0;
        CGFloat contentY = SKScreenHeight;
        CGFloat contentW = SKScreenWidth;
        CGFloat contentH = self.heightPicker;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        [_contentView setBackgroundColor:[UIColor whiteColor]];
    }
    return _contentView;
}

- (UIView *)topLine
{
    if (!_topLine) {
        CGFloat topLineX = 0;
        CGFloat topLineY = SKSystemHeight - SKLineHeight;
        CGFloat topLineW = SKScreenWidth;
        CGFloat topLineH = SKLineHeight;
        _topLine = [[UIView alloc]initWithFrame:CGRectMake(topLineX, topLineY, topLineW, topLineH)];
        _topLine.backgroundColor = self.borderButtonColor;
    }
    return _topLine;
}

- (UIPickerView *)pickerView
{
    if (!_pickerView) {
        CGFloat pickerW = SKScreenWidth;
        CGFloat pickerH = self.contentView.frame.size.height - SKSystemHeight;
        CGFloat pickerX = 0;
        CGFloat pickerY = SKSystemHeight;
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(pickerX, pickerY, pickerW, pickerH)];
        [_pickerView setBackgroundColor:[UIColor whiteColor]];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (UIButton *)leftButton
{
    if (!_leftButton) {
        CGFloat leftW = SKSystemHeight;
        CGFloat leftH = SKSystemHeight - SKSmallPadding * 2;
        CGFloat leftX = SKBigPadding;
        CGFloat leftY = SKSmallPadding;
        _leftButton = [[UIButton alloc]initWithFrame:CGRectMake(leftX, leftY, leftW, leftH)];
        [_leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [_leftButton setTitleColor:self.titleColor forState:UIControlStateNormal];
        [_leftButton.layer setBorderColor:self.borderButtonColor.CGColor];
        [_leftButton.layer setBorderWidth:SKLineHeight];
        [_leftButton.layer setCornerRadius:4];
        [_leftButton.titleLabel setFont:self.font];
        [_leftButton addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)righBtutton
{
    if (!_righBtutton) {
        CGFloat rightW = self.leftButton.frame.size.width;
        CGFloat rightH = self.leftButton.frame.size.height;
        CGFloat rightX = SKScreenWidth - rightW - SKBigPadding;
        CGFloat rightY = self.leftButton.frame.origin.y;
        _righBtutton = [[UIButton alloc]initWithFrame:CGRectMake(rightX, rightY, rightW, rightH)];
        [_righBtutton setTitle:@"确定" forState:UIControlStateNormal];
        [_righBtutton setTitleColor:self.titleColor forState:UIControlStateNormal];
        [_righBtutton.layer setBorderColor:self.borderButtonColor.CGColor];
        [_righBtutton.layer setBorderWidth:SKLineHeight];
        [_righBtutton.layer setCornerRadius:4];
        [_righBtutton.titleLabel setFont:self.font];
        [_righBtutton addTarget:self action:@selector(buttonRightClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _righBtutton;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle) {
        CGFloat titleX = SKSmallPadding * 2 + self.leftButton.frame.size.width;
        CGFloat titleY = 0;
        CGFloat titleW = SKScreenWidth - titleX * 2;
        CGFloat titleH = SKSystemHeight - SKLineHeight;
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(titleX, titleY, titleW, titleH)];
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.textColor = self.titleColor;
        _labelTitle.text = self.title;
        _labelTitle.font = self.font;
        _labelTitle.adjustsFontSizeToFitWidth = YES;
    }
    return _labelTitle;
}

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        CGFloat lineX = 0;
        CGFloat lineY = self.pickerView.frame.origin.y + self.pickerView.frame.size.height;
        CGFloat lineW = self.contentView.frame.size.width;
        CGFloat lineH = SKLineHeight;
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
        _bottomLine.backgroundColor = self.borderButtonColor;
    }
    return _bottomLine;
}

#pragma mark - --- setter

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.labelTitle.text = title;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    self.leftButton.titleLabel.font = font;
    self.righBtutton.titleLabel.font = font;
    self.labelTitle.font = font;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.labelTitle.textColor = titleColor;
    [self.leftButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.righBtutton setTitleColor:titleColor forState:UIControlStateNormal];
}

- (void)setBorderButtonColor:(UIColor *)borderButtonColor
{
    _borderButtonColor = borderButtonColor;
    self.leftButton.layer.borderColor = self.borderButtonColor.CGColor;
    self.righBtutton.layer.borderColor = self.borderButtonColor.CGColor;
}

- (void)setHeightPicker:(CGFloat)heightPicker
{
    _heightPicker = heightPicker;
    CGRect frame = self.contentView.frame;
    frame.size.height = heightPicker;
    self.contentView.frame = frame;
}

- (void)setShowType:(SKCityPickerViewShowType)showType {
    _showType = showType;
    if (showType == SKCityPickerViewShowTypeCenter) {
        CGRect frame = self.contentView.frame;
        frame.size.height += SKSystemHeight;
        self.contentView.frame = frame;
    }
}

@end
