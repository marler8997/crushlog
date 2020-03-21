const std = @import("std");
const assert = std.debug.assert;

pub const OrderedByteCycle = struct {
    const Node = struct {
        prev: u8,
        next: u8,
    };
    nodes: [256]Node,
    pub fn initAscending() OrderedByteCycle {
        var self : OrderedByteCycle = undefined;
        var i : u8 = 0;
        while (true) {
            _ = @subWithOverflow(u8, i, 1, &self.nodes[i].prev);
            _ = @addWithOverflow(u8, i, 1, &self.nodes[i].next);
            i = self.nodes[i].next;
            if (i == 0) break;
        }
        return self;
    }

    pub fn swap(self: *OrderedByteCycle, a: u8, b: u8) void {
        if (a == b) return;

        const aNode = &self.nodes[a];
        const bNode = &self.nodes[b];
        if (aNode.next == b) {
            self.flipAdjacent(a, b);
        } else if (bNode.next == a) {
            self.flipAdjacent(b, a);
        } else {
            self.nodes[aNode.prev].next = b;
            self.nodes[aNode.next].prev = b;

            self.nodes[bNode.prev].next = a;
            self.nodes[bNode.next].prev = a;

            const tempANodeCopy = aNode.*;
            self.nodes[a] = bNode.*;
            self.nodes[b] = tempANodeCopy;
        }
    }

    fn flipAdjacent(self: *OrderedByteCycle, first: u8, second: u8) void {
        assert(self.nodes[first].next == second);

        const firstNode = &self.nodes[first];
        const secondNode = &self.nodes[second];

        secondNode.prev = firstNode.prev;
        self.nodes[firstNode.prev].next = second;

        firstNode.next = secondNode.next;
        self.nodes[secondNode.next].prev = first;

        firstNode.prev = second;
        secondNode.next = first;
    }

    pub fn assertValid(self: *const OrderedByteCycle) void {
        var count : u8 = 0;
        var i : u8 = 0;
        while (true) {
            const next = self.nodes[i].next;
            //std.debug.warn("{} ", .{i});
            assert(i == self.nodes[self.nodes[i].next].prev);
            _ = @addWithOverflow(u8, count, 1, &count);
            if (count == 0) {
                //std.debug.warn("\n", .{});
                assert(0 == next);
                return;
            }
            assert(next != 0);
            i = next;
        }
    }

    fn assertOrder(self: *const OrderedByteCycle, vals: []const u8) void {
        var i : u8 = 0;
        while (i < vals.len - 1) : (i += 1) {
            assert(self.nodes[vals[i]].next == vals[i+1]);
        }
    }
};

pub const OrderedByteList = struct {
    cycle: OrderedByteCycle,
    head: u8,
    pub fn initAscending() OrderedByteList {
        return OrderedByteList {
            .cycle = OrderedByteCycle.initAscending(),
            .head = 0,
        };
    }

    pub fn swap(self: *OrderedByteList, a: u8, b: u8) void {
        if (a == b) return;
        self.cycle.swap(a, b);
        if (self.head == a) { self.head = b; }
        else if (self.head == b) { self.head = a; }
    }

    pub fn moveToBack(self: *OrderedByteList, val: u8) void {
        //self.swap(val, self.cycle.nodes[self.head].prev);
        self.swap(val, self.head);
        self.head = self.cycle.nodes[self.head].next;
    }
};


test "OrderedBytes" {
    {
        var b = OrderedByteList.initAscending();
        b.cycle.assertValid();
        assert(b.head == 0);
        b.cycle.assertOrder(&[_]u8 { 255, 0, 1, 2});

        b.swap(0, 1);
        b.cycle.assertValid();
        assert(b.head == 1);
        b.cycle.assertOrder(&[_]u8 { 255, 1, 0, 2});

        b.swap(255, 1);
        b.cycle.assertValid();
        assert(b.head == 255);
        b.cycle.assertOrder(&[_]u8 { 254, 1, 255, 0, 2});

        b.swap(1, 0);
        b.cycle.assertValid();
        assert(b.head == 255);
        b.cycle.assertOrder(&[_]u8 { 254, 0, 255, 1, 2});

        b.moveToBack(255);
        b.cycle.assertValid();
        assert(b.head == 1);
        b.cycle.assertOrder(&[_]u8 { 254, 0, 255, 1, 2});

        b.swap(2, 254);
        b.cycle.assertValid();
        assert(b.head == 1);
        b.cycle.assertOrder(&[_]u8 { 253, 2, 0, 255, 1, 254, 3});
    }
}
