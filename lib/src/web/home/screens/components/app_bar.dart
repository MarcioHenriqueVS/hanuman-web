import 'package:flutter/material.dart';
import '../../../../utils.dart';

class NewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NewAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseWidth = 1920;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      color: const Color(0xff13171a),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(60 * fem, 0, 0 * fem, 0 * fem),
                width: 60 * fem,
                height: 60 * fem,
                child: Image.asset(
                  'assets/images/logoTeste.png',
                ),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        1550 * fem, 0 * fem, 60 * fem, 0 * fem),
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          // group8Hn2 (1:92)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 26.21 * fem, 0 * fem),
                          width: 26.21 * fem,
                          height: 26.21 * fem,
                          child: Image.asset(
                            'assets/images/twitter.png',
                          ),
                        ),
                        Container(
                          // group6okN (1:95)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 26.21 * fem, 0 * fem),
                          width: 26.21 * fem,
                          height: 26.21 * fem,
                          child: Image.asset(
                            'assets/images/facebook.png',
                          ),
                        ),
                        Container(
                          // vector8Gr (1:98)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 26.76 * fem, 0 * fem),
                          width: 26.21 * fem,
                          height: 26.21 * fem,
                          child: Image.asset(
                            'assets/images/instagram.png',
                          ),
                        ),
                        Container(
                          // frame42fGn (1:99)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 0 * fem),
                          width: 26.21 * fem,
                          height: 26.21 * fem,
                          child: Image.asset(
                            'assets/images/youtube.png',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // group64zHp (1:103)
                    // margin: EdgeInsets.fromLTRB(
                    //     0 * fem, 40.55 * fem, 188.91 * fem, 0 * fem),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // frame49ufg (1:107)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 125 * fem, 0 * fem),
                          height: 40,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.green, // Cor da linha
                                          width: 2.0, // Espessura da linha
                                        ),
                                      ),
                                    ),
                                    // frame48qxe (1:108)
                                    padding: EdgeInsets.fromLTRB(13.23 * fem,
                                        0 * fem, 13.23 * fem, 0 * fem),
                                    height: double.infinity,
                                    child: Text(
                                      'Home',
                                      style: SafeGoogleFont(
                                        'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1 * ffem / fem,
                                        color: const Color(0xfffbfbfb),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                // autogroupgureW3C (89BdL52knvJHrZwYFEgUrE)
                                padding: EdgeInsets.fromLTRB(
                                    54.15 * fem, 0 * fem, 4.23 * fem, 0 * fem),
                                height: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      // services1ke (1:112)
                                      margin: EdgeInsets.fromLTRB(0 * fem,
                                          0 * fem, 57.87 * fem, 0 * fem),
                                      child: Text(
                                        'Services',
                                        style: SafeGoogleFont(
                                          'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          height: 1 * ffem / fem,
                                          color: const Color(0xfffbfbfb),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      // projectsu5L (1:115)
                                      margin: EdgeInsets.fromLTRB(0 * fem,
                                          0 * fem, 60.37 * fem, 0 * fem),
                                      child: Text(
                                        'Projects',
                                        textAlign: TextAlign.center,
                                        style: SafeGoogleFont(
                                          'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          height: 1 * ffem / fem,
                                          color: const Color(0xfffbfbfb),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      // supportR3g (1:118)
                                      'Support',
                                      textAlign: TextAlign.center,
                                      style: SafeGoogleFont(
                                        'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1 * ffem / fem,
                                        color: const Color(0xfffbfbfb),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
