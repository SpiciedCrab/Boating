import 'package:flutter/material.dart';
import 'package:ocean_clock/configs.dart';
import 'dart:async';

import 'package:ocean_clock/drawn_hand.dart';
import 'package:ocean_clock/water_bubble.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'dart:math' as math;

final radiansPerSecond = vector.radians(360 / 1000.0);
final radiansPerRealSecond = vector.radians(360 / 60.0);


class Scence extends StatefulWidget {
  @override
  ScenceState createState() => new ScenceState();
}

class ScenceState extends State<Scence> {

  var _now = DateTime.now();
  List<Point> _points = [];
  List<Point> _bgPoints = [];
  Timer _timer;
  double _trackLength = 0;
  ScrollController _controller = ScrollController();
  double _textHeight = 130;

  static const double _sunSize = 50;
  Point _sunPosition = Point(x: _sunSize / 2, y:  _sunSize/ 2, dX: 1, dY: 1, aX: 1, aY: 1);

  void _updateTime() {
    if(_now.millisecond == 999) {
      isReverting = true;
    }
    if(_now.millisecond == 0){
      isReverting = false;
    }

    var minute = currentMinutes / 60;
    var bounus = minute > 0.5 ? -0 : 0;
    if(_controller.positions.isNotEmpty && _controller.position.minScrollExtent != null) {
      _controller.jumpTo(currentHour * _textHeight + minute * _textHeight / 2 - bounus + _textHeight - MediaQuery.of(context).size.height / 2);
    }
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(milliseconds: 1),
        _updateTime,
      );
    });
  }

  bool isReverting = false;
  int get currentHour => _now.hour;
  int get currentMinutes => 20;

  @override
  Widget build(BuildContext context) {
    bool showPoints = _now.millisecond >= 250 && _now.millisecond <= 750;

    var rotate = -math.pi / 4 + (_now.millisecond / 10 ) * math.pi / 200;
    var transformY = _transformY;
    var _currentTrackPadding = _trackDistance;
    return new Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          Container(
//        padding: EdgeInsets.all(100),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: _sunOpacity - 0.1,
              colors: _isNight ? <Color>[ Color(0xFF373938).withOpacity(_sunOpacity) , Color(0xFF373938).withOpacity(_sunOpacity)] :
              <Color>[Color(0xFFc5d54e), Color(0xFFa9b8cf)],
            ),
          ),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                _isNight ? Opacity(
                  opacity: 0.3 + 0.3 * math.sin(_now.millisecond * radiansPerSecond).abs(),
                  child: Center(
                      child: Transform.translate(offset: _caculateSunPosition(),
                          child: Transform.rotate(angle:  _now.millisecond * radiansPerSecond,
                              child: Image.asset('assets/images/sun.png',
                                fit: BoxFit.fill,
                                width: _sunSize, height:  _sunSize,
                              )))),
                ) : Align(
                  alignment: AlignmentDirectional.center,
                  child: Opacity(
                    opacity: _sunOpacity,
                    child: Transform.translate(offset: Offset(0 , - _sunBottomPadding),
                      child: Transform.scale(
                        scale: _sunScale * (0.9 +  0.1 * math.sin(0.5 * _now.millisecond * radiansPerSecond).abs()),
                        child: Transform.rotate(angle:  _now.second * radiansPerRealSecond,
                            child: Image.asset('assets/images/sun.png',
                              fit: BoxFit.fill,
                              width: _sunSize, height:  _sunSize,
                            )),
                      ),),
                  ),
                ),
                Transform.translate(offset: Offset(_currentTrackPadding, -transformY),
                  child: Transform.rotate(angle:  -math.pi / 8 + math.sin(math.pi * _now.millisecond / 1000) * math.pi / 4,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: <Color>[Color(0xFFe07c6d), Color(0xFFc06354), ],
                          ),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(60),
                              bottomLeft: Radius.circular(60),
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10))
                      ),
                      child: Stack(
                        alignment: AlignmentDirectional.topStart,
                        children: <Widget>[
//                          Padding(
//                            padding: const EdgeInsets.all(30.0).copyWith(top: 20),
//                            child: ClipOval(
//                              child: Container(
//                                color: Colors.yellow,
//                              ),
//                            ),
//                          ),
                          showPoints ? Container(
                              width: 20,
                              height: 5,
                              margin: const EdgeInsets.only(left: 8, top: 20),
                              color: Colors.black,
                            ) : ClipOval(
                            child: Container(
                              margin: const EdgeInsets.only(left: 10, top: 10),
                              height: 30,
                              width: 30,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 5, right: 5),
                                child: ClipOval(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: <Color>[Colors.black26, Colors.black ],
                                        ),
                                    ),
                                    height: 2,
                                    width: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 10, right: 10),
                                      child: ClipOval(
                                        child: Container(
                                          height: 1,
                                          width: 1,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child:
                  Transform.translate(offset: Offset(_currentTrackPadding, -transformY),
                    child: DrawnHand(
                      color: Color(0xFFb15a50),
                      thickness: 15,
                      size: handLength,
                      angleRadians: _now.millisecond * radiansPerSecond,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40.0 + MediaQuery.of(context).padding.left),
                  child: ListView.builder(
                      itemCount: 48,
                      controller: _controller,
                      itemBuilder: (ctx, idx){
                        return Container(
                            height: _textHeight,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text((idx % 24).toString(), textScaleFactor: idx == currentHour ? 1.3 : 1 ,
                              style: Theme.of(context).textTheme.title.copyWith(color: idx > currentHour ? Color(0xFF102343).withOpacity(0.5) : Colors.white.withOpacity(idx == currentHour ? 1 : 0.5)),));
                      }),
                ),
                WaveWidget(
                  config: CustomConfig(
                    gradients: [
                      [Color(0xFF224c7e).withOpacity(0.7), Color(0xFF224c7e).withOpacity(0.3)],
                      [Color(0xFF224c7e).withOpacity(0.3), Color(0xFF224c7e).withOpacity(0.6)],
                    ],
                    durations: [5200, 5000],
                    heightPercentages: [0.432, 0.43],
                    gradientBegin: Alignment.bottomCenter,
                    gradientEnd: Alignment.topCenter,
                  ),
                  waveAmplitude: 0,
                  waveFrequency: 1.0,
                  backgroundColor: Colors.transparent,
                  size: Size(double.infinity, double.infinity),
                ),
                Transform.translate(
                  offset: Offset(0, 0),
                  child: Padding(
                    padding: EdgeInsets.only(top: (40.0 - transformY)),
                    child: Center(
                      child: Container(
                        height: 400,
//                  color: Colors.black.withOpacity(0.5),
                        padding: const EdgeInsets.only(top: 210),
                        child: SizedBox.expand(
                          child: CustomPaint(
                            painter: FloatingPointView(
                                _points,
                                Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                                paddingTop: 12 - transformY,
                                radius:  _now.millisecond * radiansPerSecond,
                                paddingHorizon: _currentTrackPadding
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ) ,
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: _trackMargin),
                    child: Container(
                      height: 88,
                      width: _trackLength + _trackLength / 2,
                      margin: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Container(),),
//                          SizedBox(
//                            width: _trackLength / 4,
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.end,
//                              children: <Widget>[
////                              Transform.rotate(angle: math.pi, child: Icon(Icons.label, size: 40, color: Colors.white.withOpacity(0.2),),),
//                                Container(margin: const EdgeInsets.symmetric(horizontal: 10) ,
//                                  color: Colors.white.withOpacity(0.2), width: _trackLength / 4 - 60 ,height: 5,),],
//                            ),
//                          ),
                          Container(
                            width: _trackLength,
                            height: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text('60', style: Theme.of(context).textTheme.subtitle),
                                Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 20) , color: Colors.white.withOpacity(0.2), height: 5,),),
                                Text('30', style: Theme.of(context).textTheme.subtitle,),
                                Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 20) , color: Colors.white.withOpacity(0.2), height: 5,),),
                                Text('0', style: Theme.of(context).textTheme.subtitle,),
                              ],
                            ),
                          ),
