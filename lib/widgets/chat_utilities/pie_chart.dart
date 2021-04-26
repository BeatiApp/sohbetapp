import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';

class StorageChartWidget extends StatelessWidget {
  final Map<String, double> storageMap;

  const StorageChartWidget({Key key, this.storageMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalFileSize = 0;

    storageMap.values.forEach((element) {
      totalFileSize += element;
    });

    List<Color> colorList = [
      Colors.red,
      Colors.yellow,
      Colors.blue,
      Colors.green,
      Colors.purple
    ];
    return Container(
      height: 250,
      width: MediaQuery.of(context).size.width * 0.8,
      // color: Colors.grey,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Depolama Alanı ve Bilgiler",
              style:
                  GoogleFonts.roboto(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            PieChart(
              dataMap: storageMap,
              animationDuration: Duration(milliseconds: 800),
              chartLegendSpacing: 30,
              chartRadius: MediaQuery.of(context).size.width / 4.5,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 30,
              legendOptions: LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendShape: BoxShape.circle,
                legendTextStyle: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: false,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Toplam Tutulan Depolama Alanı: ${filesize(totalFileSize.toInt())}",
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
