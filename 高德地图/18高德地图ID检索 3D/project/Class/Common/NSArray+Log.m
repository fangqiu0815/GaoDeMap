

#import "NSArray+Log.h"

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale
{

    NSMutableString *stringM = [NSMutableString string];
    [stringM appendString:@"[\n"];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != self.count - 1) {
            [stringM appendFormat:@"\t%@,\n",obj];
        }else {
            [stringM appendFormat:@"\t%@",obj];
        }
    }];
    [stringM appendString:@"]\n"];
    return stringM;
}

@end

@implementation NSDictionary (Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *stringM = [NSMutableString string];
    [stringM appendString:@"{\n"];
    int index = 0;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (index == self.count - 1) {
            [stringM appendFormat:@"\t\"%@\" : \"%@\"",key,obj];
        }else {
            [stringM appendFormat:@"\t\"%@\" : \"%@\",\n",key,obj];
        }
    }];
    [stringM appendString:@"}\n"];
    return stringM;
}

@end
