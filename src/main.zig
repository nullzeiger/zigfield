const std = @import("std");

// minefield with a size 10x10
const ROWSCOLS = 10;
// Number of mines
const MINES = 5;
// Buffer size
const BUFFER = 2;
// Map symbol
const MAPSPRITE = '*';

// Arrive data structure
const Arrive = struct {
    symbol: u8,
    y: u32,
    x: u32,
};

// Hero data structure
const Hero = struct {
    symbol: u8,
    y: u32,
    x: u32,
};

// Mine data structure
const Mine = struct {
    symbol: u8,
    y: u32,
    x: u32,
};

// Create new map
fn createMap(arrive: Arrive) [ROWSCOLS][ROWSCOLS]u8 {
    var map: [ROWSCOLS][ROWSCOLS]u8 = undefined;

    for (0..ROWSCOLS) |row| {
        for (0..ROWSCOLS) |col| {
            map[row][col] = MAPSPRITE;
        }
    }

    map[arrive.y][arrive.x] = arrive.symbol;

    return map;
}

// Clear console and print map
fn printMap(map: *[ROWSCOLS][ROWSCOLS]u8, hero: Hero) void {
    std.debug.print("\x1B[2J\x1B[H", .{});

    std.debug.print("Command to move(hjkl) and exit(q)\n", .{});

    map[hero.y][hero.x] = hero.symbol;

    for (0..ROWSCOLS) |row| {
        for (0..ROWSCOLS) |col| {
            std.debug.print("{c}", .{map[row][col]});
        }
        std.debug.print("\n", .{});
    }

    map[hero.y][hero.x] = MAPSPRITE;
}

// Create random arrive
fn createArrive(arrive: *Arrive) !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const rand = prng.random();
    arrive.y = rand.intRangeAtMost(u8, 0, 9);
    arrive.x = rand.intRangeAtMost(u8, 0, 9);
    arrive.symbol = 'P';
}

// Create 5 random mine
fn createMines(mines: *[MINES]Mine) !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const rand = prng.random();

    for (0..MINES) |i| {
        mines[i].y = rand.intRangeAtMost(u8, 0, 9);
        mines[i].x = rand.intRangeAtMost(u8, 0, 9);
        mines[i].symbol = 'X';
    }
}

pub fn main() !void {
    // Create hero
    var hero = Hero{
        .y = 0,
        .x = 0,
        .symbol = '@',
    };

    // Create arrive
    var arrive: Arrive = undefined;
    try createArrive(&arrive);

    // Create mines
    var mines: [MINES]Mine = undefined;
    try createMines(&mines);

    // Create map
    var map = createMap(arrive);
    printMap(&map, hero);

    // Logic game
    var loop = true;

    while (loop) {
        // Input
        const reader = std.io.getStdIn().reader();
        var input: [BUFFER]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&input);
        try reader.streamUntilDelimiter(fbs.writer(), '\n', BUFFER);

        if (input[0] != 'q' or input[0] != 'l' or input[0] != 'k' or input[0] != 'j' or input[0] != 'h') {
            printMap(&map, hero);
        }

        if (input[0] == 'q') {
            loop = false;
            break;
        }

        if (input[0] == 'l') {
            hero.x += 1;
            if (hero.x > 9)
                hero.x = 9;
            printMap(&map, hero);
        }

        if (input[0] == 'h') {
            hero.x -= 1;
            if (hero.x < 0)
                hero.x = 0;
            printMap(&map, hero);
        }

        if (input[0] == 'k') {
            hero.y += 1;
            if (hero.y > 9)
                hero.y = 9;
            printMap(&map, hero);
        }

        if (input[0] == 'j') {
            hero.y += 1;
            if (hero.y < 0)
                hero.y = 0;
            printMap(&map, hero);
        }

        if (hero.x == arrive.x and hero.y == arrive.y) {
            std.debug.print("Win!!\n", .{});
            loop = false;
            break;
        }

        for (0..MINES) |i| {
            if (hero.x == mines[i].x and hero.y == mines[i].y) {
                hero.symbol = mines[i].symbol;
                printMap(&map, hero);
                std.debug.print("Game Over!!\n", .{});
                loop = false;
                break;
            }
        }
    }
}
