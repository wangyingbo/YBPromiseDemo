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

#pragma mark - initUI

- (void)configButton {
    CGFloat button_w = 100;
    CGFloat button_h = 50;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(FULL_SCREEN_W/2 - button_w/2, 100, button_w, button_h)];
    [button setTitle:@"测试" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(promiseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

#pragma mark - initData

#pragma mark - actions

/// Promise使用文档：https://github.com/google/promises/blob/master/g3doc/index.md
/// @param sender sender description
- (void)promiseAction:(id)sender {
    
}

#pragma mark - promise task

- (FBLPromise<NSString *> *)task1:(NSURL *)anURL {
    dispatch_queue_t queue = dispatch_queue_create("com.task1.yb", DISPATCH_QUEUE_CONCURRENT);
    FBLPromise<NSString *> *promise = [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(1000 * 1000);//1000ms
        NSLog(@"task 1");
    }];
    return promise;
}

- (FBLPromise<NSString *> *)task2:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    dispatch_queue_t queue = dispatch_queue_create("com.task2.yb", DISPATCH_QUEUE_CONCURRENT);
    FBLPromise<NSString *> *promise = [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(2000 * 1000);//2000ms
        NSLog(@"task 2");
    }];
    return promise;
    
}

- (FBLPromise<NSString *> *)task3:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    dispatch_queue_t queue = dispatch_queue_create("com.task3.yb", DISPATCH_QUEUE_CONCURRENT);
    FBLPromise<NSString *> *promise = [FBLPromise onQueue:queue async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(1500 * 1000);//1500ms
        NSLog(@"task 3");
    }];
    return promise;
    
}

- (FBLPromise<NSString *> *)async1:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    FBLPromise<NSString *> *promise = [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(2000 * 1000);//2000ms
        NSLog(@"async 1");
    }];
    return promise;
    
}

- (FBLPromise<NSString *> *)async2:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    FBLPromise<NSString *> *promise = [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        usleep(2200 * 1000);//2200ms
        NSLog(@"async 2");
    }];
    return promise;
    
}

- (FBLPromise<NSString *> *)do1:(NSURL *)anURL {
    if (anURL.absoluteString.length == 0) {
        return [FBLPromise resolvedWith:nil];
    }
    FBLPromise<NSString *> *promise = [FBLPromise do:^id _Nullable{
        usleep(2000 * 1000);//2000ms
        NSLog(@"do 1");
        return @"do 1";
    }];
    return promise;
    
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
    return string;
  }];
}

- (FBLPromise<NSNumber *> *)work2:(NSString *)string {
  return [FBLPromise do:^id {
    return @(string.integerValue);
  }];
}

- (NSNumber *)work3:(NSNumber *)number {
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

- (FBLPromise<NSData*> *)Wrap {
    return [FBLPromise wrapObjectOrErrorCompletion:^(FBLPromiseObjectOrErrorCompletion handler) {
        
    }];
}

- (void)advancedTopics {
    FBLPromise.defaultDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

@end
