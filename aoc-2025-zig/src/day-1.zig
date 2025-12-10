const std = @import("std");

// 6812 is too high

pub fn main() !void {
    var row_it = std.mem.tokenizeSequence(u8, @embedFile("inputs/day-1.txt"), "\n");
    var current: i32 = 50;
    var counter: i32 = 0;
    var numPasses: i32 = 0;
    const max = 100; // 0 - 99 = 100
    std.debug.print("Starts at: {d}\n", .{current});
    while (row_it.next()) |row| {
        const number: i32 = try std.fmt.parseInt(i32, row[1..], 10);
        const isLeft = row[0] == 'L';
        var numOverrotations = @divTrunc(number, max);
        const numberRemaining = @mod(number, max);
        const distanceToZero = if (isLeft) current else max - current;

        if (numberRemaining > distanceToZero) {
            numOverrotations += if (current != 0) 1 else 0;
            current = if (isLeft) max - (numberRemaining - distanceToZero) else numberRemaining - distanceToZero;
        } else {
            current = if (isLeft) current - numberRemaining else current + numberRemaining;
        }

        numPasses += numOverrotations;

        if (current == 0 or current == 100) {
            counter += 1;
            current = 0;
        }

        std.debug.print("This row is: {s} and current becomes {d} ", .{ row, current });
        if (numOverrotations > 0) {
            std.debug.print("Overrotated! Total passes: {d}", .{numOverrotations});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\nEnds at zero: {d}\nPasses zero: {d}\n", .{ counter, numPasses });
}
