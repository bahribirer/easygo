// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get errorEmptyEmail => 'E-posta adresinizi giriniz.';

  @override
  String get errorInvalidEmail => 'Geçerli bir e-posta giriniz.';

  @override
  String get errorMissingInfoTitle => 'Eksik / Hatalı Bilgi';

  @override
  String get errorMissingInfoMessage =>
      'Lütfen e-posta alanını kontrol ederek tekrar deneyin.';

  @override
  String get successSentTitle => 'Gönderildi';

  @override
  String successSentMessage(Object email) {
    return 'Şifre sıfırlama bağlantısı $email adresinize gönderildi. Gelen kutusu ve spam klasörünü kontrol edin.';
  }

  @override
  String get errorNetwork => 'Ağ hatası. İnternet bağlantınızı kontrol edin.';

  @override
  String get errorTooManyRequests =>
      'Çok fazla deneme yapıldı. Bir süre sonra tekrar deneyin.';

  @override
  String get errorUserDisabled => 'Bu hesap devre dışı bırakılmış.';

  @override
  String get errorGeneric =>
      'İşlem alınamadı. Bir süre sonra tekrar deneyin veya farklı bir e-posta ile deneyin.';

  @override
  String get errorGeneric2 => 'İşlem alınamadı. Lütfen tekrar deneyiniz.';

  @override
  String get infoTitle => 'Bilgi';

  @override
  String get back => 'Geri';

  @override
  String get forgotPasswordTitle => 'Şifremi Unuttum';

  @override
  String get forgotPasswordSubtitle =>
      'Mail adresine doğrulama bağlantısı göndereceğiz.';

  @override
  String get universityEmailLabel => 'Üniversite E-mail Adresi';

  @override
  String get universityEmailHint => 'ornek@samsun.edu.tr';

  @override
  String get forgotPasswordNote =>
      'Gelen kutunuzu ve spam klasörünü kontrol edin. Kurumsal adreslerde karantinaya düşebilir.';

  @override
  String get sendVerificationButton => 'Doğrulama Bağlantısı Gönder';

  @override
  String get help => 'Yardım';

  @override
  String get helpMessage =>
      'E-posta gelmediyse spam klasörünü kontrol edin veya birkaç dakika sonra tekrar deneyin.';

  @override
  String get emailNotReceived => 'E-posta gelmedi mi?';

  @override
  String get loginTitleLine1 => 'Devam Etmek İçin';

  @override
  String get loginTitleLine2 => 'Giriş Yapınız.';

  @override
  String get emailLabel => 'E-posta adresi';

  @override
  String get emailHint => 'universite@ornek.edu.tr';

  @override
  String get emailRequired => 'E-posta gerekli';

  @override
  String get emailInvalid => 'Geçerli bir e-posta girin';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'Şifre gerekli';

  @override
  String get passwordMinLength => 'En az 6 karakter';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get loginErrorTitle => 'Giriş Başarısız';

  @override
  String get loginInfoTitle => 'Eksik Bilgi';

  @override
  String get loginInfoMessage =>
      'Lütfen e-posta ve şifre alanlarını düzgün doldurun.';

  @override
  String get loginErrorWrongCredentials => 'E-posta veya şifre hatalı.';

  @override
  String get loginErrorNotFound => 'Bu e-posta ile kullanıcı bulunamadı.';

  @override
  String get loginErrorTooMany =>
      'Çok fazla deneme. Biraz sonra tekrar deneyin.';

  @override
  String get loginErrorNetwork => 'Ağ hatası. Bağlantınızı kontrol edin.';

  @override
  String get loginErrorInvalidEmail => 'Geçersiz e-posta adresi.';

  @override
  String loginErrorUnexpected(Object error) {
    return 'Beklenmeyen hata: $error';
  }

  @override
  String get ok => 'Tamam';

  @override
  String get commonBack => 'Geri';

  @override
  String get registerTitle => 'Hesap Oluştur';

  @override
  String get registerSubtitle => 'Hemen kayıt ol, sohbete başla';

  @override
  String get nameLabel => 'İsim Soyisim';

  @override
  String get nameHint => 'Adını yaz';

  @override
  String get btnRegister => 'Kayıt Ol';

  @override
  String get dialogInfoTitle => 'Eksik / Hatalı Bilgi';

  @override
  String get dialogErrorTitle => 'Kayıt Başarısız';

  @override
  String get infoFillForm => 'Lütfen tüm alanları doğru şekilde doldurun.';

  @override
  String get errorEmailDomain => 'Lütfen geçerli bir @metu.edu.tr adresi girin';

  @override
  String passwordMinChars(Object count) {
    return 'En az $count karakter';
  }

  @override
  String get strengthWeak => 'Zayıf';

  @override
  String get strengthMedium => 'Orta';

  @override
  String get strengthGood => 'İyi';

  @override
  String get strengthStrong => 'Güçlü';

  @override
  String get activeChatsTitle => 'Aktif Sohbetler';

  @override
  String get noActiveChatsMessage => 'Şu an aktif sohbetiniz bulunmamaktadır.';

  @override
  String get archivedChatsTitle => 'Arşivlenmiş Sohbetler';

  @override
  String get noArchivedChatsMessage =>
      'Henüz arşivlenmiş sohbetiniz bulunmamaktadır.';

  @override
  String get friendsListTitle => 'Arkadaş Listesi';

  @override
  String get sortAZ => 'A → Z';

  @override
  String get sortZA => 'Z → A';

  @override
  String get friendRemovedMessage => 'Arkadaş listeden kaldırıldı.';

  @override
  String get searchFriendsHint => 'İsim, e-posta veya konum ara';

  @override
  String get defaultUserName => 'Kullanıcı';

  @override
  String friendCountLabel(Object count) {
    return '$count kişi';
  }

  @override
  String get noFriendsTitle => 'Hiç arkadaş yok.';

  @override
  String get noFriendsSubtitle =>
      'Arama bölümünden kullanıcıları bulup arkadaş ekleyebilirsin.';

  @override
  String get searchHint => 'Ara';

  @override
  String get clear => 'Temizle';

  @override
  String get profileLoadFailed => 'Profil verisi alınamadı.';

  @override
  String get genericError => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get unfriendConfirmTitle => 'Arkadaşlıktan çıkar?';

  @override
  String unfriendConfirmMessage(Object name) {
    return '\"$name\" kişi listesinden kaldırılacak.';
  }

  @override
  String get unfriendConfirmYes => 'Evet, çıkar';

  @override
  String get unfriendSuccessTitle => 'Arkadaşlık Silindi 💔';

  @override
  String get unfriendSuccessMessage =>
      'Bu kişiyi arkadaş listesinden kaldırdın.';

  @override
  String get userDefault => 'Kullanıcı';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get friendsSection => 'Arkadaşlar';

  @override
  String get interestsSection => 'İlgi Alanları';

  @override
  String get noInterests => 'İlgi alanı belirtilmemiş';

  @override
  String get unfriendButton => 'Arkadaşlıktan Çıkar';

  @override
  String get sendMessage => 'Mesaj Gönder';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get errorTitle => 'Hata';

  @override
  String get friendsFetchError =>
      'Veriler alınırken bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get friendAcceptedTitle => 'Arkadaş Oldunuz';

  @override
  String get friendAcceptedMessage => 'İstek kabul edildi.';

  @override
  String get friendAcceptError => 'İstek kabul edilemedi.';

  @override
  String get friendRejectedTitle => 'Reddedildi';

  @override
  String get friendRejectedMessage => 'İstek reddedildi.';

  @override
  String get friendRejectError => 'İstek reddedilemedi.';

  @override
  String get friendsSummary => 'Arkadaş';

  @override
  String get requestsSummary => 'İstek';

  @override
  String get friendRequestsTitle => 'Arkadaşlık İstekleri';

  @override
  String get noFriendRequests => 'Şu an bekleyen isteğin yok.';

  @override
  String pendingRequests(Object count) {
    return '$count beklemede';
  }

  @override
  String get accept => 'Kabul';

  @override
  String get reject => 'Reddet';

  @override
  String get noFriends => 'Henüz arkadaşın yok gibi görünüyor.';

  @override
  String get findFriends => 'Arkadaş Bul';

  @override
  String get friendsTitle => 'Arkadaşlar';

  @override
  String get manageConnections => 'Bağlantılarını yönet';

  @override
  String get addFriendButton => 'Arkadaş Ekle';

  @override
  String get searchError => 'Arama sırasında bir hata oluştu.';

  @override
  String get selfRequestTitle => 'Olmaz ki 🙂';

  @override
  String get selfRequestMessage => 'Kendine arkadaşlık isteği gönderemezsin.';

  @override
  String get requestSentTitle => 'İstek Gönderildi';

  @override
  String requestSentMessage(Object name) {
    return '$name adlı kullanıcıya arkadaşlık isteği gönderildi.';
  }

  @override
  String get requestFailedTitle => 'Gönderilemedi';

  @override
  String get requestFailedMessage =>
      'İstek gönderilirken bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get searchUsersTitle => 'Kullanıcı Ara';

  @override
  String get searchButton => 'Ara';

  @override
  String get thisIsYou => 'Bu sensin';

  @override
  String get add => 'Ekle';

  @override
  String get alreadyFriend => 'Zaten arkadaş';

  @override
  String get pending => 'Beklemede';

  @override
  String get close => 'Kapat';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String get eventCancelled => 'Etkinlik iptal edildi.';

  @override
  String get cancelFailed => 'İptal edilemedi';

  @override
  String get error => 'Hata';

  @override
  String get sendFailed => 'Gönderilemedi';

  @override
  String get createEvent => 'Etkinlik Oluştur';

  @override
  String get eventType => 'Etkinlik Tipi';

  @override
  String get eventTypeCoffee => 'Kahve';

  @override
  String get eventTypeMeal => 'Yemek';

  @override
  String get eventTypeChat => 'Sohbet';

  @override
  String get eventTypeStudy => 'Ders Çalışma';

  @override
  String get eventTypeSport => 'Spor';

  @override
  String get eventTypeCinema => 'Sinema';

  @override
  String get select => 'Seçiniz';

  @override
  String get dateWeekendOnly => 'Tarih (sadece Cumartesi & Pazar)';

  @override
  String get selectDate => 'Tarih Seç';

  @override
  String get selectDateShort => 'Tarih seçin';

  @override
  String get timeSlot => 'Saat Aralığı';

  @override
  String get city => 'Şehir';

  @override
  String get selectCity => 'İl seçiniz';

  @override
  String get sending => 'Gönderiliyor…';

  @override
  String get sendToPool => 'Havuza Gönder';

  @override
  String get eventSent => 'Etkinlik havuza gönderildi.';

  @override
  String get limitReachedTitle => 'Günlük limit doldu';

  @override
  String get limitReachedMessage =>
      'Bugün en fazla 3 buluşma oluşturabilirsin.';

  @override
  String get activeChats => 'Aktif Sohbetler';

  @override
  String get archivedChats => 'Arşivlenmiş Sohbetler';

  @override
  String get confirmCancelTitle => 'Etkinliği iptal etmek istiyor musun?';

  @override
  String get confirmCancelMessage => 'Bu işlem geri alınamaz.';

  @override
  String get confirmCancelOk => 'Evet, iptal et';

  @override
  String get noEventsTitle => 'Henüz bir buluşma yok';

  @override
  String get noEventsMessage =>
      'Hemen bir etkinlik oluştur; birlikte güzel vakit geçirebileceğin insanlarla tanış.';

  @override
  String get eventButtonLabel => 'Etkinlik';

  @override
  String get pendingStatus => 'Beklemede';

  @override
  String get inboxTitle => 'Gelen Kutusu';

  @override
  String get inboxMarkAllRead => 'Hepsini okundu yap';

  @override
  String get inboxDeleteAll => 'Tümünü sil';

  @override
  String get inboxEmpty => 'Henüz bildirim yok 💌';

  @override
  String get timeNow => 'şimdi';

  @override
  String timeMinutes(Object count) {
    return '$count dk önce';
  }

  @override
  String timeHours(Object count) {
    return '$count sa önce';
  }

  @override
  String timeDays(Object count) {
    return '$count gün önce';
  }

  @override
  String get editProfileTitle => 'Profili Düzenle';

  @override
  String get editProfileName => 'Ad / Kullanıcı Adı';

  @override
  String get editProfileBirthDate => 'Doğum Tarihi';

  @override
  String get editProfileCity => 'Şehir';

  @override
  String get editProfileInterests => 'İlgi Alanları';

  @override
  String get editProfileSave => 'Kaydet';

  @override
  String get editProfileSaving => 'Kaydediliyor…';

  @override
  String get birthDateHelp => 'Doğum Tarihini Seç';

  @override
  String get completeProfile => 'Profili Tamamla';

  @override
  String get percentSign => '%';

  @override
  String stepCount(Object current, Object total) {
    return 'Adım $current / $total';
  }

  @override
  String get languageTitle => 'Dil';

  @override
  String get languageSubtitle => 'Uygulamayı hangi dilde kullanmak istersin?';

  @override
  String get languageSelect => 'Dil seçiniz';

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get langEnglish => 'İngilizce';

  @override
  String get errorSelectLanguage => 'Lütfen bir dil seçin';

  @override
  String get genderTitle => 'Cinsiyet';

  @override
  String get genderSubtitle => 'Kendini nasıl tanımlıyorsun?';

  @override
  String get genderSelect => 'Cinsiyet seçiniz';

  @override
  String get genderFemale => 'Kadın';

  @override
  String get genderMale => 'Erkek';

  @override
  String get genderOther => 'Diğer';

  @override
  String get errorSelectGender => 'Lütfen bir cinsiyet seçin';

  @override
  String get infoEditableLater =>
      'Bu bilgileri daha sonra profil ayarlarından değiştirebilirsin.';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get interestsTitle => 'İlgi Alanları';

  @override
  String get interestsSubtitle =>
      'Hayatını renklendiren tutkularını paylaş. En az 5 ilgi alanı seç.';

  @override
  String get clearAll => 'Tümünü temizle';

  @override
  String minInfoOk(Object count) {
    return 'Harika! $count ilgi alanı seçtin.';
  }

  @override
  String minInfoNotEnough(Object remaining) {
    return 'En az 5 ilgi alanı seç. Kalan: $remaining';
  }

  @override
  String get backButton => 'Geri';

  @override
  String get step3Title => 'Konum ve Doğum Tarihi';

  @override
  String get step3Subtitle =>
      'Seni daha iyi tanımamıza yardım et. Konumun keşfet içeriklerinde, yaşın ise önerilerde daha iyi eşleşmeler için kullanılır.';

  @override
  String get locationTitle => 'Konum';

  @override
  String get locationSelect => 'İl Seçiniz';

  @override
  String get birthDateTitle => 'Doğum Tarihi';

  @override
  String get birthDateSelect => 'Doğum Tarihini Seç';

  @override
  String get birthDateHint => 'GG.AA.YYYY';

  @override
  String get formErrorCityAndDate =>
      'Devam etmek için şehir ve doğum tarihi seçmelisin.';

  @override
  String get saving => 'Kaydediliyor…';

  @override
  String get step4Title => 'Profil Fotoğrafın';

  @override
  String get step4Subtitle =>
      'Gülümsemeyi unutma! Fotoğrafın ilk izlenim için çok önemli.';

  @override
  String get photoSource => 'Fotoğraf Kaynağı';

  @override
  String get gallery => 'Galeri';

  @override
  String get camera => 'Kamera';

  @override
  String get photoSelect => 'Fotoğrafı seç';

  @override
  String get step4Hint =>
      'Net ve aydınlık bir fotoğraf seç. Yüzün görünür olsun, bu seni daha bulunabilir kılar.';

  @override
  String get registrationCompleted => 'Kayıt Tamamlandı!';

  @override
  String get registrationCompletedSubtitle =>
      'Hesabın hazır. Keyifle keşfetmeye başlayabilirsin 🎉';

  @override
  String get startApp => 'Uygulamaya Başla';

  @override
  String get skipForNow => 'Sonra Yapacağım';

  @override
  String get uploading => 'Yükleniyor…';

  @override
  String get complete => 'Tamamla';

  @override
  String get welcomeTitle1 => 'Hoş';

  @override
  String get welcomeTitle2 => 'geldiniz…';

  @override
  String get welcomeSubtitle => '\"Bağlantılar kur,\nsohbet et, eğlen\"';

  @override
  String get noAccount => 'Hesabın yok mu? ';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get googleSignIn => 'Google ile Devam Et';

  @override
  String get profileFriends => 'Arkadaş';

  @override
  String get profileAge => 'Yaş';

  @override
  String get profileAbout => 'Hakkında';

  @override
  String get profileEmail => 'E-posta';

  @override
  String get profileLocation => 'Konum';

  @override
  String get profileNoData => 'Profil verisi bulunamadı';

  @override
  String get profileOpenSettings => 'Ayarları Aç';

  @override
  String get profileUnknown => 'Bilinmiyor';

  @override
  String friendsCount(Object count) {
    return '$count kişi';
  }

  @override
  String get friendsEmpty => 'Henüz arkadaşın yok gibi görünüyor.';

  @override
  String get friendsFind => 'Arkadaş Bul';

  @override
  String get friendsSeeAll => 'Tüm arkadaşları gör';

  @override
  String get interestsEmpty => 'İlgi alanı belirtilmemiş';

  @override
  String get settings => 'Ayarlar';

  @override
  String get unknownUser => 'Bilinmeyen';

  @override
  String get profileViewsTitle => 'Profili Görüntüleyenler';

  @override
  String get noDataYet => 'Henüz veri yok';

  @override
  String get premiumSoon => 'Tümünü görmek için premium yakında ✨';

  @override
  String get unlockAll => 'Tümünü aç';

  @override
  String get justNow => 'az önce';

  @override
  String minutesAgo(Object count) {
    return '$count dk önce';
  }

  @override
  String hoursAgo(Object count) {
    return '$count sa önce';
  }

  @override
  String daysAgo(Object count) {
    return '$count gün önce';
  }

  @override
  String weeksAgo(Object count) {
    return '$count hf önce';
  }

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get privacySection => '🔒 Gizlilik ve Görünürlük';

  @override
  String get appearanceSection => '🎨 Görünüm';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get messagesFromEveryone => 'Herkesten Mesaj Al';

  @override
  String get messagesFromEveryoneDesc =>
      'Kapalı olduğunda yalnızca takip ettiklerinden mesaj alırsın.';

  @override
  String get showInSuggestions => 'Hesap Önerileri';

  @override
  String get showInSuggestionsDesc =>
      'Profilin önerilerde görünür. İstemiyorsan kapat.';

  @override
  String get followRequestsFromAll => 'Takip İstekleri (Herkesten)';

  @override
  String get followRequestsFromAllDesc =>
      'Kapalıysa yalnızca takip ettiklerin sana istek atabilir.';

  @override
  String get makeAccountPrivate => 'Hesabı Gizliye Al';

  @override
  String get makeAccountPrivateDesc => 'Hesabını gizlemek için aç.';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get darkModeDesc => 'Uygulama temasını gece moduna al.';

  @override
  String get deleteSurveyTitle => 'Hesabınızı neden silmek istiyorsunuz?';

  @override
  String get deleteReason1 => 'Uygulama beklentimi karşılamadı';

  @override
  String get deleteReason2 => 'Çok fazla bildirim alıyorum';

  @override
  String get deleteReason3 => 'Gizlilik endişeleri';

  @override
  String get deleteReason4 => 'Başka bir hesap kullanıyorum';

  @override
  String get deleteSurveyNote => 'Eklemek istediğiniz bir not?';

  @override
  String get confirmAndDelete => 'Onayla ve Hesabı Sil';

  @override
  String get accountNotDeleted => 'Hesap silinemedi. Lütfen tekrar deneyin.';

  @override
  String get dangerZoneTitle => 'Tehlikeli Bölge';

  @override
  String get dangerZoneDescription =>
      'Hesabını silersen tüm verilerin kalıcı olarak kaldırılır. Bu işlem geri alınamaz.';

  @override
  String get deleting => 'Siliniyor…';

  @override
  String get deleteSheetTitle => 'Hesabı Silmeden Önce';

  @override
  String get deleteWarning1 => 'Bu işlem kalıcıdır ve geri alınamaz.';

  @override
  String get deleteWarning2 => 'Profil ve ayarlar dahil tüm verilerin silinir.';

  @override
  String get deleteReasonOptional => 'Neden silmek istiyorsun? (opsiyonel)';

  @override
  String get deleteNoteLabel => 'Eklemek istediğin bir not var mı?';

  @override
  String get deleteNoteHint => 'Kısaca yazabilirsin…';

  @override
  String get deleteConfirmText =>
      'Eminim. Hesabımı kalıcı olarak silmek istiyorum.';

  @override
  String get reasonNotUsing => 'Uygulamayı artık kullanmıyorum';

  @override
  String get reasonPrivacy => 'Gizlilik/Veri endişeleri';

  @override
  String get reasonNotifications => 'Bildirimler rahatsız etti';

  @override
  String get reasonTechnical => 'Teknik sorunlar yaşadım';

  @override
  String get reasonOtherApp => 'Başka bir uygulamaya geçtim';

  @override
  String get reasonOther => 'Diğer';

  @override
  String get splashSubtitle => 'Seni bekleyen harika insanlar var!';

  @override
  String get interestYoga => 'Yoga';

  @override
  String get interestRunning => 'Koşu';

  @override
  String get interestSwimming => 'Yüzme';

  @override
  String get interestBasketball => 'Basketbol';

  @override
  String get interestFootball => 'Futbol';

  @override
  String get interestTennis => 'Tenis';

  @override
  String get interestCycling => 'Bisiklet Sürme';

  @override
  String get interestClimbing => 'Kaya Tırmanışı';

  @override
  String get interestHiking => 'Doğa Yürüyüşü';

  @override
  String get interestGym => 'Gym & Fitness';

  @override
  String get interestMartialArts => 'Dövüş Sanatları';

  @override
  String get interestGolf => 'Golf';

  @override
  String get interestVolleyball => 'Voleybol';

  @override
  String get interestSkiing => 'Kayak';

  @override
  String get interestSurfing => 'Sörf';

  @override
  String get confirm => 'Onayla';

  @override
  String get testNotificationTitle => 'Test Bildirimi';

  @override
  String get testNotificationBody => 'Bu bir yerel yedek';

  @override
  String get countryName => 'Türkiye';
}
