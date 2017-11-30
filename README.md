# RefreshAnimation
刷新动画
最近项目中有一个自定义的刷新控件，以前用过很多第三方，所以这次决定自己写一个来用，先看下效果吧：
![这里写图片描述](http://img.blog.csdn.net/20171130162830335?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQ29kaW5nRmlyZQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

这个效果分解一下可以分为三步：
1.拉伸放大图片；
2.松手开始刷新，背景开始旋转；
3.刷新完毕，回到起始位置；

一步步带你来看这里怎么写：
1.拉伸放大图片：
图片大小一开始为0，随着拉伸图片大小开始放大，达到指定大小后不再改变；

```
/*
在scrollView的代理方法中这么写，往下拖拽偏移量小于0，按照偏移量控制图片放大，博主这里选择直接改变frame，你也可以选择用transform方法来写，提供这么一种思路。
*/
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
```
按照上面来写还不够，要考虑到往上托送造成的影响，所以要加上一个限制，必须偏移量小于0才能触发：

```
    if (tmpTableView.contentOffset.y < 0) {
    
    }
```


2.松手开始刷新，背景开始旋转
松手后的动作也是通过scrollView的代理方法来捕捉的，

```
/*
当偏移量超过80的时候才开始刷新，这时候改变状态为刷新状态，底部背景图开始旋转，这个旋转动画是个问题，看下面
*/
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
```

旋转动画：

```
/*
这是一种比较好的写法，还有一种通过UIView来选择，在完成的block中自调用的方法，这里提供一种思路，供大家参考，有兴趣可以写下。下面的那个代理来解释下，这里是在动画执行结束后拿到回调的代理，看下面
*/
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
```

3.刷新完毕，回到起始位置
在动画执行结束的代理中删除动画和相关视图，并回到起始位置：

```
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
```

以上还需要在scrollView的滚动代理中做一些限制，完整代码放这里：

```
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

```



最后，放上Demo的下载地址，需要的自行下载。
[点击下载](https://github.com/codeliu6572/RefreshAnimation)




