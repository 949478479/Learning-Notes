//
//  NSObject+LXExtension.m
//
//  Created by 从今以后 on 15/9/14.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import ObjectiveC.runtime;
#import "NSObject+LXExtension.h"
#import "NSObject+DLIntrospection.h"

@implementation NSObject (LXExtension)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 打印变量

+ (void)lx_printIvars
{
    /*
    Class class = [self class];
    uint outCount = 0;
    Ivar *ivars = class_copyIvarList(class, &outCount);
    for (uint i = 0; i < outCount; ++i) {
        Ivar ivar = ivars[i];
        if (i == 0) {
            printf("%s 实例变量如下: \n\n", class_getName(class));
        }
        printf("%s : %s \n\n", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    free(ivars);*/
    NSLog(@"%@", [self dl_instanceVariables]);
}

- (void)lx_printIvars
{
    [[self class] lx_printIvars];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 打印属性

+ (void)lx_printProperties
{
    /*
    Class class = [self class];
    uint outCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (uint i = 0; i < outCount; ++i) {
        objc_property_t property = properties[i];
        if (i == 0) {
            printf("%s 属性如下: \n\n", class_getName(class));
        }
        printf("%s : %s \n\n", property_getName(property),  property_getAttributes(property));
    }
    free(properties);*/
    NSLog(@"%@", [self dl_properties]);
}

- (void)lx_printProperties
{
    [[self class] lx_printProperties];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 打印方法

+ (void)lx_printMethods
{
    NSLog(@"%@", [self dl_classMethods]);
}

- (void)lx_printMethods
{
    NSLog(@"%@", [[self class] dl_instanceMethods]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 获取属性数组

+ (NSArray<NSString *> *)lx_properties
{
    NSMutableArray *propertyArray = [NSMutableArray new];
    {
        uint outCount = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (uint i = 0; i < outCount; ++i) {
            [propertyArray addObject:(NSString *)[NSString stringWithUTF8String:property_getName(properties[i])]];
        }
        free(properties);
    }
    return propertyArray;
}

- (NSArray<NSString *> *)lx_properties
{
    return [[self class] lx_properties];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 获取实例变量数组

+ (NSArray<NSString *> *)lx_variables
{
    NSMutableArray *ivarArray = [NSMutableArray new];
    {
        uint outCount = 0;
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        for (uint i = 0; i < outCount; ++i) {
            [ivarArray addObject:(NSString *)[NSString stringWithUTF8String:ivar_getName(ivars[i])]];
        }
        free(ivars);
    }
    return ivarArray;
}

- (NSArray<NSString *> *)lx_variables
{
    return [[self class] lx_variables];
}

@end