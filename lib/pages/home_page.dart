// ignore_for_file: prefer_const_constructors

import 'package:flutter/services.dart';
import 'package:test_flutter/model/radio.dart';
import 'package:test_flutter/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<MyRadio>? radios;

  @override
  void initState() {
    super.initState();
    fetchRadios();
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    print(radios);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(children: [
        VxAnimatedBox()
            .size(context.screenWidth, context.screenHeight)
            .withGradient(LinearGradient(
              colors: [
                AIUtil.primaryColor1,
                AIUtil.primaryColor2,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ))
            .make(),
        AppBar(
          title: "AI Radio".text.xl4.bold.white.make().shimmer(
                primaryColor: Vx.purple300,
                secondaryColor: Colors.white,
              ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0.0,
        ).h(100.0).p16(),
        VxSwiper.builder(
            itemCount: radios.length,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            itemBuilder: (context, index) {
              final rad = radios[index];
              return VxBox(child: ZStack([]))
                  .bgImage(
                    DecorationImage(
                    image: NetworkImage(rad.image),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)),
                  )
                  .border(color: Colors.black, width: 5.0)
                  .withRounded(value: 60.0)
                  .make().p16().centered();
            }),
      ],
      fit: StackFit.expand,

      ),
    );
  }
}
