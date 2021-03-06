//
//  ViewController.m
//  YBPromiseDemo
//
//  Created by fengbang on 2020/8/14.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import "ViewController.h"
#import "FBLPromises.h"



#define FULL_SCREEN_W ([UIScreen mainScreen].bounds.size.width)
#define FULL_SCREEN_H ([UIScreen mainScreen].bounds.size.height)


@interface ViewController ()

@end

@implementation ViewController

#pragma mark - override

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configButton];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"点击了屏幕!!!");
}

#pragma mark - initUI

- (void)configButton {
    CGFloat button_w = 150;
    CGFloat button_h = 50;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(FULL_SCREEN_W/2 - button_w/2, 100, button_w, button_h)];
    [button setTitle:@"测试" forState:UIControlStateNormal];
    //[button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(promiseAction:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:button];
    
}

#pragma mark - initData

- (void)initData {
    
}

#pragma mark - actions

/// Promise使用文档：https://github.com/google/promises/blob/master/g3doc/index.md
/// @param sender sender description
- (void)promiseAction:(id)sender {
    
    //测试then pipeline
    //[self testThenPipeline];
    
    //测试catch pipeline
    //[self testCatchPipeline];
    
    //测试同步 promise all
    //[self testPromiseAll];
    
    //测试 promise default queue all
    //[self testPromiseAsyncMainQueueAll];
    
    //测试promise aysnc custom queue all
    //[self testPromiseAsyncCustomQueueAll];
    
    //测试异步管道
    //[self testAsyncPipeline];
    
    //测试异步wait
    //[self testAsyncAwait];
    
    //测试链式语法
    //[self testDotChain];
    
    //测试主线程弹窗是否会阻断promise
    //[self testPromiseAlertActionAll];
    
    //测试主线程弹窗是否会阻断promiseAwait（死锁）
    //[self testPromiseAlertActionAwaitDeadlock];
    
    //测试主线程promise弹窗链
    //[self testPromiseAlertActionAwaitChain];
    
    //测试主线程promise弹窗链多个方法调用
    [self testPromiseAlertActionSerial];
}

/// 测试then pipeline
- (void)testThenPipeline {
    [[[[self work1:@"10"] then:^id(NSString *string) {
      return [self work2:string];
    }] then:^id(NSNumber *number) {
      return [self work3:number];
    }] then:^id(NSNumber *number) {
      NSLog(@"then pipeline done:%@", number);  // 100
      return number;
    }];
}

/// 测试catch pipeline
- (void)testCatchPipeline {
    [[[[[self work1:@"abc"] then:^id(NSString *string) {
      return [self work2:string];
    }] then:^id(NSNumber *number) {
      return [self work3:number];  // Never executed.
    }] then:^id(NSNumber *number) {
      NSLog(@"%@", number);  // Never executed.
      return number;
    }] catch:^(NSError *error) {
      NSLog(@"Cannot convert string to number: %@", error);
    }];
}

/// 测试同步promise all
- (void)testPromiseAll {
    FBLPromise *do1 = [self do1:[NSURL URLWithString:@"abc"]];
    FBLPromise *do2 = [self do2:[NSURL URLWithString:@"def"]];
    [[FBLPromise all:@[do1,do2]] then:^id _Nullable(NSArray * _Nullable value) {
        NSLog(@"sync promise all done!!!");
        return nil;
    }];
    
}

/// 测试 promise default queue all
- (void)testPromiseAsyncMainQueueAll {
    FBLPromise *async1 = [self async1:[NSURL URLWithString:@"abc"]];
    FBLPromise *async2 = [self async2:[NSURL URLWithString:@"def"]];
    NSMutableArray *mutAsyncArray = [NSMutableArray array];
    [mutAsyncArray addObject:async1];
    [mutAsyncArray addObject:async2];
    
    [[FBLPromise all:mutAsyncArray.copy] then:^id _Nullable(NSArray * _Nullable value) {
        NSLog(@"async default queue all calues: %@",value);
        NSLog(@"async default queue all task done!!!");
        return nil;
    }];
}

