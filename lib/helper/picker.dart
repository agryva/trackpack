import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

showPrompt({ BuildContext context, String title, String detailContent, String pathLottie,
  double height = 305,
  Function onSubmit }){
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            contentPadding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            content: Container(
              width: double.maxFinite,
              height: height,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 16),
                  Center(
                    child: Lottie.asset(
                      "$pathLottie",
                      width: 150,
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    '$title',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    '$detailContent',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Trackpack',
                                  style: GoogleFonts.lato(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black45,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 22),
                                        decoration: BoxDecoration(
                                            color: Color(0xffF4F4F8),
                                            borderRadius: BorderRadius.circular(16)),
                                        child: Text(
                                          "Cancel",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    InkWell(
                                      onTap: onSubmit,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 26),
                                        decoration: BoxDecoration(
                                            color: Color(0xff5841BF),
                                            borderRadius: BorderRadius.circular(16)),
                                        child: Text(
                                          "Oke",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )

                            ],
                          )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}