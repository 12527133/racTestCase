//
//  ViewController.m
//  ractest
//
//  Created by bao on 2018/6/23.
//  Copyright © 2018年 bao. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveObjC.h"
#import "RACReturnSignal.h"
#import "compentFactory.h"
@interface ViewController ()
@property id<RACSubscriber> sub;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    float x = 15;
    float y = 50;
    float w = 150;
    float h = 50;
    float s = 40;
    [[compentFactory button:@"testRACDisposable" frame:CGRectMake(x, y, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [[compentFactory button:@"testFilter" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [[compentFactory button:@"testMap" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
   [[compentFactory button:@"testBind" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
 
   [[compentFactory button:@"testFlattenMap" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [[compentFactory button:@"takeUntil" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];

    
    [[compentFactory button:@"switchToLatest" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [[compentFactory button:@"skip" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [[compentFactory button:@"distinctUntilChanged" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [[compentFactory button:@"testReplaySubject" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [[compentFactory button:@"testFlattenMapSameSubscriber" frame:CGRectMake(x, y += s, w, h) parent:self.view] addTarget:self action:@selector(clickHandler:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickHandler:(UIButton *)send {
    NSString *title = send.titleLabel.text;
    [self performSelector:NSSelectorFromString(title)];
}

- (void)testRACDisposable {
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"创建信号量");
        
        //3、发布信息
        [subscriber sendNext:@"I'm send next data"];
        
        NSLog(@"那我啥时候运行");
        self.sub = subscriber;
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"disposable");
        }];
    }];
    RACDisposable* dis = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    [dis dispose];
}
 
- (void)testFilter {
    RACSignal *signal = [@[ @1, @2, @3 ] rac_sequence].signal ;
    signal = [signal filter:^BOOL(NSNumber *value) {
        return value.integerValue % 2;
    }];
    [signal subscribeNext:^(NSNumber *value) {
        NSLog(@"%@", value);
    }];
}

- (void)testMap {
    RACSignal *signal = [@[ @1, @2, @3 ] rac_sequence].signal;
     signal = [signal map:^id(NSNumber *value) {
         return @(value.integerValue * 2);
     }];
     [signal subscribeNext:^(NSNumber *value) {
         NSLog(@"%@", value);
     }];
}

- (void)testBind {
    RACSubject *originSignal = [RACSubject subject];
    RACSignal *bindSignal = [originSignal bind: ^{
        return
        ^RACSignal *(id value, BOOL *stop){
            NSLog(@"%@ 为originSignal的值",value);
            // 得到value后，可以干任何你想干的
            value = @"把value变成想要的，会由bindSignal的subscriber转发出来";
            return [RACReturnSignal return:value];
        };
        
    }];
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    // 原型号发送数据
    [originSignal sendNext:@"originSignal的value"];
}

/****** test flattenMap *******/
- (RACSignal *)testFlattenMap {
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"x"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal* (^block2)(id value) = ^RACSignal *(id value) {
        NSLog(@"%@", @"falttenMap");
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriberd) {
            [subscriberd sendNext:@"didlogin"];
            [subscriberd sendCompleted];
            return nil;
        }];
    };
    RACSignal *signal2 = [signal1 flattenMap:block2];
    
    [signal2 subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    return signal2;
}
/****** test flattenMap *******/



- (void)takeUntil {
    RACSubject *sub = [RACSubject subject];
    [sub subscribeNext:^(id  _Nullable x) {
        NSLog(@"sub:%@", x);
    }];
    
    RACSubject *untilsub = [RACSubject subject];
    [untilsub subscribeNext:^(id  _Nullable x) {
        NSLog(@"untilsub:%@", x);
    }];
    
    // takeUntil其实就是sub信号 在untilsub信号发送complete事件前有效。因为一但untilsub发送complete后，就会销毁[sub takeUntil:untilsub]及untilsub，但是sub并未被销毁哦；
    [[sub takeUntil:untilsub] subscribeNext:^(id  _Nullable x) {
        NSLog(@"takeUntilSignal:%@", x);
    }];
    
    [sub sendNext:@"3"];
    
    [untilsub sendNext:@"u6"];
    [untilsub sendCompleted];
    [untilsub sendNext:@"u6"];
    
    [sub sendNext:@"1"];
    
}


- (void)switchToLatest {
    RACSubject *signalofsignal = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    RACSubject *signal3 = [RACSubject subject];


//    [signalofsignal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@", x);
//    }];
    
    [signalofsignal.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    [signalofsignal sendNext:signal];
    [signalofsignal sendNext:signal3];

    [signal sendNext:@"sig"];
    [signal3 sendNext:@"sig3"];
    [signal sendNext:@"sig2"];
    [signal3 sendNext:@"sig4"];
}

- (void)distinctUntilChanged {
    RACSubject *sub = [RACSubject subject];
    [[sub distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];

    [sub sendNext:@"1"];
    [sub sendNext:@"1"];
    [sub sendNext:@"2"];
    [sub sendNext:@"2"];
    [sub sendNext:@"3"];
    [sub sendNext:@"4"];

}

- (void)skip {
    RACSubject *sub = [RACSubject subject];
    [[sub skip:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    [sub sendNext:@"1"];
    [sub sendNext:@"1"];
    [sub sendNext:@"1"];
    [sub sendNext:@"2"];
    [sub sendNext:@"3"];
    [sub sendNext:@"4"];
    [sub sendNext:@"5"];
}

// test replaySubject
- (void)testReplaySubject {
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    // 3.订阅信号，前面已发送过的信号（@1，@2）都会重放。
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    // 4.订阅信号, 前面已发送过的信号（@1，@2）都会重放。第二次subscribeNext时，不会影响上一次subscribeNext
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者接收到的数据%@",x);
    }];
    
    //5.这里再次发送时以上3和4处订阅都会执行，并且只收到@3。
    [replaySubject sendNext:@3];
    
    // 6.订阅信号, 前面已发送过的信号（@1，@2，@3）都会重放。第三次subscribeNext时，不会影响以前的subscribeNext。
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第三个订阅者接收到的数据%@",x);
    }];
}


/****** test the bug by flattenMap and same subscriber *******/
- (void)testFlattenMapSameSubscriber {
    void (^block0)(id x)  = ^(id x) {
        NSLog(@"%@", x);
    };
    
    [[self loginWithUsername] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}

- (RACSignal *)loginWithUsername {
    static int i = 0;
    static int t = 0;
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (i==0) {
            i++;
            [self retryLoginWithGeetest:subscriber];
            
        } else {
            [subscriber sendNext:@"x"];
            [subscriber sendCompleted];
        }
        return nil;
    }];
    
    RACSignal* (^block2)(id value) = ^RACSignal *(id value) {
        NSLog(@"%d", t++);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriberd) {
            [subscriberd sendNext:@"didlogin"];
            [subscriberd sendCompleted];
            return nil;
        }];
    };
    RACSignal *signal2 = [signal1 flattenMap:block2];
    
    return signal2;
}

- (void)retryLoginWithGeetest:(id<RACSubscriber>)subscriber{
    [[self loginWithUsername] subscribe:subscriber];
}
/****** test the bug by flattenMap and same subscriber *******/

@end