/// 测试promise aysnc custom queue all
- (void)testPromiseAsyncCustomQueueAll {
    //测试
    FBLPromise *task1 = [self task1:[NSURL URLWithString:@"abc"]];
    FBLPromise *task2 = [self task2:[NSURL URLWithString:@"def"]];
    FBLPromise *task3 = [self task3:[NSURL URLWithString:@"ghi"]];
    NSMutableArray *mutTaskArray = [NSMutableArray array];
    [mutTaskArray addObject:task1];
    [mutTaskArray addObject:task2];
    [mutTaskArray addObject:task3];
    
    dispatch_queue_t queue = dispatch_queue_create("com.all.yb", DISPATCH_QUEUE_SERIAL);
    [[FBLPromise onQueue:queue all:mutTaskArray.copy] then:^id _Nullable(NSArray * _Nullable value) {
        NSLog(@"async custom queue all calues: %@",value);
        NSLog(@"async custom queue all task done!!!");
        return nil;
    }];
    
}

/// 测试异步管道
- (void)testAsyncPipeline {
    
    [[[[self task1:[NSURL URLWithString:@"abc"]] then:^id _Nullable(NSString * _Nullable value) {
        NSLog(@"task 1 then result:%@",value);
        return [self task2:[NSURL URLWithString:@"def"]];
    }] then:^id _Nullable(id  _Nullable value) {
        NSLog(@"task 2 then result:%@",value);
        return [self task3:[NSURL URLWithString:@"ghi"]];
    }] then:^id _Nullable(id  _Nullable value) {
        NSLog(@"task 3 then result:%@",value);
        return @"end";
    }];
    
}

/// 测试异步wait
- (void)testAsyncAwait {
    NSError *error;
    NSString *task1 = FBLPromiseAwait([self task1:[NSURL URLWithString:@"abc"]], &error);
    if (error) {
    }
    NSLog(@"task 1 excute result: %@",task1);
    NSString *task2 = FBLPromiseAwait([self task2:[NSURL URLWithString:@"def"]], &error);
    if (error) {
    }
    NSLog(@"task 2 excute result: %@",task2);
    NSString *task3 = FBLPromiseAwait([self task3:[NSURL URLWithString:@"ghi"]], &error);
    if (error) {
    }
    NSLog(@"task 3 excute result: %@",task3);
}

/**
 测试链式语法
 Dot-syntax in Objective-C
 https://github.com/google/promises/blob/master/g3doc/index.md#dot-syntax-in-objective-c
 */
- (void)testDotChain {
    
    [self work1:@"abc"]
    .then(^id(NSString *string) {
      return [self work2:string];
    })
    .then(^id(NSNumber *number) {
      return [self work3:number];
    })
    .then(^id(NSNumber *number) {
      NSLog(@"%@", number);
      return nil;
    })
    .catch(^(NSError *error) {
      NSLog(@"Cannot convert string to number: %@", error);
    });
}

/// 测试主线程弹窗是否会阻断promise
- (void)testPromiseAlertActionAll {
    FBLPromise *alertAsync1 = [self asyncPromiseAlert1:[NSURL URLWithString:@"abc"]];
    FBLPromise *alertAsync2 = [self asyncPromiseAlert2:[NSURL URLWithString:@"def"]];
    NSMutableArray *mutAlertArray = [NSMutableArray array];
    [mutAlertArray addObject:alertAsync1];
    [mutAlertArray addObject:alertAsync2];
    
    //dispatch_queue_t queue = dispatch_queue_create("com.all.yb", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    [[FBLPromise onQueue:mainQueue all:mutAlertArray.copy] then:^id _Nullable(NSArray * _Nullable value) {
        NSLog(@"async promise alert all calues: %@",value);
        NSLog(@"async promise alert all task done!!!");
        return nil;
    }];
}

/// 测试主线程弹窗是否会阻断promiseAwait-死锁（warnging: 此种写法主队列互相等待了，造成死锁）
- (void)testPromiseAlertActionAwaitDeadlock {
#warning 死锁
    NSError *error;
    
    FBLPromise *alertAsync1 = [self asyncPromiseAlert1:[NSURL URLWithString:@"abc"]];
    NSString *task1 = FBLPromiseAwait(alertAsync1, &error);
    if (error) {
        NSLog(@"alert async task 1 error:%@",error);
        return;
    }
    NSLog(@"alert async task 1 excute result: %@",task1);
    
    FBLPromise *alertAsync2 = [self asyncPromiseAlert2:[NSURL URLWithString:@"def"]];
    NSString *task2 = FBLPromiseAwait(alertAsync2, &error);
    if (error) {
        NSLog(@"alert async task 2 error:%@",error);
        return;
    }
    NSLog(@"alert async task 2 excute result: %@",task2);
    
    FBLPromise *alertAsync3 = [self asyncPromiseAlert3:[NSURL URLWithString:@"ghi"]];
    NSString *task3 = FBLPromiseAwait(alertAsync3, &error);
    if (error) {
        NSLog(@"alert async task 3 error:%@",error);
        return;
    }
    NSLog(@"alert async task 3 excute result: %@",task3);
    
}

