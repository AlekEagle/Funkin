package haxe.net.impl;
import haxe.io.Bytes;

class BytesRW {
    public var available(default, null):Int = 0;
    private var currentOffset:Int = 0;
    private var currentData: Bytes = null;
    private var chunks:Array<Bytes> = [];

    public function new() {

    }

    public function writeByte(v:Int) {
        var b = Bytes.alloc(1);
        b.set(0, v);
        writeBytes(b);
    }

    public function writeShort(v:Int) {
        var b = Bytes.alloc(2);
        b.set(0, (v >> 8) & 0xFF);
        b.set(1, (v >> 0) & 0xFF);
        writeBytes(b);
    }

    public function writeInt(v:Int) {
        var b = Bytes.alloc(4);
        b.set(0, (v >> 24) & 0xFF);
        b.set(1, (v >> 16) & 0xFF);
        b.set(2, (v >> 8) & 0xFF);
        b.set(3, (v >> 0) & 0xFF);
        writeBytes(b);
    }

    public function writeBytes(data:Bytes) {
        chunks.push(data);
        available += data.length;
    }

    public function readAllAvailableBytes():Bytes {
        return readBytes(available);
    }

    public function readBytes(count:Int):Bytes {
        var count2 = Std.int(Math.min(count, available));
        var out = Bytes.alloc(count2);
        for (n in 0 ... count2) out.set(n, readByte());
        return out;
    }

    public function readUnsignedShort():UInt {
        var h = readByte();
        var l = readByte();
        return (h << 8) | (l << 0);
    }

    public function readUnsignedInt():UInt {
        var v3 = readByte();
        var v2 = readByte();
        var v1 = readByte();
        var v0 = readByte();
        return (v3 << 24) | (v2 << 16) | (v1 << 8) | (v0 << 0);
    }

    public function readByte():Int {
        if (available <= 0) throw 'Not bytes available';
        while (currentData == null || currentOffset >= currentData.length) {
            currentOffset = 0;
            currentData = chunks.shift();
        }
        available--;
        return currentData.get(currentOffset++);
    }
}