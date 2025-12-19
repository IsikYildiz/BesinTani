# BesinTanı - Derin Öğrenme ile Yemek Tanımlama / Food Recognition with Deep Learning

---

## Türkçe Açıklama

### Proje Özeti

**BesinTanı**, kullanıcıları yeme alışkanlıkları hakkında bilgilendirmek ve daha sağlıklı beslenmeye teşvik etmek amaçlı geliştirilmiş bir mobil uygulamadır. 
Kullanıcılar uygulama ile yemek fotoğraflarını (kamera veya galeriden) tanımlayabilmekte ve bu yemeklerin kalorilerini, besin değerlerini ve  (bir kısmının) basit tariflerini öğrenebilmektedirler. Yemek bilgilerine manuel olarak da erişilebilmektedir.
Kullanıcılar her gün için yedikleri yemekleri bir listeye kaydederek aldıkları kalori ve besin değerlerini takip edebilirler. Yemekler hem tanımlama sonucunda hem de manuel olarak eklenebilmektedir.
Bunnu dışında son 7 gün, 30 gün ve 1 yıllık besin değerlerini görebilirler.

**Derin Öğrenme Modeli**: Yemek tanımlama için geliştirilen derin öğrenme modeli için EfficentNet mimarisinin EfficentNetB3 modeli kullanılmıştır. Bu modelin ağırlıklarından yola çıkarak bir model eğitilmiştir. 
Modelin eğitiminde tenserflow ve keras kütüphaneleri kullanılmıştır. Eğitim Kaggle Notebooks aracılığıyla yapılmıştır. Modelin veri seti, food-101 ile kaggleda bulunabilen TurkishCuisineNet veri setlerinin birleştirilmesi ve düznlenmesiyle oluşturulmuştur.

### Kullanılan Teknolojiler

- **Flutter** (frontend)
- **Flask (Python)** (sunucu)
- **SQLite** (veri tabanı)
- **Tenserflow ve Keras Kütüphaneleri** (derin öğrenme modeli)
- **Visual Studio Code** (ide)

**Teknoloji Seçimleri**: Uygulamanın hem ios hem de android platformlarda çalışabilmesi, buna rağmen hızlıca ve tek kod tabanı üzerinden geliştirilebilmesi için flutter framework seçilmiştir. 
Uygulamanın internete ihtiyacını minimalize etmek için veriler SQLite veri tabanı ile saklanmıştır.
Sunucu yapısı karmaşık olmadığından Flask kullanılmıştır. Derin öğrenme modelinin geliştirilmesi için tenserflow ile keras kütüphaneleri zengin içerikleri sebebiyle seçilmişlerdir.

---

## English Description

### Project Overview

**BesinTanı** is a mobile application developed to inform users about their eating habits and encourage healthier nutrition. 
Users can identify food items through photos (via camera or gallery) to learn about their calories, nutritional values, and—for some items—simple recipes. Nutritional information can also be accessed manually. 
Furthermore, users can track their daily intake by logging meals into a list, which can be populated through both image recognition and manual entry. 
The app also allows users to monitor their nutritional data over the last 7 days, 30 days, and one year.

**Deep Learning Model**: The EfficientNetB3 architecture was utilized for the food identification model. A custom model was trained by leveraging the pre-trained weights of this architecture. 
TensorFlow and Keras libraries were used for the training process, which was conducted via Kaggle Notebooks. The dataset was curated by merging and organizing the Food-101 dataset with the TurkishCuisineNet dataset available on Kaggle.

### Technologies Used

- **Flutter** (frontend)
- **Flask (Python)** (server)
- **SQLite** (database)
- **Tenserflow ve Keras libraries** (deep learning model)
- **Visual Studio Code** (ide)

**Technology Choices**: To ensure the application can operate on both iOS and Android platforms while allowing for rapid development via a single codebase, the Flutter framework was selected. 
To minimize the need for an internet connection, data is stored locally using an SQLite database. 
Flask was utilized for the backend as the server requirements are not overly complex, while TensorFlow and Keras were chosen for developing the deep learning model due to their rich libraries and extensive features.

---