/// 测试主线程promise弹窗链
- (void)testPromiseAlertActionAwaitChain {
    NSError *error;

#warning 注释部分写法仍然导致死锁
//    FBLPromise *alertAsync1 = [self asyncPromiseAlertAwait1:[NSURL URLWithString:@"abc"]];
//    NSString *task1 = FBLPromiseAwait(alertAsync1, &error);
//    if (error) {
//        NSLog(@"alert async await task 1 error:%@",error);
//        return;
//    }
//    NSLog(@"alert async await task 1 excute result: %@",task1);
    
//    FBLPromise *alertAsync2 = [self asyncPromiseAlertAwait2:[NSURL URLWithString:@"def"]];
//    NSString *task2 = FBLPromiseAwait(alertAsync2, &error);
//    if (error) {
//        NSLog(@"alert async await task 2 error:%@",error);
//        return;
//    }
//    NSLog(@"alert async await task 2 excute result: %@",task2);
//
//    FBLPromise *alertAsync3 = [self asyncPromiseAlertAwait3:[NSURL URLWithString:@"ghi"]];
//    NSString *task3 = FBLPromiseAwait(alertAsync3, &error);
//    if (error) {
//        NSLog(@"alert async await task 3 error:%@",error);
//        return;
//    }
//    NSLog(@"alert async await task 3 excute result: %@",task3);
    
    
    [[[[[self asyncPromiseAlertAwait1:[NSURL URLWithString:@"abc"]] then:^id _Nullable(NSString * _Nullable value) {
        NSLog(@"task 1 then:%@",value);
        return [self asyncPromiseAlertAwait2:[NSURL URLWithString:@"def"]];
    }] then:^id _Nullable(NSString *  _Nullable value) {
        NSLog(@"task 2 then:%@",value);
        if ([value isEqualToString:@"stop"]) {
            NSLog(@"in the task 2, end task");
            return @"in the task 2, end task";
        }
        return [self asyncPromiseAlertAwait3:[NSURL URLWithString:@"ghi"]];
    }] then:^id _Nullable(id  _Nullable value) {
        NSLog(@"task 3 then:%@",value);
        return @"end task";
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"await chain error:%@",error);
    }];
    
}

/// 测试主线程promise弹窗链多个方法调用
- (void)testPromiseAlertActionSerial {
    
    /**
     一步一个方法，在方法末尾判断是否调起下一个方法
     */
    
    [self testPromiseAlertActionSerial1];
}

- (void)testPromiseAlertActionSerial1 {
    FBLPromise *promise = [self asyncPromiseAlertAwait1:[NSURL URLWithString:@"abc"]];
    [[promise then:^id _Nullable(id  _Nullable value) {
        NSLog(@"task 1 then parameter:%@",value);
        [self testPromiseAlertActionSerial2];
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"task 1 error:%@",error);
    }];
}

- (void)testPromiseAlertActionSerial2 {
    FBLPromise *promise = [self asyncPromiseAlertAwait2:[NSURL URLWithString:@"def"]];
    [[promise then:^id _Nullable(id  _Nullable value) {
        NSLog(@"task 2 then parameter:%@",value);
        if ([value isEqualToString:@"stop"]) {
            NSLog(@"in the task 2, end task");
            return @"in the task 2, end task";
        }
        [self testPromiseAlertActionSerial3];
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"task 2 error:%@",error);
    }];
}

- (void)testPromiseAlertActionSerial3 {
    FBLPromise *promise = [self asyncPromiseAlertAwait3:[NSURL URLWithString:@"ghi"]];
    [[promise then:^id _Nullable(id  _Nullable value) {
        NSLog(@"task 3 then parameter:%@",value);
        NSLog(@"all task end!!!");
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"task 3 error:%@",error);
    }];
}

#pragma mark - promise task

