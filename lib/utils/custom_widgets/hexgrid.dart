import "dart:math";

///Implemented from:
/// https://www.redblobgames.com/grids/hexagons/implementation.html
class Hex {
  static List directions = [
    Hex( 1, 0), Hex( 1,-1), Hex(0, -1),
    Hex(-1, 0), Hex(-1, 1), Hex(0,  1)
  ];

  final int _q;
  final int _r;

  get q => _q;
  get r => _r;
  get s => -_q - _r;

  int distance(Hex other) {
    int a = (q - other.q).abs();
    int b = (r - other.r).abs();
    int c = (a - b).abs();
    return max(a, max(b, c));
  }

  Hex neighbor(int direction) {
    assert(0 <= direction && direction < 6);
    return this + directions[direction];
  }

  Point toPixel(Layout layout) {
    Orientation M = layout.orientation;
    double x = (M.f0 * q + M.f1 * r) * layout.size.x;
    double y = (M.f2 * q + M.f3 * r) * layout.size.y;

    return Point(x + layout.origin.x, y + layout.origin.y);
  }

  Point cornerOffset(Layout layout, int corner) {
    Point size = layout.size;
    double angle = 2.0 * pi * (corner + layout.orientation.startAngle) / 6;
    return Point(
        layout.origin.x + size.x * cos(angle),
        layout.origin.y + size.y * sin(angle));
  }

  List<Point> corners(Layout layout) {
    List<Point> corners = new List();

    Point center = toPixel(layout);
    for (int i = 0; i < 6; i++) {
      Point offset = cornerOffset(layout, i);
      corners.add(Point(center.x + offset.x, center.y + offset.y));
    }

    return corners;
  }

  @override
  toString() => "($q, $r)";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Hex &&
              runtimeType == other.runtimeType &&
              _q == other._q &&
              _r == other._r;

  @override
  int get hashCode =>
      _q.hashCode ^
      _r.hashCode;

  Hex operator +(Hex other) {
    return Hex(q + other.q, r + other.r);
  }

  Hex operator -(Hex other) {
    return Hex(q - other.q, r - other.r);
  }

  Hex operator *(int k) => Hex(q * k, r * k);

  Hex(this._q, this._r);

  factory Hex.fromPoint(Layout layout, Point p) {
    Point size = layout.size;
    double q, r;

    double x, z, y;
    int rx, ry, rz;
    double xDiff, yDiff, zDiff;

    if (layout.flat) {
      q = (p.x * 2/3 / size.x);
      r = (-p.x / 3 + sqrt(3)/3 * p.y) / size.y;
    } else {
      q = (p.x * sqrt(3) / 3 - p.y / 3) / size.x;
      r = p.y * 2 / 3 / size.y;
    }

    //Convert to cube coordinates
    x = q;
    z = r;
    y = -x - z;
    rx = (x).round();
    ry = (y).round();
    rz = (z).round();

    xDiff = (rx - x).abs();
    yDiff = (ry - y).abs();
    zDiff = (rz - z).abs();

    if (xDiff > yDiff && xDiff > zDiff) {
      rx = -ry - rz;
    } else if (yDiff > zDiff) {
      ry = -rx - rz;
    } else {
      rz = -rx - ry;
    }

    //Convert to axial
    return Hex(rx, rz);
  }
}

class Orientation {
  final double f0, f1, f2, f3;
  final double b0, b1, b2, b3;
  final double startAngle;
  Orientation(this.f0, this.f1, this.f2, this.f3,
      this.b0, this.b1, this.b2, this.b3, this.startAngle);
}

class Layout {
  final Orientation orientation;
  final Point size;
  final Point origin;
  final bool flat;

  factory Layout(Point size, Point origin) =>
      new Layout.orientFlat(size, origin);

  Layout.orientPointy(this.size, this.origin) :
        flat = false,
        orientation = new Orientation(
            sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
            sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5);

  Layout.orientFlat(this.size, this.origin) :
        flat = true,
        orientation = new Orientation(
            3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0),
            2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0, 0.0);
}