//                          SizedBox(
//                            width: _trackLength / 4,
//                            child: Row(
//                              children: <Widget>[
//                                Container(margin: const EdgeInsets.only(left: 20), width: _trackLength / 4 - 20, color: Colors.white.withOpacity(0.2) ,height: 5,),
//                              ],
//                            ),
//                          ),
                          Expanded(child: Container(),),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double get _trackDistance => _trackMargin / 2 + _trackLength * (60 - currentMinutes) / 60 - _trackLength / 2;
  static const double _trackMargin = 120;
  double get _transformY => -math.sin(2 * math.pi * _now.millisecond / 1000) * 20;
  bool get _isNight => currentHour < 6 || currentHour> 18;
  double get _sunBottomPadding {
    double canvasHeight= MediaQuery.of(context).size.height / 2 - _sunSize - 20 ;
    if(currentHour > 14) {
      return canvasHeight - (currentHour - 14) * (canvasHeight) / 4;
    } else {
      return (currentHour - 6) * canvasHeight / 8;
    }
  }

  double get _sunScale {
    double scaleOrigin=  1;
    if(currentHour > 14) {
      return  1 + scaleOrigin - (currentHour - 14) * (scaleOrigin) / 4;
    } else {
      return  1 + (currentHour - 5) * scaleOrigin / 8;
    }
  }

  double get _sunOpacity {
    double scaleOrigin = 0.7;
    if(_isNight) {
      scaleOrigin = 0.4;
      if(currentHour <= 24 && currentHour >= 18) {
        return 1 - scaleOrigin + (currentHour - 18) * scaleOrigin / 6;
      } else {
        return 1 - scaleOrigin + (6 - currentHour) * scaleOrigin / 6;
      }
    }

    if(currentHour > 14) {
      return  0.3 + scaleOrigin - (currentHour - 14) * (scaleOrigin) / 4;
    } else {
      return 0.3 + (currentHour - 6) * scaleOrigin / 8;
    }
  }

  Future<ui.Codec> _loadImage(AssetBundleImageKey key) async {
    final ByteData data = await key.bundle.load(key.name);
    if (data == null)
      throw 'Unable to read data';
    return await ui.instantiateImageCodec(data.buffer.asUint8List());
  }

  var _sunImage = new ExactAssetImage("assets/images/sun.png");
  ui.Image _sunImageCodec;

  Future<ui.Image> _findSunImage() async {
    if(_sunImageCodec != null) {
      return _sunImageCodec;
    }

    var key = await _sunImage.obtainKey(new ImageConfiguration());
    var codec = await _loadImage(key);
    var info = await codec.getNextFrame();
    _sunImageCodec = info.image;
    return _sunImageCodec;
  }

  Offset _caculateSunPosition() {
    _sunPosition.x += _sunPosition.dX ;
    _sunPosition.dY = _sunPosition.aY * math.sin(_now.millisecond * radiansPerSecond * 0.7) * _sunPosition.dX;
    _sunPosition.y += _sunPosition.dY;

    if(_sunPosition.y >= MediaQuery.of(context).size.height / 2 - _sunSize / 2) {
      _sunPosition.y = MediaQuery.of(context).size.height / 2 - _sunSize / 2;
      _sunPosition.dY = -_sunPosition.dY;
      _sunPosition.aY = - _sunPosition.aY;
    }

    if(_sunPosition.x >= MediaQuery.of(context).size.width / 2 - _sunSize / 2) {
      _sunPosition.x = MediaQuery.of(context).size.width / 2 - _sunSize / 2;
      if((_sunPosition.dX / 4).abs() == 1) {
        _sunPosition.dX = _sunPosition.dX / 4;
      }
      _sunPosition.dX = -_sunPosition.dX;
      _sunPosition.aX = - _sunPosition.aX;
      _sunPosition.dY = -_sunPosition.dY;
      _sunPosition.aY = - _sunPosition.aY;
    }

    if(_sunPosition.x <= - MediaQuery.of(context).size.width / 2 + _sunSize / 2 ) {
      _sunPosition.x =  - MediaQuery.of(context).size.width / 2 + _sunSize / 2;
      if((_sunPosition.dX / 4).abs() == 1) {
        _sunPosition.dX = _sunPosition.dX / 4;
      }
      _sunPosition.dX = - _sunPosition.dX;
      _sunPosition.aX = - _sunPosition.aX;
      _sunPosition.dY = -_sunPosition.dY;
      _sunPosition.aY = - _sunPosition.aY;
    }

    if(_sunPosition.y <=  _sunSize) {
      _sunPosition.y =  _sunSize;
      _sunPosition.dY = -_sunPosition.dY;
      _sunPosition.aY = - _sunPosition.aY;
    }

    double minshipArea = MediaQuery.of(context).size.width - _trackDistance - handLength;
    double maxshipArea = MediaQuery.of(context).size.width - _trackDistance + handLength;
    double sunPosition = MediaQuery.of(context).size.width - _sunPosition.x;
    double handY = handLength - (12 - _transformY);

    if(sunPosition >= minshipArea && sunPosition <= maxshipArea && _sunPosition.y < handY + 20 && _sunPosition.isEnable) {
      if(_sunPosition.dX.abs() != 4) {
        _sunPosition.dX = - 4 * _sunPosition.dX;
      } else {
        _sunPosition.dX = - _sunPosition.dX;
      }

      _sunPosition.aX = - _sunPosition.aX;
      _sunPosition.dY =   _sunPosition.dY;
      _sunPosition.aY = - _sunPosition.aY;
      _sunPosition.isEnable = false;
    } else {
      _sunPosition.isEnable = true;
    }
    
    return Offset(_sunPosition.x, _sunPosition.y);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateTime();
    _findSunImage();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(Scence oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _points = Point.randomPoints(MediaQuery.of(context).size.width);
    _bgPoints = Point.randomPoints(MediaQuery.of(context).size.width);
    _trackLength = MediaQuery.of(context).size.width / 2;
    _sunPosition.x = MediaQuery.of(context).size.width / 2;
    _sunPosition.y = MediaQuery.of(context).size.height / 2;
  }
}