- (FBLPromise<NSString *> *)task1:(NSURL *)anURL {
    dispatch_queue_t queue = dispatch_queue_create("com.task1.yb", DISPATCH_QUEUE_CONCURRENT);
    return [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(1000 * 1000);//1000ms
        NSLog(@"task 1");
        fulfill(@"task 1");
    }];
}

- (FBLPromise<NSString *> *)task2:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    dispatch_queue_t queue = dispatch_queue_create("com.task2.yb", DISPATCH_QUEUE_CONCURRENT);
    return [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(2000 * 1000);//2000ms
        NSLog(@"task 2");
        fulfill(@"task 2");
    }];
    
}

- (FBLPromise<NSString *> *)task3:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    dispatch_queue_t queue = dispatch_queue_create("com.task3.yb", DISPATCH_QUEUE_CONCURRENT);
    return [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(1500 * 1000);//1500ms
        NSLog(@"task 3");
        fulfill(@"task 3");
    }];
    
}

- (FBLPromise<NSString *> *)async1:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    return [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(2000 * 1000);//2000ms
        NSLog(@"async 1");
        fulfill(@"async 1");
    }];
    
}

- (FBLPromise<NSString *> *)async2:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    return [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(2200 * 1000);//2200ms
        NSLog(@"async 2");
        fulfill(@"async 2");
    }];
    
}

- (FBLPromise<NSString *> *)asyncPromiseAlert1:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    NSString *absoluteString = anURL.absoluteString;
    dispatch_queue_t queue = dispatch_queue_create("com.task1.yb", DISPATCH_QUEUE_CONCURRENT);
    return [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(0500 * 1000);//0500ms
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"asyncPromiseAlert 1" message:@"test asyncPromiseAlert 1 message" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"async 1");
                fulfill(absoluteString);
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    }];
    
}

- (FBLPromise<NSString *> *)asyncPromiseAlert2:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    NSString *absoluteString = anURL.absoluteString;
    dispatch_queue_t queue = dispatch_queue_create("com.task2.yb", DISPATCH_QUEUE_CONCURRENT);
    return [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(2200 * 1000);//2200ms
        NSLog(@"async 2");
        fulfill(absoluteString);
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"asyncPromiseAlert 2" message:@"test asyncPromiseAlert 2 message" preferredStyle:UIAlertControllerStyleAlert];
//            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            }]];
//            [self presentViewController:alert animated:YES completion:nil];
//        });
        
    }];
    
}

- (FBLPromise<NSString *> *)asyncPromiseAlert3:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    NSString *absoluteString = anURL.absoluteString;
    dispatch_queue_t queue = dispatch_queue_create("com.task3.yb", DISPATCH_QUEUE_CONCURRENT);
    return [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(3000 * 1000);//3000ms
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"asyncPromiseAlert 3" message:@"test asyncPromiseAlert 3 message" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"async 3");
                fulfill(absoluteString);
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    }];
    
}

- (FBLPromise<NSString *> *)asyncPromiseAlertAwait1:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:@"task 1 error!!!"];
    }
    NSString *absoluteString = anURL.absoluteString;
    dispatch_queue_t queue = dispatch_queue_create("com.task1.yb", DISPATCH_QUEUE_CONCURRENT);
    FBLPromise *task = [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(0500 * 1000);//0500ms
        NSLog(@"async 1");
        fulfill(absoluteString);
    }];
    NSError *error = nil;
    NSString *string = FBLPromiseAwait(task, &error);
    FBLPromise *promise = [FBLPromise pendingPromise];
    if (string && !error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"asyncPromiseAlert 1" message:@"test asyncPromiseAlert 1 message" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [promise fulfill:absoluteString];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        [promise fulfill:@"task 1 error!!!"];
    }
    
    return promise;
}

- (FBLPromise<NSString *> *)asyncPromiseAlertAwait2:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    NSString *absoluteString = anURL.absoluteString;
    dispatch_queue_t queue = dispatch_queue_create("com.task2.yb", DISPATCH_QUEUE_CONCURRENT);
    FBLPromise *task = [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(2200 * 1000);//2200ms
        NSLog(@"async 2");
        fulfill(absoluteString);
    }];
    
    FBLPromise *promise = [FBLPromise pendingPromise];
    NSError *error = nil;
    NSString *string = FBLPromiseAwait(task, &error);
    if (string && !error) {
        NSUInteger random = arc4random();
        if (random % 3 == 0) {
            [promise fulfill:absoluteString];
        } else if (random % 3 == 1) {
            NSError *randomError = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"reason":@"random error reason!!!"}];
            [promise reject:randomError];
        } else {
            [promise fulfill:@"stop"];
        }
    }else {
        [promise fulfill:@"task 2 error!!!"];
    }
    return promise;
}

