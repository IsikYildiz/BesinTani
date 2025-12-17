import 'package:dio/dio.dart';
import 'dart:io';

class ServerRepository {
  static const String baseUrl = 'http://10.0.2.2:5000'; 
  final Dio _dio = Dio();

  // Sunucudan gelen yemek isimleri ile DB'deki isimleri eşleştirme haritası
  static const Map<String, String> foodNameMap = {
    "adana_kebap": "Adana Kebap",
    "anne_koftesi": "Anne Köftesi",
    "baklava": "Baklava",
    "balik_ve_patates": "Balık Ve Patates",
    "beyaz_lahana_sarmasi": "Beyaz Lahana Sarması",
    "biber_dolma": "Biber Dolma",
    "biftek": "Biftek",
    "brokoli": "Brokoli",
    "bruksel_lahanasi": "Brüksel Lahanası",
    "bulgur_pilavi": "Bulgur Pilavı",
    "burrito": "Burrito",
    "cacik": "Cacık",
    "canak_enginar": "Enginar", 
    "cannoli": "Cannoli",
    "cheesecake": "Cheesecake",
    "churros": "Churros",
    "cig_kofte": "Çig Köfte",
    "cikolatali_pasta": "Çikolatalı Pasta",
    "cilekli_pasta": "Çilekli Pasta",
    "cin_boregi": "Çin Böreği",
    "cipura": "Çipura",
    "coban_salatasi": "Çoban Salatası",
    "creme_brulee": "Krem Brule", 
    "cup_cakes": "Cup Cakes",
    "dana_kaburga_biftek": "Dana Kaburga Biftek",
    "domates_corbasi": "Domates Çorbası",
    "dondurma": "Dondurma",
    "doner": "Döner",
    "donuts": "Donuts",
    "dumplings": "Dumplings",
    "elmali_turta": "Elmalı Turta",
    "eriste": "Erişte",
    "et_sote": "Et Sote",
    "falafel": "Falafel",
    "fransiz_sogan_corbasi": "Fransız Soğan Çorbası",
    "fransiz_tostu": "Fransiz Tostu",
    "hamburger": "Hamburger",
    "hamsi_tava": "Hamsi Tava",
    "haslanmis_yumurta": "Haşlanmış Yumurta",
    "havuclu_kek": "Havuçlu Kek",
    "hot_dog": "Hot Dog",
    "hummus": "Hummus",
    "hunkar_begendi": "Hünkar Beğendi",
    "icli_kofte": "İçli Kofte",
    "iskender": "İskender",
    "ispanak_yemegi": "Ispanak Yemegi",
    "izgara_somon": "Izgara Somon",
    "kabak_mucver": "Kabak Mücver",
    "kalamar_kizartmasi": "Kalamar Kızartması",
    "kalburabasti": "Kalburabastı",
    "karnabahar": "Karnabahar",
    "karniyarik": "Karnıyarık",
    "kazandibi": "Kazandibi",
    "kemal_pasa_tatlisi": "Kemalpaşa Tatlısı",
    "kisir": "Kısır",
    "kiymali_borek": "Kıymalı Börek",
    "kiymali_pide": "Kıymalı Pide",
    "kokorec": "Kokoreç",
    "lahmacun": "Lahmacun",
    "lasagna": "Lazanya",
    "levrek": "Levrek",
    "lokma": "Lokma",
    "mac_and_cheese": "Mac And Cheese",
    "manti": "Mantı",
    "menemen": "Menemen",
    "mercimek_corbasi": "Mercimek Çorbası",
    "mercimek_koftesi": "Mercimek Köftesi",
    "midye": "Midye",
    "midye_tava": "Midye Tava",
    "mumbar_dolmasi": "Mumbar Dolması",
    "nachos": "Nachos",
    "omlet": "Omlet",
    "paella": "Paella",
    "pankek": "Pankek",
    "patates_kizartmasi": "Patates Kızartması",
    "patates_puresi": "Patates Püresi",
    "patates_salatasi": "Patates Salatası",
    "patlican_kebabi": "Patlıcan Kebabı",
    "peynirli_borek": "Peynirli Börek",
    "pilav": "Pilav",
    "pirasa": "Pırasa",
    "pizza": "Pizza",
    "ramen": "Ramen",
    "ravioli": "Ravioli",
    "risotto": "Risotto",
    "sahlep": "Salep", 
    "salcali_makarna": "Salçalı Makarna",
    "sandvic": "Sandviç",
    "sehriye_corbasi": "Şehriye Çorbası",
    "sesar_salatasi": "Sezar Salatası",
    "sogan_halkasi": "Soğan Halkasi",
    "spagetti": "Spagetti",
    "su_boregi": "Su Böreği",
    "sucuklu_yumurta": "Sucuklu Yumurta",
    "sulu_bamya_yemegi": "Sulu Bamya Yemeği",
    "sulu_barbunya_yemegi": "Sulu Barbunya Yemeği",
    "sulu_bezelye_yemegi": "Sulu Bezelye Yemeği",
    "sulu_kuru_fasulye_yemegi": "Sulu Kuru Fasulye Yemeği",
    "sulu_mercimek_yemegi": "Sulu Mercimek Yemeği",
    "sulu_nohut_yemegi": "Sulu Nohut Yemeği",
    "sulu_patates_yemegi": "Sulu Patates Yemeği",
    "susi": "Suşi", 
    "sutlac": "Sütlaç",
    "taco": "Taco",
    "tantuni": "Tantuni",
    "tarhana_corbasi": "Tarhana Çorbası",
    "tas_kebabi": "Tas Kebabı",
    "tavuk_kanat": "Tavuk Kanat",
    "tavuk_sote": "Tavuk Sote",
    "tiramisu": "Tiramisu",
    "tulumba_tatlisi": "Tulumba Tatlısı",
    "waffle": "Waffle",
    "yaprak_sarma": "Yaprak Sarma",
    "yayla_corbasi": "Yayla Çorbası",
    "yogurtlu_makarna": "Yoğurtlu Makarna",
    "yunan_salatasi": "Yunan Salatası",
    "zeytinyagli_fasulye": "Zeytinyağlı Fasulye"
  };


  // Fotoğrafı sunucuya gönderip tahmini alır
  Future<Map<String, dynamic>?> predictFood(File imageFile) async {
    final String uploadUrl = '$baseUrl/';

    try {
      // Dosyayı FormData olarak hazırlar
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      Response response = await _dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        
        // Sunucudan gelen ismi alır
        final String rawName = data['label'] ?? '';
        print('Sunucudan gelen cevap: $rawName');

        // İsim dönüştürme
        if (foodNameMap.containsKey(rawName)) {
          data['food_name'] = foodNameMap[rawName];
        } else {
          print('Server: DB için eşleşen yemek ismi bulunamadı: $rawName');
          return null; 
        }
        return data;
      } else {
        print('Sunucu hatası: ${response.statusCode} ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.unknown) {
        print('Bağlantı Hatası: Sunucuya ulaşılamadı. IP adresini ve sunucunun çalıştığını kontrol edin.');
      } else {
        print('HTTP/Dio Hatası: $e');
      }
      return null;
    } catch (e) {
      print('Genel Server Hatası: $e');
      return null;
    }
  }
}