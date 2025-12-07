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
        const overrotation = switch (isLeft) {
            true => number > current,
            false => number > (max - current),
        };

        // We default this to 1 because it isn't guaranteed to get added
        var newPasses: i32 = 0;
        if (!overrotation) {
            current = if (isLeft) current - number else current + number;
        } else {
            const difference = if (isLeft) number - current else number - (max - current);
            newPasses = @divTrunc(difference, max) + 1;
            numPasses += newPasses;
            const modulo = @rem(difference, max);
            current = if (isLeft) 100 - modulo else modulo;
        }

        if (current == 0 or current == 100) {
            counter += 1;
            current = 0;
        }

        std.debug.print("This row is: {s} and current becomes {d} ", .{ row, current });
        if (overrotation) {
            std.debug.print("Overrotated! Total passes: {d}", .{newPasses});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\nEnds at zero: {d}\nPasses zero: {d}\n", .{ counter, numPasses });
}
