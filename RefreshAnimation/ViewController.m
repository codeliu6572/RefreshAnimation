//
//  ViewController.m
//  RefreshAnimation
//
//  Created by 刘浩浩 on 2017/11/29.
//  Copyright © 2017年 CodingFire. All rights reserved.
//

#import "ViewController.h"



#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate>
{
    UITableView *tmpTableView;
    CABasicAnimation *_rotationAnimation;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIView *view = [[UIView alloc]initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    self.view.backgroundColor = [UIColor whiteColor];
    tmpTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64) style:UITableViewStylePlain];
    tmpTableView.delegate = self;
    tmpTableView.dataSource = self;
    [self.view addSubview:tmpTableView];
    tmpTableView.backgroundColor = [UIColor orangeColor];
    tmpTableView.backgroundView = view;


}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    if (tmpTableView.contentOffset.y < 0) {
        
        if (_refreshImageView1) {
            if (tmpTableView.contentOffset.y > -100) {
                float width = fabs(tmpTableView.contentOffset.y);
                if (width > 46) {
                    width = 46;
                }
                _refreshImageView1.frame = CGRectMake(WIDTH / 2 - width / 2, 10, width / 46 * 46, width / 46 * 46);
                _refreshImageView2.frame = CGRectMake(WIDTH / 2 - width / 2, 10, width / 46 * 46, width / 46 * 46);
                _refereshLabel.text = @"下拉刷新";
                
            }
            else
            {
                _refreshImageView1.frame = CGRectMake(WIDTH / 2 - 46 / 2, 10, 46, 46);
                _refreshImageView2.frame = CGRectMake(WIDTH / 2 - 46 / 2, 10, 46, 46);
                if ([_refereshLabel.text isEqualToString:@"下拉刷新"]) {
                    _refereshLabel.text = @"松开刷新...";
                }
            }
        }
        
        if (!_refreshImageView1) {
            _refreshImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH / 2, 10, 0, 0)];
            _refreshImageView1.image = [UIImage imageNamed:@"icon_base"];
            [tmpTableView.backgroundView addSubview:_refreshImageView1];
            
            _refreshImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH / 2, 10, 0, 0)];
            _refreshImageView2.image = [UIImage imageNamed:@"icon_top"];
            [tmpTableView.backgroundView addSubview:_refreshImageView2];
            
            _refereshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 56, WIDTH, 30)];
            _refereshLabel.text = @"下拉刷新";
            _refereshLabel.textColor = [UIColor grayColor];
            _refereshLabel.font = [UIFont systemFontOfSize:12];
            _refereshLabel.textAlignment = NSTextAlignmentCenter;
            [tmpTableView.backgroundView addSubview:_refereshLabel];
        }
    }
   

    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (tmpTableView.contentOffset.y < 0) {
        if (tmpTableView.contentOffset.y > -80) {
            return;
        }
        [self startAnimation];

        [UIView animateWithDuration:0.5 animations:^{
            tmpTableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
            //        tmpTableView.scrollEnabled = NO;
            tmpTableView.decelerationRate = 0.0;
            
        }];
        _refereshLabel.text = @"正在刷新...";
    }

}

- (void)startAnimation{
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //让其在z轴旋转
    _rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    //旋转角度
    _rotationAnimation.duration = 1;
    //旋转周期
    _rotationAnimation.cumulative = YES;
    //旋转累加角度
    _rotationAnimation.repeatCount = 3;
    //旋转次数
    _rotationAnimation.delegate = self;
    [_refreshImageView1.layer addAnimation:_rotationAnimation forKey:@"rotationAnimation"];
}

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag {
    //set the backgroundColor property to match animation toValue
    [_refreshImageView1.layer removeAllAnimations];
    [UIView animateWithDuration:0.5 animations:^{
        tmpTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
    }completion:^(BOOL finished) {
        [_refreshImageView2 removeFromSuperview];
        [_refreshImageView1 removeFromSuperview];
        [_refereshLabel removeFromSuperview];
        _refreshImageView2 = nil;
        _refreshImageView1 = nil;
        _refereshLabel = nil;
    }];
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d行",indexPath.row];
    
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
