import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/product_controller.dart';
import 'package:ofcluxury_app/views/category_screen/category_details.dart';
import 'package:ofcluxury_app/views/widgets_common/bg_widget.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProductController());

    return bgWidget(
        child: Scaffold(
          appBar: AppBar(
            title: categories.text.fontFamily(bold).color(darkFontGrey).make(),
          ),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
                shrinkWrap: true,
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 200),
                itemBuilder: (context,index){
                  return Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(categoryImages[index], width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                      8.heightBox,
                      categoriesList[index].text.color(darkFontGrey).fontFamily(semibold).size(12).align(TextAlign.center).make(),
                    ],
                  ).box.color(lightGrey).withRounded(value: 16).padding(const EdgeInsets.all(8)).make().onTap(() {
                    controller.getSubCategories(categoriesList[index]);
                    Get.to(
                          () => CategoryDetails(title: categoriesList[index]),
                    );
                  });
                }),
          ),
        )
    );
  }
}