- (FBLPromise<NSString *> *)asyncPromiseAlertAwait3:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:@"task 3 error!!!"];
    }
    NSString *absoluteString = anURL.absoluteString;
    dispatch_queue_t queue = dispatch_queue_create("com.task3.yb", DISPATCH_QUEUE_CONCURRENT);
    FBLPromise *task = [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(3000 * 1000);//3000ms
        NSLog(@"async 3");
        fulfill(absoluteString);
    }];
    
    FBLPromise *promise = [FBLPromise pendingPromise];
    NSError *error = nil;
    NSString *string = FBLPromiseAwait(task, &error);
    if (string && !error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"asyncPromiseAlert 3" message:@"test asyncPromiseAlert 3 message" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [promise fulfill:absoluteString];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        [promise fulfill:@"task 3 error!!!"];
    }
    return promise;
    
}

- (FBLPromise<NSString *> *)do1:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    return [FBLPromise do:^id _Nullable{
        usleep(2000 * 1000);//2000ms
        NSLog(@"do 1");
        return @"do 1";
    }];
    
}

- (FBLPromise<NSString *> *)do2:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    return [FBLPromise do:^id _Nullable{
        usleep(1000 * 1000);//1000ms
        NSLog(@"do 2");
        return @"do 2";
    }];
    
}

- (FBLPromise<NSString *> *)pending1:(NSURL *)anURL {
    FBLPromise<NSString *> *promise = [FBLPromise pendingPromise];
    // ...
//    if (success) {
//      [promise fulfill:@"Hello world"];
//    } else {
//      [promise reject:someError];
//    }
    
    return promise;
}

- (void)then {
    FBLPromise<NSNumber *> *numberPromise = [FBLPromise resolvedWith:@42];

    // Return another promise.
    FBLPromise<NSString *> *chainedStringPromise0 = [numberPromise then:^id(NSNumber *number) {
        return number.stringValue;
    }];

    // Return any value.
    FBLPromise<NSString *> *chainedStringPromise1 = [numberPromise then:^id(NSNumber *number) {
      return [number stringValue];
    }];

    // Return an error.
    FBLPromise<NSString *> *chainedStringPromise2 = [numberPromise then:^id(NSNumber *number) {
      return [NSError errorWithDomain:@"" code:0 userInfo:nil];
    }];

    // Fake void return.
    FBLPromise<NSString *> *chainedStringPromise3 = [numberPromise then:^id(NSNumber *number) {
      NSLog(@"%@", number);
      return nil;
      // OR
      return number;
    }];
    
    dispatch_queue_t queue = dispatch_queue_create("com.then.yb", DISPATCH_QUEUE_CONCURRENT);
    [numberPromise onQueue:queue then:^id(NSNumber *number) {
      return number.stringValue;
    }];
}

- (void)thenPipeline {
    [[[[self work1:@"10"] then:^id(NSString *string) {
      return [self work2:string];
    }] then:^id(NSNumber *number) {
      return [self work3:number];
    }] then:^id(NSNumber *number) {
      NSLog(@"%@", number);  // 100
      return number;
    }];
}

- (void)catchPipeline {
    [[[[[self work1:@"abc"] then:^id(NSString *string) {
      return [self work2:string];
    }] then:^id(NSNumber *number) {
      return [self work3:number];  // Never executed.
    }] then:^id(NSNumber *number) {
      NSLog(@"%@", number);  // Never executed.
      return number;
    }] catch:^(NSError *error) {
      NSLog(@"Cannot convert string to number: %@", error);
    }];
}

- (FBLPromise<NSString *> *)work1:(NSString *)string {
  return [FBLPromise do:^id {
      NSLog(@"excute work 1");
      return string;
  }];
}

- (FBLPromise<NSNumber *> *)work2:(NSString *)string {
  return [FBLPromise do:^id {
      NSLog(@"excute work 2");
      NSInteger number = string.integerValue;
      return number > 0 ? @(number) : [NSError errorWithDomain:@"" code:0 userInfo:nil];
  }];
}

