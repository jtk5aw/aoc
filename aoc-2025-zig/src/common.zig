const std = @import("std");

pub const PartError = error{
    InvalidArguments,
    InvalidPartNumber,
};

/// Parse command-line arguments to determine which part to run
/// Returns the part number (1 or 2)
/// Errors if no arguments provided or invalid arguments
pub fn parsePart() !u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    // Skip program name
    _ = args.skip();

    // Expect -p flag
    const flag = args.next() orelse {
        std.debug.print("Error: Missing arguments. Usage: program -p <1|2>\n", .{});
        return PartError.InvalidArguments;
    };

    if (!std.mem.eql(u8, flag, "-p")) {
        std.debug.print("Error: Invalid flag '{s}'. Usage: program -p <1|2>\n", .{flag});
        return PartError.InvalidArguments;
    }

    const part_str = args.next() orelse {
        std.debug.print("Error: Missing part number. Usage: program -p <1|2>\n", .{});
        return PartError.InvalidArguments;
    };

    const part = std.fmt.parseInt(u8, part_str, 10) catch {
        std.debug.print("Error: Invalid part number '{s}'. Must be 1 or 2.\n", .{part_str});
        return PartError.InvalidPartNumber;
    };

    if (part != 1 and part != 2) {
        std.debug.print("Error: Part must be 1 or 2, got {d}\n", .{part});
        return PartError.InvalidPartNumber;
    }

    return part;
}
