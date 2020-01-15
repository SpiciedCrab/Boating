import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:ocean_clock/configs.dart';

class Point {
  double aX, aY ,aR ,dX ,dY, dA ,x, y, r, aA;
  double oAX, oAY, oDX, oDY;
  Color color;
  bool isEnable;
  bool isRemained = false;
  double Function(double) func;

  resetPosition() {
    aX = oAX;
    aY = oAY;
    dX = oDX;
    dY = oDY;
    dA = 0.1;
    r = math.Random().nextInt(10).toDouble();
  }

  Point({this.aX=0, this.aY=0, this.aR, this.dX=0, this.dY=0, this.dA = 0.001 ,this.x=0, this.y=0, this.color, this.r=5 ,this.aA = originAAlpha,
    this.oAX, this.oAY,this.oDX,this.oDY,
    this.isEnable = true,
    this.func = defaultFunc});

  static List<Point> randomPoints(double maxX) {
    int count = math.Random().nextInt(20) + 20;
    List<Point> points = [];
    for(var i = 0; i < count; i ++) {
      double yPosition = math.Random().nextInt(100).toDouble();
      double xPosition = math.Random().nextInt(100).toDouble();
      double size = math.Random().nextInt(10).toDouble();
      points.add(Point(aX: xPosition / 100,
          aY: 0.1,
          oAY: 0.1,
          oAX: xPosition / 100,
          x: math.Random().nextInt(maxX.toInt()).toDouble(),
          y: yPosition,
          dX: xPosition/ 100,
          oDX: xPosition/ 100,
          dY: 0.1,
          oDY: 0.1,
          dA: originAAlpha,
          r: size, aA: originAAlpha, aR: 0.99, color: Color(0xFFc3cddc).withOpacity(originAAlpha)));
    }
    return points;
  }

  markAsRemained() {
    if(!isRemained) {
      isRemained = true;
      remained.add(this);
    }
  }

  static List<Point> remained = [];
}

final int maxCount = 200;
const double originAAlpha = 0.000001;

double defaultFunc(double x) {
  double randomMult = math.Random().nextInt(110).toDouble()/ 100;
  double randomM = math.Random().nextInt(100).toDouble() / 100;
  return math.atan(x * 10) * 100;
}

double tailPoint(double x) {
  double randomM = math.Random().nextInt(100).toDouble() / 100 + 0.01;
  return math.sin(x * randomM / 100) * handLength + randomM * 50;
}



class FloatingPointView extends CustomPainter {
  List<Point> _points;
  Paint pointPainter;
  Size _containerSize;
  double radius;
  double paddingTop;
  double paddingHorizon;

  double waterRadians = math.pi / 2;

  FloatingPointView(this._points,this._containerSize, {this.radius = 0 , this.paddingTop = 0, this.paddingHorizon = 0}) {
    pointPainter = new Paint();
  }

  @override
  void paint(Canvas canvas, Size size) {

    if(paddingTop != 0) {
      waterRadians = math.acos(paddingTop / handLength);
    }

    Point.remained.forEach((c){
      if(c.isEnable) {
        _actionRemained(c);
        canvas.drawCircle(
            Offset(c.x, c.y), c.r, pointPainter..color = c.color);
      }
    });
    
    if(radius != null && radius >= 0 && radius < waterRadians) {
      _points = Point.randomPoints(_containerSize.width);
//      _points.forEach((c){
//        if(!c.isRemained) {
//          c.isEnable = true;
//          c.resetPosition();
//        }
//      });
    }

    _points.forEach((c){
      var newPoint = _updatePoint(c, _containerSize);
      if(newPoint.isEnable) {
        Rect rect = Offset(newPoint.x - 5, newPoint.y - 5) & Size(
            10,
            10
        );

        pointPainter.shader = RadialGradient(
          radius: 0.9,
          colors: [Colors.white.withOpacity(newPoint.color.opacity), newPoint.color],
        ).createShader(rect);

        canvas.drawCircle(
            Offset(newPoint.x, newPoint.y), newPoint.r, pointPainter);
      } else {
//        newPoint.resetPosition();
//        newPoint.isEnable = true;
      }
    });

  }


  Point _fixPointByRadius(Point point) {
    if(radius >= (waterRadians) && radius < math.pi) {
      var originY = handLength * math.sin(radius - math.pi / 2);
      point.y = (originY - paddingTop) * math.Random().nextInt(100).toDouble()/ 100;
      var tanX = (point.y + paddingTop) / math.tan((radius - math.pi / 2)) ;
      double maxX = math.max(0, _containerSize.width / 2 - tanX + paddingHorizon) ;
      if(point.x > maxX) {
//        point.isEnable = false;
        point.x = maxX;
        point.resetPosition();
      }
    } else if(radius >= math.pi && radius <  (2 * math.pi - waterRadians)) {
      var originY = handLength * math.cos(radius - math.pi);
      point.y = (originY - paddingTop) * math.Random().nextInt(120).toDouble()/ 100;
      double maxX = math.tan(radius - math.pi) * (point.y + paddingTop)  + _containerSize.width / 2 + paddingHorizon;
      if(point.x > maxX) {
//        point.isEnable = false;
        point.x = maxX;
        point.resetPosition();
      }
    } else if(radius >=  (2 * math.pi - waterRadians) && radius <  2 * math.pi) {
      if(point.x >= (_containerSize.width / 2 + paddingHorizon - 100)) {
        if(point.y >= 0) {
          point.y = 0;
          point.x = (handLength + _containerSize.width / 2 + paddingHorizon) - 50;
        }
        point.aA = originAAlpha;
        point.markAsRemained();
        _actionRemained(point);
      } else {
        point.isEnable = false;
      }
    } else {
      point.isEnable = false;
    }

    return point;
  }

  _actionRemained(Point point) {
    point.y -= (tailPoint(point.dX) + paddingTop);
    point.dX += point.aX;
    point.x += point.dX * 5;
  }

  Point _updatePoint(Point _point, Size size) {
    if(_point.x <= 0) {
      _point.x = _containerSize.width;
      _point.resetPosition();

      if(_point.isRemained) {
        if(_point.y >= 44) {
          _point.isEnable = false;
        } else {
          _actionRemained(_point);
        }

        return _point;
      }
    }


    _point.x -= _point.dX;
    _point.y += _point.func(_point.dX);
    _point.dY += _point.aY;
    _point.dX += _point.aX;
    _point.dA += _point.aA;
    _point.r = _point.r * (1 - ((1 - _point.aR)/ 10));

    if(_point.r <= 3) {
      _point.r = math.Random().nextInt(15).toDouble();
      _point.x = _containerSize.width;
      _point.resetPosition();
    }

//    if(_point.y >= _containerSize.height) {
//      _point.y = 0;
//    }

    var opacity = math.max(0.8 * (radius - math.pi / 2 ) / (3 * math.pi / 2), 0.0) ;
//
    if(opacity >= 0.8) {
      opacity = 0.1;
      _point.dA = 0.1;
    }
    _point.color = _point.color.withOpacity(opacity);

    if(radius != null) {
      _point = _fixPointByRadius(_point);
    }

    return _point;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}