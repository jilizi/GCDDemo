//
//  ViewController.m
//  GCDDemo
//
//  Created by YQ on 2017/1/16.
//  Copyright © 2017年 杨强. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self GCD_semaphore];
    
//    [self GCD_timer];
    
}


- (void)GCD_Group{
    
     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_group_t group = dispatch_group_create();
     dispatch_group_async(group, queue, ^{
         NSLog(@"%@",group);
         NSLog(@"blok0");
     });
     dispatch_group_async(group, queue, ^{
         NSLog(@"block1");
     });
     dispatch_group_async(group, queue, ^{
         NSLog(@"block2");
     });
     dispatch_group_notify(group, queue, ^{
         NSLog(@"done");
     });
//     dispatch_release(group); // 只有在MRC下才这么写,ARC下会自动管理
    
}

- (void)GCD_Barrier{
    
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.ForBarrier", DISPATCH_QUEUE_CONCURRENT);
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%ld", i);
        });
    }
    dispatch_barrier_async(queue, ^{
        NSLog(@"--- ---");
    });
    for (NSInteger i = 5; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%ld", i);
        });
    }
}

// 使用信号量可以做到并行队列串行执行 ，而且当信号量为1时是按照代码顺序执行的
- (void)GCD_semaphore{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(globalQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//当信号量>=1时，才会执行下面的代码，等待信号量-1
        NSLog(@"first start");
        NSLog(@"first end");
        dispatch_semaphore_signal(semaphore);//信号量+1
    });
    dispatch_async(globalQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"second start");
        NSLog(@"second end");
        dispatch_semaphore_signal(semaphore);//信号量+1
    });
    dispatch_async(globalQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"third start");
        NSLog(@"third end");
        dispatch_semaphore_signal(semaphore);//信号量+1
    });
    
    
/*  dispatch_semaphore_wait 函数的作用：
 1、如果dsema信号量的值大于0，该函数所处线程就继续执行下面的语句，
 并且将信号量的值减1; 
 2、如果desema的值为0，那么这个函数就阻塞当前线程等待timeout（注意timeout的类型为dispatch_time_t，
 需要传入对应的类型参数），如果等待的期间desema的值被dispatch_semaphore_signal函数加1了，且该函数（即dispatch_semaphore_wait）所处线程获得了信号量，那么就继续向下执行并将信号量减1。
 
 3、如果等待期间没有获取到信号量或者信号量的值一直为0，那么等到timeout时，其所处线程自动执行其后语句。
*/
 // 异步里面的同步
    for (int i = 0; i < 10; i++) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(globalQueue, ^{
            NSLog(@"%d start",i);
            //            NSLog(@"%d end",i);
            dispatch_semaphore_signal(semaphore);
        });
    }
    
}

//原因是我们创建的这个_timer在这段代码执行完后就被销毁了，可以看出GCD并没有管理它的内存，并没有强持有它，所以我们需要自己想办法让它不被销毁
- (void)GCD_timer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //GCD创建的timer必须被持有
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    /*
     para1: 间隔几秒
     para2: leeway (翻译:最小的余地)精确度
     */
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        //要执行的任务
        NSLog(@"***");
    });
    
    //开始执行定时器
    dispatch_resume(self.timer);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