- (NSNumber *)work3:(NSNumber *)number {
    NSLog(@"excute work 3");
    return @(number.integerValue * number.integerValue);
}

- (void)all {
    FBLPromise<NSString *>*promise1 = [FBLPromise do:^id _Nullable{
        return @"all test promise 1";
    }];
    FBLPromise<NSString *>*promise2 = [FBLPromise do:^id _Nullable{
        return @"all test promise 2";
    }];
    NSArray *promiseArr = @[promise1,promise2];

    // Promises of different types:
    [[FBLPromise
      all:promiseArr] then:^id _Nullable(NSArray * _Nullable value) {
        return @"all done";
    }];
}

- (void)always {
    FBLPromise<NSString *>*promise = [FBLPromise do:^id _Nullable{
        return @"always promise 1";
    }];
    [[[promise then:^id _Nullable(NSString * _Nullable value) {
        return @1;
    }] catch:^(NSError * _Nonnull error) {
        
    }] always:^{
        NSLog(@"always done!");
    }];
}

/// any is similar to all, but it fulfills even if some of the promises in the provided array are rejected. If all promises in the input array are rejected, the returned promise rejects with the same error as the last one that was rejected.
- (void)any {
    FBLPromise<NSString *>*promise1 = [FBLPromise do:^id _Nullable{
        return @"any test promise 1";
    }];
    FBLPromise<NSString *>*promise2 = [FBLPromise do:^id _Nullable{
        return @"any test promise 2";
    }];
    NSArray *promiseArr = @[promise1,promise2];
    // Promises of different types:
    [[FBLPromise
        any:promiseArr]
     then:^id _Nullable(NSArray * _Nullable value) {
        return @"any done";
    }];
}

- (void)await {
    
    FBLPromise<NSString *>*promise1 = [FBLPromise do:^id _Nullable{
        return @"await test promise 1";
    }];
    FBLPromise<NSString *>*promise2 = [FBLPromise do:^id _Nullable{
        return @"await test promise 2";
    }];
    FBLPromise<NSString *>*promise3 = [FBLPromise do:^id _Nullable{
        return @"await test promise 3";
    }];
    FBLPromise<NSString *>*promise4 = [FBLPromise do:^id _Nullable{
        return @"await test promise 4";
    }];
    FBLPromise<NSString *>*promise5 = [FBLPromise do:^id _Nullable{
        return @"await test promise 5";
    }];
    FBLPromise<NSString *>*promise6 = [FBLPromise do:^id _Nullable{
        return @"await test promise 6";
    }];
    [[[FBLPromise do:^id {
      NSError *error;
      NSNumber *minusFive = FBLPromiseAwait(promise1, &error);
      if (error) return error;
      NSNumber *twentyFive = FBLPromiseAwait(promise2, &error);
      if (error) return error;
      NSNumber *twenty = FBLPromiseAwait(promise3, &error);
      if (error) return error;
      NSNumber *five = FBLPromiseAwait(promise4, &error);
      if (error) return error;
      NSNumber *zero = FBLPromiseAwait(promise5, &error);
      if (error) return error;
      NSNumber *result = FBLPromiseAwait(promise6, &error);
      if (error) return error;
      return result;
    }] then:^id(NSNumber *result) {
      // ...
        return @"await done";
    }] catch:^(NSError *error) {
      // ...
    }];
}

/// delay returns a new pending promise that fulfills with the same value as self after the given delay, or rejects with the same error immediately. It may come in handy if you want to add an artificial pause to your promises chain.
- (void)delay {
    
}

/// race class method is similar to all, but the promise that it returns fulfills or rejects with the same resolution as the first promise that resolves among the given.
- (void)Race {
    
}

/// recover lets us catch an error and easily recover from it without breaking the rest of the promise chain.
- (void)recover {
    FBLPromise<NSString *>*promise = [FBLPromise do:^id _Nullable{
        return @"recover test promise 1";
    }];
    [[promise recover:^id(NSError *error) {
        NSLog(@"Fallback to default avatars due to error: %@", error);
        return @"recover excute";
    }] then:^id(id  _Nullable value) {
      //...
        return @"recover done";
    }];
}

