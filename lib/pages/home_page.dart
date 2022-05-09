// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:test_flutter/model/radio.dart';
import 'package:test_flutter/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<MyRadio> radios;
  MyRadio _selectedRadio;
  Color _selectedColor;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "5f4c56155288a8a3f6453155660025d82e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedRadio.url);
        break;
      case "pause":
        _audioPlayer.stop();
        _isPlaying = false;
        setState(() {});
        break;
      case "next":
        _audioPlayer.stop();
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index + 1 > MyRadioList.radios.length) {
          newRadio =
              MyRadioList.radios.firstWhere((element) => element.id == 1);
          MyRadioList.radios.remove(newRadio);
          MyRadioList.radios.insert(0, newRadio);
        } else {
          newRadio = MyRadioList.radios
              .firstWhere((element) => element.id == index + 1);
          MyRadioList.radios.remove(newRadio);
          MyRadioList.radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;
      case "prev":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio =
              MyRadioList.radios.firstWhere((element) => element.id == 1);
          MyRadioList.radios.remove(newRadio);
          MyRadioList.radios.insert(0, newRadio);
        } else {
          newRadio = MyRadioList.radios
              .firstWhere((element) => element.id == index - 1);
          MyRadioList.radios.remove(newRadio);
          MyRadioList.radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;
      default:
        print("Unknown command: ${response["command"]}");
        break;
    }
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    final radioJsonDecode = jsonDecode(radioJson);
    // radios = MyRadioList.fromJson(radioJson).radios;
    var radioData = radioJsonDecode["radios"];
    MyRadioList.radios = List.from(radioData)
        .map<MyRadio>((radio) => MyRadio.fromMap(radio))
        .toList();
    // print(MyRadioList.radios);
    _selectedRadio = MyRadioList.radios.first;
    _selectedColor = Color(int.tryParse(_selectedRadio.color));
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio =
        MyRadioList.radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: _selectedColor ?? AIUtil.primaryColor2,
          child: MyRadioList.radios != null
              ? [
                  100.heightBox,
                  "All Songs".text.xl3.white.semiBold.make().px16(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: MyRadioList.radios
                        .map((e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.image),
                              ),
                              title: e.name
                                  .text
                                  .xl
                                  .white
                                  .semiBold
                                  .make(),
                              subtitle: e.tagline.text.white.make(),
                            ))
                        .toList(),
                  ).expand()
                ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
        ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(
                colors: [
                  AIUtil.primaryColor2,
                  _selectedColor ?? AIUtil.primaryColor1,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))
              .make(),
          [
            AppBar(
              title: "AI Radio".text.xl4.bold.white.make().shimmer(
                    primaryColor: Vx.purple300,
                    secondaryColor: Colors.white,
                  ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0.0,
            ).h(100.0).p16(),
            20.heightBox,
            "Start with - Hey Alan".text.italic.semiBold.white.make(),
            10.heightBox,
            VxSwiper.builder(
              itemCount: MyRadioList.radios.length,
              height: 50.0,
              viewportFraction: 0.35,
              autoPlay: true,
              autoPlayAnimationDuration: 3.seconds,
              autoPlayCurve: Curves.linear,
              enableInfiniteScroll: true,
              itemBuilder: (context, index) {
                final s = MyRadioList.radios[index];
                return Chip(
                  label: s.name.text.make(),
                  backgroundColor: Vx.randomColor,
                );
              },
            )
          ].vStack(),
          30.heightBox,
          MyRadioList.radios != null
              ? VxSwiper.builder(
                  itemCount: MyRadioList.radios.length,
                  aspectRatio: 1.0,
                  // context.mdWindowSize==MobileWindowSize.xsmall?1.0:context.mdWindowSize==MobileWindowSize.medium? 2.0:3.0
                  enlargeCenterPage: true,
                  onPageChanged: (index) {
                    _selectedRadio = MyRadioList.radios[index];
                    final colorHex = MyRadioList.radios[index].color;
                    _selectedColor = Color(int.tryParse(colorHex));
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final rad = MyRadioList.radios[index];
                    return VxBox(
                      child: ZStack(
                        [
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: VxBox(
                              child: rad.category.text.uppercase.white
                                  .make()
                                  .px16(),
                            )
                                .height(40)
                                .black
                                .alignCenter
                                .withRounded(value: 10.0)
                                .make(),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VStack(
                              [
                                rad.name.text.xl3.white.bold.make(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold.make(),
                                10.heightBox,
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            ),
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: [
                                Icon(
                                  CupertinoIcons.play_circle,
                                  color: Colors.white,
                                ),
                                10.heightBox,
                                "Double tap to Play".text.gray300.make(),
                              ].vStack())
                        ],
                        clip: Clip.antiAlias,
                      ),
                    )
                        .clip(Clip.antiAlias)
                        .bgImage(
                          DecorationImage(
                              image: Image.network(rad.image).image,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)),
                        )
                        .border(color: Colors.black, width: 5.0)
                        .withRounded(value: 60.0)
                        .make()
                        .onInkDoubleTap(() {
                      _playMusic(rad.url);
                    }).p16();
                  },
                ).centered()
              : Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                )),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaying)
                "Playing Now - ${_selectedRadio.name}".text.xl2.white.bold.makeCentered(),
                20.heightBox,
              Icon(
                _isPlaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onInkTap(() {
                if (_isPlaying) {
                  _audioPlayer.stop();
                } else {
                  _playMusic(_selectedRadio.url);
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12),
        ],
        fit: StackFit.expand,
      ),
    );
  }
}
