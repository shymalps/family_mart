import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Extras/animated_wrapper.dart';
import '../../Extras/image_urls.dart';
import '../../Extras/styles.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgColor, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AnimatedWrapper(index: 0, child: _buildTopBar()),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                         Text('Directors',
                            style: AppTextStyles.heading2),
                        const SizedBox(height: 16),

                        // Row 1
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _directorCard(_width, ImageUrls.director_1,
                                'Mr. Jinny Jose Akkara'),
                            _directorCard(
                                _width, ImageUrls.director_2, 'Mr. Jommy John'),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Row 2
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _directorCard(_width, ImageUrls.director_3,
                                'Mrs. Liji Sebastian'),
                            _directorCard(_width, ImageUrls.director_4,
                                'Mrs. Marykutty Sebastian'),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Row 3
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _directorCard(_width, ImageUrls.director_5,
                                'Mrs. Julie Joseph'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // About texts
                        const Text(
                          'We stands for service rather than business',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Mini Supermarket'),
                        const Text('Hotel'),
                        const Text('Pets'),
                        const Text('Aquarium'),
                        const SizedBox(height: 20),
                        const Text(
                          'കോവിഡ് കാലഘട്ടത്തിൽ കൊരട്ടിയിലെ ജനങ്ങൾക്കു വേണ്ടി തുടങ്ങിയ ഒരു സ്ഥാപനം ആണ് ഫാമിലി മാർട്ട്.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'അത്യാവശ്യം വേണ്ട സാധനങ്ങൾ ഡെലിവറി ചാർജ്‌ഇല്ലാതെയും സർവീസ് ചാർജ്, GST പോലെയുള്ള നികുതികളും ഒഴിവാക്കി വീട്ടിൽ എത്തിക്കുക എന്നതായിരുന്നു ലക്ഷ്യം. ഞങ്ങൾ ഇപ്പോഴും ഇത് തുടർന്നു കൊണ്ടിരിക്കുന്നു.',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'ഇപ്പോൾ ഫാമിലി മിനി മാർട്ട് സൂപ്പർമാർക്കറ്റ് കൂടാതെ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('ഹോട്ടൽ'),
                        const Text('ഫിഷ് - മീറ്റ് സ്റ്റാൾ'),
                        const Text('അക്വാറിയം - പെറ്റ്സ് ഷോപ്പ്'),
                        const Text(
                            'തുടങ്ങിയ സ്ഥാപനങ്ങൾ കൊരട്ടിയിൽ പ്രവർത്തിക്കുന്നു'),
                        const Text(
                            '25 ഇൽ പരം കൊരട്ടി നിവാസികൾ ഞങ്ങളോടൊപ്പം തൊഴിൽ ചെയുന്നു'),
                        const Text(
                            'എല്ലാവിധ സഹായ സഹകരണങ്ങൾക്കും നന്ദിയും കടപ്പാടും രേഖപ്പെടുത്തുന്നു. തുടർന്നും പ്രതീക്ഷിച്ചു കൊള്ളുന്നു.'),
                        const SizedBox(height: 20),
                        const Text(
                          'ഹോം ഡെലിവറി ഓർഡർ ചെയ്യാനായി 9995651144',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                            'കംപ്ലൈന്റ്സ് ഉണ്ടെങ്കിൽ 9946098799, 9846518324'),
                        const Text('ഗൂഗിൾ പേ, ഫോൺ പേ, പേടിഎം: 9846518324'),
                        const SizedBox(height: 10),
                        const Text(
                          'വാട്സാപ്പ് ഗ്രൂപ്പിൽ ജോയിൻ ചെയ്യാനായി ലിങ്കിൽ ക്ലിക്ക് ചെയുക ...👇',
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'website: familymartsupermarket.com',
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                        const Text('email: shop2@familymartsupermarket.com'),
                        const SizedBox(height: 20),
                        const Text(
                          'Providing home delivery in Koratty and 5 km surrounding area, Monday to Saturday home delivery available. Sunday morning meat item only providing home delivery. Every day posting price and item details. Providing 30 days credit limit for all our customer members. No membership fees. All items with wholesale rate @ your home.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                            'Chicken, beef, Pork, Fish, grocery, stationary, etc.....items are available in our shop.....'),
                        const SizedBox(height: 20),
                        const Text('Contact: 9995651144',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _directorCard(double width, String imagePath, String name) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: width * 0.4,
      height: width * 0.5,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.bottomCenter.add(const Alignment(0, -0.6)),
            colors: [Colors.black, Colors.transparent],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('About Us', style: AppTextStyles.heading1),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.4)
                    ]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
