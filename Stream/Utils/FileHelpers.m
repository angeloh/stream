#import "FileHelpers.h"

NSString *documentDirectory()
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return documentDirectory;
}

NSString *pathInDocumentDirectory(NSString *fileName)
{
    return [documentDirectory() stringByAppendingPathComponent:fileName];
}