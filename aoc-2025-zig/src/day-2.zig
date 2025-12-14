const std = @import("std");
const common = @import("common.zig");

// NOTE TO SELF: This was my original plan, I didn't do it. Might still have to. 🤞 I don't
// MY PLAN IS TO GENERATE ALL THE INVALID ID PAIRS UP TO THE LENGTH OF THE LARGEST NUMBER FOUND IN THE SET
// OF RANGES. THEN, JUST CHECK ALL THE ONES THAT FALL IN ONE OF THE RANGES AND GO FROM THERE.
// INVALID NUMBERS ARE JUST THE SAME SEQUENCE REPEATED TWICE SO THEY HAVE TO BE AN EVEN LENGTH AND I DON'T THINK THEY'RE CNA
// BE THAT MANY
//

// Define the set of characters to treat as whitespace
const whitespace_chars = [_]u8{
    ' ',
    '\t',
    '\n',
    '\r',
    '\x0B', // vertical tab
};

pub fn main() !void {
    const part = try common.parsePart();

    switch (part) {
        1 => try part1(),
        2 => try part2(),
        else => unreachable,
    }
}

pub fn part1() !void {}

pub fn part2() !void {
    try skeleton(any_repeating);
}

pub fn skeleton(repeating_func: fn ([]const u8) bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pair_it = std.mem.tokenizeSequence(u8, @embedFile("inputs/day-2.txt"), ",");

    var all_invalids = try std.ArrayList(i64).initCapacity(allocator, 100);
    defer all_invalids.deinit(allocator);
    while (pair_it.next()) |pair| {
        std.debug.print("This row is {s}\n", .{pair});

        var row_it = std.mem.splitSequence(u8, pair, "-");
        const first = std.mem.trim(u8, row_it.next().?, &whitespace_chars);
        const second = std.mem.trim(u8, row_it.next().?, &whitespace_chars);
        std.debug.assert(row_it.next() == null);

        const start = try std.fmt.parseInt(i64, first, 10);
        const end = try std.fmt.parseInt(i64, second, 10);

        var invalids = try find_invalid(allocator, repeating_func, start, end);
        defer invalids.deinit(allocator);
        for (invalids.items) |invalid| {
            try all_invalids.append(allocator, invalid);
            //std.debug.print("Appending: {d}\n", .{invalid});
        }
    }

    std.debug.print("Final values:\n", .{});
    var final_sum: i64 = 0;
    for (all_invalids.items) |invalid| {
        //std.debug.print("{d}\n", .{invalid});
        final_sum += invalid;
    }
    std.debug.print("And the final sum is ..... {d}\n", .{final_sum});
}

fn find_invalid(allocator: std.mem.Allocator, repeating_func: fn ([]const u8) bool, start: i64, end: i64) !std.ArrayList(i64) {
    var list = try std.ArrayList(i64).initCapacity(allocator, 10);
    errdefer list.deinit(allocator);

    var i = start;
    while (i <= end) : (i += 1) {
        const curr_string = try std.fmt.allocPrint(allocator, "{}", .{i});
        defer allocator.free(curr_string);

        if (repeating_func(curr_string)) {
            std.debug.print(".", .{});
            try list.append(allocator, i);
        }
    }
    std.debug.print("\n", .{});
    return list;
}

fn is_repeating(curr_string: []const u8) bool {
    return is_repeating_for(curr_string, 2);
}

fn any_repeating(curr_string: []const u8) bool {
    var times_repeated = curr_string.len;
    while (times_repeated > 1) : (times_repeated -= 1) {
        if (is_repeating_for(curr_string, times_repeated)) {
            //std.debug.print("Found for {s} with {d}\n", .{ curr_string, times_repeated });
            return true;
        }
    }
    return false;
}

fn is_repeating_for(curr_string: []const u8, times_repeated: usize) bool {
    if (curr_string.len % times_repeated != 0) {
        return false;
    }

    const skip = curr_string.len / times_repeated;
    var curr_string_idx: usize = 0;
    while (curr_string_idx < skip) : (curr_string_idx += 1) {
        const to_check = curr_string[curr_string_idx];
        for (0..times_repeated) |idx| {
            //std.debug.print("Debug line - curr_string: {s}, times_repeated {d}, curr_string_idx: {d}, skip: {d}, idx: {d}\n", .{ curr_string, times_repeated, curr_string_idx, skip, idx });
            if (to_check != curr_string[curr_string_idx + (skip * idx)]) {
                return false;
            }
        }
    }
    return true;
}