/// reduce makes it easy to produce a single value from a collection of promises using a given closure or block. A benefit of using Promise.reduce over the Swift library's reduce(_:_:), is that Promise.reduce resolves the promise with the partial value for you so you don't have to chain on that promise inside the closure in order to get its value. Here's a simple example of how to reduce an array of numbers to a single string:
- (void)reduce {
    NSArray<NSNumber *> *numbers = @[ @1, @2, @3 ];
    [[[FBLPromise resolvedWith:@"0"] reduce:numbers
                                    combine:^id(NSString *partialString, NSNumber *nextNumber) {
      return [NSString stringWithFormat:@"%@, %@", partialString, nextNumber.stringValue];
    }] then:^id(NSString *string) {
      // Final result = 0, 1, 2, 3
      NSLog(@"reduce result = %@", string);
      return nil;
    }];
}

- (void)retry {
    NSURL *url = [NSURL URLWithString:@"https://myurl.com"];

    // Defaults to one retry attempt after a one second delay.
    [[[FBLPromise retry:^id {
      return [self fetchWithURL:url];
    }] then:^id(NSArray *values) {
      NSLog(@"%@", values);
      return nil;
    }] catch:^(NSError *error) {
      NSLog(@"%@", error);
    }];

    // Specifies a custom queue, 5 retry attempts, 2 second delay, and a predicate.
    dispatch_queue_t customQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    [[[FBLPromise onQueue:customQueue
        attempts:5
        delay:2.0
        condition:^BOOL(NSInteger remainingAttempts, NSError *error) {
          return error.code == NSURLErrorNotConnectedToInternet;
        }
        retry:^id {
          return [self fetchWithURL:url];
    }] then:^id(NSArray *values) {
      // Will enter `then` block if one of the retry attempts succeeds.
      NSLog(@"%@", values);
      return nil;
    }] catch:^(NSError *error) {
      // Will enter `catch` block if all retry attempts have been exhausted or the
      // given condition was not met.
      NSLog(@"%@", error);
    }];
}

- (FBLPromise<id> *)fetchWithURL:(NSURL *)url {
  return [FBLPromise wrap2ObjectsOrErrorCompletion:^(FBLPromise2ObjectsOrErrorCompletion handler) {
    [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:handler];
  }];
}

/// timeout allows us to wait for a promise for a time interval or reject it, if it doesn't resolve within the given time. A timed out promise rejects with NSError in FBLPromiseErrorDomain domain with code FBLPromiseErrorCodeTimedOut.
- (void)timeout {
    
}

- (void)validate {
    FBLPromise<NSString *>*promise = [FBLPromise do:^id _Nullable{
        return @"validate test promise 1";
    }];
    [[[promise validate:^BOOL(NSString *authToken) {
      return authToken.length > 0;
    }] then:^id(NSString *authToken) {
      return @"validate excute";
    }] catch:^(NSError *error) {
      NSLog(@"Failed to get auth token: %@", error);
    }];
}

- (FBLPromise<NSData*> *)wrap {
    return [FBLPromise wrapObjectOrErrorCompletion:^(FBLPromiseObjectOrErrorCompletion handler) {
        
    }];
}

- (void)advancedTopics {
    FBLPromise.defaultDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

/**
 Anti-patterns
 https://github.com/google/promises/blob/master/g3doc/index.md#anti-patterns
 */
- (void)antiPatterns {
    
}

//- (FBLPromise<NSData *> *)asyncCall {
//  FBLPromise<NSData *> *promise = [self doSomethingAsync];
//  [promise then:^id(NSData *result) {
//    return [self processData:result];
//  }];
//  return promise;
//}

//- (FBLPromise<NSData *> *)asyncCall {
//  FBLPromise<NSData *> *promise = [self doSomethingAsync];
//  return [promise then:^id(NSData *result) {
//    return [self processData:result];
//  }];
//}

/**
 Nested promises
 https://github.com/google/promises/blob/master/g3doc/index.md#nested-promises
 */
- (void)nestedPromises {
//    [[self loadSomething] then:^id(NSData *something) {
//      return [[self loadAnother] then:^id(NSData *another) {
//        return [self doSomethingWith:something andAnother:another];
//      }];
//    }];
    
//    [[self loadSomething] then:^id(NSData *something) {
//      return [self loadAnotherWithSomething:something];
//    }];
}

//- (FBLPromise<MyResult *> *)loadAnotherWithSomething:(NSData *)something {
//  return [[self loadAnother] then:^id(NSData *another) {
//    return [self doSomethingWith:something andAnother:another];
//  }];
//}

@end
