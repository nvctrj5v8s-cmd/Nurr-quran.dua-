import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ==================== DUA PAGE ====================
class DuaPage extends StatefulWidget {
  final Color themeColor;
  final String langCode;
  const DuaPage({super.key, required this.themeColor, required this.langCode});

  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'key': 'morning_duas', 'icon': '🌅', 'gradient': [Colors.orange.shade700, Colors.amber.shade500]},
    {'key': 'evening_duas', 'icon': '🌙', 'gradient': [Colors.deepPurple.shade700, Colors.purple.shade400]},
    {'key': 'leaving_home', 'icon': '🚪', 'gradient': [Colors.blue.shade700, Colors.cyan.shade500]},
    {'key': 'entering_home', 'icon': '🏠', 'gradient': [Colors.green.shade700, Colors.lightGreen.shade500]},
    {'key': 'before_sleep', 'icon': '😴', 'gradient': [Colors.indigo.shade800, Colors.blue.shade600]},
    {'key': 'after_wudu', 'icon': '💧', 'gradient': [Colors.teal.shade700, Colors.cyan.shade400]},
    {'key': 'before_exam', 'icon': '📚', 'gradient': [Colors.pink.shade700, Colors.red.shade400]},
    {'key': 'when_traveling', 'icon': '✈️', 'gradient': [Colors.lightBlue.shade700, Colors.blue.shade400]},
    {'key': 'when_sick', 'icon': '🤒', 'gradient': [Colors.deepOrange.shade700, Colors.orange.shade500]},
    {'key': 'for_parents', 'icon': '👪', 'gradient': [Colors.purple.shade700, Colors.pink.shade400]},
    {'key': 'seeking_knowledge', 'icon': '🎓', 'gradient': [Colors.cyan.shade700, Colors.teal.shade400]},
  ];

  final Map<String, List<Map<String, dynamic>>> duaData = {
    'morning_duas': [
      {
        'number': '1️⃣',
        'arabic': 'أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ',
        'transliteration': 'A\'udhu billahi minash-shaytanir-rajim',
        'german': 'Ich suche Zuflucht bei Allah vor dem verfluchten Satan',
        'english': 'I seek refuge with Allah from the accursed Satan',
        'source': 'Quran',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلاَّ بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        'transliteration': 'Allahu la ilaha illa huwa al-hayyul-qayyum, la ta\'khudhahu sinatun wa la nawm, lahu ma fis-samawati wa ma fil-ard, man dhal-ladhi yashfa\'u \'indahu illa bi-idhnih, ya\'lamu ma bayna aydihim wa ma khalfahum, wa la yuhituna bi-shay\'in min \'ilmihi illa bima sha\'a, wasi\'a kursiyyuhus-samawati wal-ard, wa la ya\'uduhu hifdhuhuma, wa huwal-\'aliyyul-\'adhim',
        'german': 'Allah - es gibt keinen Gott außer Ihm, dem Lebendigen, dem Beständigen. Ihn überkommt weder Schlummer noch Schlaf. Ihm gehört, was in den Himmeln und was auf der Erde ist. Wer ist es denn, der bei Ihm Fürsprache einlegen könnte außer mit Seiner Erlaubnis? Er weiß, was vor ihnen und was hinter ihnen liegt, während sie nichts von Seinem Wissen erfassen, außer was Er will. Sein Thron umfasst die Himmel und die Erde, und ihre Behütung beschwert Ihn nicht. Er ist der Erhabene und Allgewaltige.',
        'english': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Throne extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
        'source': 'Quran 2:255',
      },
      {
        'number': '3️⃣',
        'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        'transliteration': 'Qul huwa Allahu ahad, Allahus-samad, lam yalid wa lam yulad, wa lam yakun lahu kufuwan ahad',
        'german': 'Sprich: Er ist Allah, ein Einziger, Allah, der Absolute. Er zeugt nicht und ist nicht gezeugt worden, und Ihm ebenbürtig ist keiner.',
        'english': 'Say: He is Allah, the One, Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
        'source': 'Surah Al-Ikhlas',
      },
      {
        'number': '4️⃣',
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        'transliteration': 'Qul a\'udhu bi rabbil-falaq...',
        'german': 'Sprich: Ich nehme Zuflucht beim Herrn der Morgendämmerung vor dem Übel dessen, was Er erschaffen hat...',
        'english': 'Say: I seek refuge in the Lord of daybreak from the evil of that which He created...',
        'source': 'Surah Al-Falaq',
      },
      {
        'number': '5️⃣',
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
        'transliteration': 'Qul a\'udhu bi rabbin-nas...',
        'german': 'Sprich: Ich nehme Zuflucht beim Herrn der Menschen, dem König der Menschen, dem Gott der Menschen...',
        'english': 'Say: I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind...',
        'source': 'Surah An-Nas',
      },
      {
        'number': '6️⃣',
        'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ للهِ، وَالْحَمْدُ للهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ',
        'transliteration': 'Asbahna wa asbahal-mulku lillah...',
        'german': 'Wir haben den Morgen erreicht und die Herrschaft gehört Allah. Alles Lob gebührt Allah...',
        'english': 'We have reached the morning and the sovereignty belongs to Allah. All praise is for Allah...',
        'source': 'Muslim',
      },
      {
        'number': '7️⃣',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma anta rabbi la ilaha illa ant...',
        'german': 'O Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Du hast mich erschaffen und ich bin Dein Diener...',
        'english': 'O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant...',
        'source': 'Sayyid Al-Istighfar - Bukhari',
      },
      {
        'number': '8️⃣',
        'arabic': 'رَضِيتُ بِاللهِ رَبَّاً، وَبِالْإِسْلَامِ دِينَاً، وَبِمُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ نَبِيَّاً',
        'transliteration': 'Raditu billahi rabban, wa bil-Islami dinan, wa bi-Muhammadin nabiyyan',
        'german': 'Ich bin zufrieden mit Allah als Herrn, mit dem Islam als Religion und mit Muhammad als Propheten',
        'english': 'I am pleased with Allah as Lord, with Islam as religion, and with Muhammad as Prophet',
        'source': 'Abu Dawud',
      },
      {
        'number': '9️⃣',
        'arabic': 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        'transliteration': 'La ilaha illallahu wahdahu la sharika lah...',
        'german': 'Es gibt keinen Gott außer Allah allein, ohne Partner. Ihm gehört die Herrschaft und Ihm gebührt das Lob...',
        'english': 'There is no god but Allah alone, without partner. To Him belongs dominion and praise...',
        'source': 'Bukhari & Muslim',
        'times': '100',
      },
      {
        'number': '🔟',
        'arabic': 'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدَاً عَبْدُكَ وَرَسُولُكَ',
        'transliteration': 'Allahumma inni asbahtu ushhiduka...',
        'german': 'O Allah, ich bezeuge am Morgen vor Dir, den Trägern Deines Thrones, Deinen Engeln und all Deiner Schöpfung...',
        'english': 'O Allah, I have reached the morning and call on You, the bearers of Your Throne, Your angels...',
        'source': 'Abu Dawud',
        'times': '4',
      },
      {
        'number': '1️⃣1️⃣',
        'arabic': 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
        'transliteration': 'Allahumma ma asbaha bi min ni\'matin...',
        'german': 'O Allah, welche Gnade auch immer ich oder eines Deiner Geschöpfe am Morgen hat, so ist sie von Dir allein...',
        'english': 'O Allah, whatever blessing I or any of Your creation have received in the morning is from You alone...',
        'source': 'Abu Dawud & An-Nasa\'i',
      },
      {
        'number': '1️⃣2️⃣',
        'arabic': 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma \'afini fi badani...',
        'german': 'O Allah, gewähre mir Gesundheit in meinem Körper, in meinem Gehör, in meinem Sehvermögen...',
        'english': 'O Allah, grant me health in my body, in my hearing, in my sight...',
        'source': 'Abu Dawud',
        'times': '3',
      },
      {
        'number': '1️⃣3️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma inni a\'udhu bika minal-kufri wal-faqr...',
        'german': 'O Allah, ich suche Zuflucht bei Dir vor Unglauben und Armut, und ich suche Zuflucht bei Dir vor der Qual des Grabes...',
        'english': 'O Allah, I seek refuge with You from disbelief and poverty, and from the punishment of the grave...',
        'source': 'Abu Dawud',
        'times': '3',
      },
      {
        'number': '1️⃣4️⃣',
        'arabic': 'حَسْبِيَ اللهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        'transliteration': 'Hasbiyallahu la ilaha illa huwa \'alayhi tawakkaltu...',
        'german': 'Allah genügt mir, es gibt keinen Gott außer Ihm. Auf Ihn vertraue ich, und Er ist der Herr des gewaltigen Thrones.',
        'english': 'Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.',
        'source': 'Abu Dawud',
        'times': '7',
      },
      {
        'number': '1️⃣5️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
        'transliteration': 'Allahumma inni as\'alukal-\'afwa wal-\'afiyah...',
        'german': 'O Allah, ich bitte Dich um Vergebung und Wohlergehen in dieser Welt und im Jenseits...',
        'english': 'O Allah, I ask You for pardon and well-being in this world and the Hereafter...',
        'source': 'Abu Dawud & Ibn Majah',
      },
      {
        'number': '1️⃣6️⃣',
        'arabic': 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءَاً أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ',
        'transliteration': 'Allahumma \'alimal-ghaybi wash-shahadah...',
        'german': 'O Allah, Kenner des Verborgenen und Sichtbaren, Schöpfer der Himmel und der Erde...',
        'english': 'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth...',
        'source': 'At-Tirmidhi',
      },
      {
        'number': '1️⃣7️⃣',
        'arabic': 'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        'transliteration': 'Bismillahil-ladhi la yadurru ma\'as-mihi shay\'un...',
        'german': 'Im Namen Allahs, mit dessen Namen nichts auf Erden und im Himmel schaden kann, und Er ist der Allhörende, der Allwissende.',
        'english': 'In the Name of Allah with whose Name nothing on earth or in the heaven can cause harm, and He is the All-Hearing, All-Knowing.',
        'source': 'Abu Dawud & At-Tirmidhi',
        'times': '3',
      },
      {
        'number': '1️⃣8️⃣',
        'arabic': 'أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ، حَنِيفَاً مُسْلِمَاً، وَمَا كَانَ مِنَ الْمُشْرِكِينَ',
        'transliteration': 'Asbahna \'ala fitratil-Islam...',
        'german': 'Wir haben den Morgen in der natürlichen Veranlagung des Islam erreicht, mit dem Wort des reinen Glaubens...',
        'english': 'We have reached the morning upon the fitrah of Islam, and upon the word of sincere devotion...',
        'source': 'Ahmad',
      },
      {
        'number': '1️⃣9️⃣',
        'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
        'transliteration': 'Subhanallahi wa bihamdihi \'adada khalqihi...',
        'german': 'Preis sei Allah und Lob sei Ihm, entsprechend der Anzahl Seiner Schöpfung, Seiner Zufriedenheit...',
        'english': 'Glory is to Allah and praise is to Him, by the multitude of His creation, His pleasure...',
        'source': 'Muslim',
        'times': '3',
      },
      {
        'number': '2️⃣0️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمَاً نَافِعَاً، وَرِزْقَاً طَيِّبَاً، وَعَمَلَاً مُتَقَبَّلَاً',
        'transliteration': 'Allahumma inni as\'aluka \'ilman nafi\'an...',
        'german': 'O Allah, ich bitte Dich um nützliches Wissen, gute Versorgung und angenommene Taten.',
        'english': 'O Allah, I ask You for beneficial knowledge, good provision, and acceptable deeds.',
        'source': 'Ibn Majah',
      },
      {
        'number': '2️⃣1️⃣',
        'arabic': 'أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ',
        'transliteration': 'Astaghfirullaha wa atubu ilayh',
        'german': 'Ich bitte Allah um Vergebung und bereue zu Ihm.',
        'english': 'I seek forgiveness from Allah and repent to Him.',
        'source': 'Bukhari',
        'times': '100',
      },
      {
        'number': '2️⃣2️⃣',
        'arabic': 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
        'transliteration': 'Ya Hayyu ya Qayyum, bi-rahmatika astaghith...',
        'german': 'O Lebendiger, O Beständiger, durch Deine Barmherzigkeit rufe ich um Hilfe...',
        'english': 'O Ever-Living, O Sustainer, through Your mercy I seek help...',
        'source': 'An-Nasa\'i',
      },
      {
        'number': '2️⃣3️⃣',
        'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ للهِ رَبِّ الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذَا الْيَوْمِ: فَتْحَهُ، وَنَصْرَهُ، وَنُورَهُ، وَبَرَكَتَهُ، وَهُدَاهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِيهِ وَشَرِّ مَا بَعْدَهُ',
        'transliteration': 'Asbahna wa asbahal-mulku lillahi rabbil-\'alamin...',
        'german': 'Wir haben den Morgen erreicht und die Herrschaft gehört Allah, dem Herrn der Welten...',
        'english': 'We have reached the morning and the sovereignty belongs to Allah, Lord of the worlds...',
        'source': 'Abu Dawud',
      },
      {
        'number': '2️⃣4️⃣',
        'arabic': 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
        'transliteration': 'Allahumma bika asbahna wa bika amsayna...',
        'german': 'O Allah, mit Dir haben wir den Morgen erreicht, mit Dir erreichen wir den Abend, mit Dir leben wir, mit Dir sterben wir...',
        'english': 'O Allah, by You we have reached the morning, by You we reach the evening, by You we live, by You we die...',
        'source': 'At-Tirmidhi',
      },
      {
        'number': '2️⃣5️⃣',
        'arabic': 'اللَّهُمَّ أَنْتَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
        'transliteration': 'Allahumma anta khalaqta nafsi wa anta tawaffaha...',
        'german': 'O Allah, Du hast meine Seele erschaffen und Du nimmst sie zurück. Dir gehört ihr Tod und ihr Leben...',
        'english': 'O Allah, You have created my soul and You take it back. To You belongs its death and its life...',
        'source': 'Muslim',
      },
      {
        'number': '2️⃣6️⃣',
        'arabic': 'اللَّهُمَّ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، لَا إِلَهَ إِلَّا أَنْتَ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ',
        'transliteration': 'Allahumma fatiris-samawati wal-ard...',
        'german': 'O Allah, Schöpfer der Himmel und der Erde, Kenner des Verborgenen und Sichtbaren...',
        'english': 'O Allah, Creator of the heavens and the earth, Knower of the unseen and seen...',
        'source': 'At-Tirmidhi & Abu Dawud',
      },
      {
        'number': '2️⃣7️⃣',
        'arabic': 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        'transliteration': 'La ilaha illallahu wahdahu la sharika lahu...',
        'german': 'Es gibt keinen Gott außer Allah allein, ohne Partner. Ihm gehört die Herrschaft, Ihm gebührt das Lob. Er gibt Leben und Tod...',
        'english': 'There is no god but Allah alone with no partner. His is the dominion and to Him belongs all praise. He gives life and causes death...',
        'source': 'At-Tirmidhi',
        'times': '10',
      },
      {
        'number': '2️⃣8️⃣',
        'arabic': 'سُبْحَانَ اللهِ',
        'transliteration': 'SubhanAllah',
        'german': 'Preis sei Allah',
        'english': 'Glory be to Allah',
        'source': 'Daily Dhikr',
        'times': '33',
      },
      {
        'number': '2️⃣9️⃣',
        'arabic': 'الْحَمْدُ للهِ',
        'transliteration': 'Alhamdulillah',
        'german': 'Alles Lob gebührt Allah',
        'english': 'All praise is for Allah',
        'source': 'Daily Dhikr',
        'times': '33',
      },
      {
        'number': '3️⃣0️⃣',
        'arabic': 'اللهُ أَكْبَرُ',
        'transliteration': 'Allahu Akbar',
        'german': 'Allah ist der Größte',
        'english': 'Allah is the Greatest',
        'source': 'Daily Dhikr',
        'times': '34',
      },
      {
        'number': '3️⃣1️⃣',
        'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        'transliteration': 'Subhanallahi wa bihamdihi',
        'german': 'Preis sei Allah und Lob sei Ihm',
        'english': 'Glory be to Allah and praise be to Him',
        'source': 'Bukhari & Muslim',
        'times': '100',
      },
    ],
    'leaving_home': [
      {
        'number': '1️⃣',
        'arabic': 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        'transliteration': 'Bismillah, tawakkaltu \'alallah, wa la hawla wa la quwwata illa billah',
        'german': 'Im Namen Allahs. Ich vertraue auf Allah. Es gibt keine Kraft und keine Macht außer durch Allah.',
        'english': 'In the name of Allah. I place my trust in Allah. There is no power and no strength except through Allah.',
        'source': 'Abu Dawud & Tirmidhi',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أَضِلَّ أَوْ أُضَلَّ، أَوْ أَزِلَّ أَوْ أُزَلَّ، أَوْ أَظْلِمَ أَوْ أُظْلَمَ، أَوْ أَجْهَلَ أَوْ يُجْهَلَ عَلَيَّ',
        'transliteration': 'Allahumma inni a\'udhu bika an adilla aw udalla, aw azilla aw uzalla, aw adhlima aw udhlama, aw ajhala aw yujhala \'alayya',
        'german': 'Oh Allah, ich suche Zuflucht bei Dir davor, fehlzugehen oder andere fehlzuleiten, auszurutschen oder andere zum Ausrutschen zu bringen, Unrecht zu tun oder Unrecht zu erleiden, unwissend zu handeln oder unwissend behandelt zu werden.',
        'english': 'O Allah, I seek refuge in You from going astray or leading others astray, from slipping or causing others to slip, from committing injustice or having injustice committed against me, and from acting ignorantly or being treated ignorantly.',
        'source': 'Abu Dawud & Tirmidhi',
      },
    ],
    'entering_home': [
      {
        'number': '1️⃣',
        'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
        'transliteration': 'Bismillahi walajna, wa bismillahi kharajna, wa \'alallahi rabbina tawakkalna',
        'german': 'Im Namen Allahs treten wir ein, und im Namen Allahs gehen wir hinaus, und auf Allah, unseren Herrn, vertrauen wir.',
        'english': 'In the name of Allah we enter, and in the name of Allah we leave, and upon Allah, our Lord, we place our trust.',
        'source': 'Abu Dawud',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلَجِ وَخَيْرَ الْمَخْرَجِ، بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
        'transliteration': 'Allahumma inni as\'aluka khayral-mawlaji wa khayral-makhraji, bismillahi walajna, wa bismillahi kharajna, wa \'alallahi rabbina tawakkalna',
        'german': 'O Allah, ich bitte Dich um das Beste beim Eintreten und das Beste beim Verlassen. Im Namen Allahs treten wir ein, und im Namen Allahs gehen wir hinaus, und auf Allah, unseren Herrn, vertrauen wir.',
        'english': 'O Allah, I ask You for the best entering and the best leaving. In the name of Allah we enter, and in the name of Allah we leave, and upon Allah, our Lord, we place our trust.',
        'source': 'Abu Dawud',
      },
    ],
    'before_sleep': [
      {
        'number': '1️⃣',
        'arabic': 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، إِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
        'transliteration': 'Bismika rabbi wada\'tu janbi, wa bika arfa\'uh, in amsakta nafsi farhamha, wa in arsaltaha fahfadhha bima tahfadhu bihi \'ibadakas-salihin',
        'german': 'In Deinem Namen, mein Herr, lege ich meine Seite nieder, und durch Dich hebe ich sie wieder. Wenn Du meine Seele nimmst, erbarme Dich ihrer, und wenn Du sie zurücksendest, beschütze sie so, wie Du Deine rechtschaffenen Diener beschützt.',
        'english': 'In Your name, my Lord, I lie down, and in Your name I rise. If You take my soul, have mercy upon it, and if You return it, protect it as You protect Your righteous servants.',
        'source': 'Bukhari & Muslim',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
        'transliteration': 'Allahumma innaka khalaqta nafsi wa anta tawaffaha, laka mamatuha wa mahyaha, in ahyaytaha fahfadhha, wa in amattaha faghfir laha, allahumma inni as\'alukal-\'afiyah',
        'german': 'O Allah, Du hast meine Seele erschaffen und Du nimmst sie. Dir gehört ihr Tod und ihr Leben. Wenn Du sie am Leben erhältst, beschütze sie, und wenn Du sie sterben lässt, vergib ihr. O Allah, ich bitte Dich um Wohlbefinden.',
        'english': 'O Allah, You created my soul and You take it. To You belongs its death and its life. If You give it life, protect it, and if You cause it to die, forgive it. O Allah, I ask You for well-being.',
        'source': 'Muslim',
      },
      {
        'number': '3️⃣',
        'arabic': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        'transliteration': 'Allahumma qini \'adhabaka yawma tab\'athu \'ibadak',
        'german': 'O Allah, bewahre mich vor Deiner Strafe am Tag, an dem Du Deine Diener auferweckst.',
        'english': 'O Allah, protect me from Your punishment on the Day You resurrect Your servants.',
        'source': 'Abu Dawud & Tirmidhi',
        'times': '3',
      },
      {
        'number': '4️⃣',
        'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        'transliteration': 'Bismika Allahumma amutu wa ahya',
        'german': 'In Deinem Namen, O Allah, sterbe ich und lebe ich.',
        'english': 'In Your name, O Allah, I die and I live.',
        'source': 'Bukhari',
      },
      {
        'number': '5️⃣',
        'arabic': 'الْحَمْدُ للهِ الَّذِي أَطْعَمَنَا وَسَقَانَا، وَكَفَانَا، وَآوَانَا، فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِيَ',
        'transliteration': 'Alhamdulillahil-ladhi at\'amana wa saqana, wa kafana, wa awana, fakam mimman la kafiya lahu wa la mu\'wi',
        'german': 'Alles Lob gebührt Allah, Der uns speiste und tränkte, uns genügen ließ und uns Unterkunft gab. Wie viele gibt es, die niemanden haben, der ihnen genügt oder Unterkunft gibt.',
        'english': 'All praise is for Allah, Who fed us and gave us drink, and Who is sufficient for us and has sheltered us. How many have none to suffice them or shelter them.',
        'source': 'Muslim',
      },
      {
        'number': '6️⃣',
        'arabic': 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ، اللَّهُمَّ أَنْتَ الْأَوَّلُ فَلَيْسَ قَبْلَكَ شَيْءٌ، وَأَنْتَ الْآخِرُ فَلَيْسَ بَعْدَكَ شَيْءٌ، وَأَنْتَ الظَّاهِرُ فَلَيْسَ فَوْقَكَ شَيْءٌ، وَأَنْتَ الْبَاطِنُ فَلَيْسَ دُونَكَ شَيْءٌ، اقْضِ عَنَّا الدَّيْنَ وَأَغْنِنَا مِنَ الْفَقْرِ',
        'transliteration': 'Allahumma rabbas-samawatis-sab\'i wa rabbal-\'arshil-\'adhim, rabbana wa rabba kulli shay\', faliqal-habbi wan-nawa, wa munzilat-tawrati wal-injili wal-furqan, a\'udhu bika min sharri kulli shay\'in anta akhidhun binasiyatih, allahumma antal-awwalu falaysa qablaka shay\', wa antal-akhiru falaysa ba\'daka shay\', wa antadh-dhahiru falaysa fawqaka shay\', wa antal-batinu falaysa dunaka shay\', iqdi \'annad-dayna wa aghnina minal-faqr',
        'german': 'O Allah, Herr der sieben Himmel und Herr des gewaltigen Thrones, unser Herr und Herr aller Dinge, Spalter des Korns und der Dattelkerne, Herabsender der Tora, des Evangeliums und des Qurans, ich suche Zuflucht bei Dir vor dem Übel von allem, dessen Stirnlocke Du hältst. O Allah, Du bist der Erste, nichts war vor Dir, und Du bist der Letzte, nichts wird nach Dir sein, und Du bist der Offenbare, nichts ist über Dir, und Du bist der Verborgene, nichts ist näher als Du. Begleiche unsere Schulden und mache uns frei von Armut.',
        'english': 'O Allah, Lord of the seven heavens and Lord of the great Throne, our Lord and Lord of everything, Splitter of the grain and the date-stone, Revealer of the Torah, the Gospel and the Quran, I seek refuge in You from the evil of everything that You seize by the forelock. O Allah, You are the First, nothing is before You, and You are the Last, nothing is after You, and You are the Manifest, nothing is above You, and You are the Hidden, nothing is nearer than You. Settle our debt and make us free from poverty.',
        'source': 'Muslim',
      },
      {
        'number': '7️⃣',
        'arabic': 'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
        'transliteration': 'Allahumma aslamtu nafsi ilayk, wa fawwadtu amri ilayk, wa wajjahtu wajhi ilayk, wa alja\'tu dhahri ilayk, raghbatan wa rahbatan ilayk, la malja\'a wa la manja minka illa ilayk, amantu bikitabikal-ladhi anzalt, wa binabiyyikal-ladhi arsalt',
        'german': 'O Allah, ich übergebe mich Dir, vertraue Dir meine Angelegenheiten an, wende mein Gesicht Dir zu und lehne meinen Rücken an Dich an, aus Verlangen nach Dir und in Ehrfurcht vor Dir. Es gibt keine Zuflucht und keine Rettung vor Dir außer zu Dir. Ich glaube an Dein Buch, das Du herabgesandt hast, und an Deinen Propheten, den Du gesandt hast.',
        'english': 'O Allah, I submit myself to You, entrust my affairs to You, turn my face to You, and lay myself down depending upon You, hoping in You and fearing You. There is no refuge and no escape from You except to You. I believe in Your Book which You revealed, and Your Prophet whom You sent.',
        'source': 'Bukhari & Muslim',
      },
    ],
    'after_wudu': [
      {
        'number': '1️⃣',
        'arabic': 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        'transliteration': 'Ashhadu an la ilaha illallahu wahdahu la sharika lah, wa ashhadu anna Muhammadan \'abduhu wa rasuluh',
        'german': 'Ich bezeuge, dass es keinen Gott gibt außer Allah allein, ohne Partner, und ich bezeuge, dass Muhammad Sein Diener und Gesandter ist.',
        'english': 'I bear witness that there is no god but Allah alone, without partner, and I bear witness that Muhammad is His servant and Messenger.',
        'source': 'Muslim',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ، وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
        'transliteration': 'Allahummaj-\'alni minat-tawwabin, waj-\'alni minal-mutatahhirin',
        'german': 'O Allah, mache mich zu einem von denen, die bereuen, und zu einem von denen, die sich reinigen.',
        'english': 'O Allah, make me among those who repent, and make me among those who purify themselves.',
        'source': 'Tirmidhi',
      },
      {
        'number': '3️⃣',
        'arabic': 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
        'transliteration': 'Subhanaka Allahumma wa bihamdik, ashhadu an la ilaha illa ant, astaghfiruka wa atubu ilayk',
        'german': 'Gepriesen seist Du, O Allah, und aller Lobpreis gebührt Dir. Ich bezeuge, dass es keinen Gott gibt außer Dir. Ich bitte Dich um Vergebung und wende mich reuevoll Dir zu.',
        'english': 'Glory be to You, O Allah, and all praise is Yours. I bear witness that there is no god but You. I seek Your forgiveness and repent to You.',
        'source': 'An-Nasa\'i',
      },
    ],
    'evening_duas': [
      {
        'number': '1️⃣',
        'arabic': 'أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ',
        'transliteration': 'A\'udhu billahi minash-shaytanir-rajim',
        'german': 'Ich suche Zuflucht bei Allah vor dem verfluchten Satan.',
        'english': 'I seek refuge with Allah from the accursed Satan.',
        'source': 'Quran',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ، لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ، لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ، مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ، يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ، وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ، وَلَا يَئُودُهُ حِفْظُهُمَا، وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        'transliteration': 'Allahu la ilaha illa huwal-hayyul-qayyum, la ta\'khudhahu sinatun wa la nawm, lahu ma fis-samawati wa ma fil-ard, man dhal-ladhi yashfa\'u \'indahu illa bi-idhnih, ya\'lamu ma bayna aydihim wa ma khalfahum, wa la yuhituna bi-shay\'in min \'ilmihi illa bima sha\'a, wasi\'a kursiyyuhus-samawati wal-ard, wa la ya\'uduhu hifdhuhuma, wa huwal-\'aliyyul-\'adhim',
        'german': 'Allah – es gibt keinen Gott außer Ihm, dem Lebendigen, dem Beständigen. Ihn erfasst weder Schlummer noch Schlaf. Ihm gehört, was in den Himmeln und auf der Erde ist. Wer kann bei Ihm Fürsprache einlegen außer mit Seiner Erlaubnis? Er weiß, was vor ihnen und was hinter ihnen ist. Sie umfassen nichts von Seinem Wissen außer dem, was Er will. Sein Thron umfasst die Himmel und die Erde, und ihre Bewahrung ermüdet Ihn nicht. Und Er ist der Erhabene, der Gewaltige.',
        'english': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Throne extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
        'source': 'Quran 2:255',
      },
      {
        'number': '3️⃣',
        'arabic': 'آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ وَقَالُوا سَمِعْنَا وَأَطَعْنَا غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ. لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
        'transliteration': 'Amanar-rasulu bima unzila ilayhi min rabbihi wal-mu\'minun, kullun amana billahi wa mala\'ikatihi wa kutubihi wa rusulihi, la nufarriqu bayna ahadin min rusulihi, wa qalu sami\'na wa ata\'na ghufranaka rabbana wa ilaykal-masir. La yukallifullahu nafsan illa wus\'aha, laha ma kasabat wa \'alayha mak-tasabat, rabbana la tu\'akhidhna in nasina aw akhta\'na, rabbana wa la tahmil \'alayna isran kama hamaltahu \'alal-ladhina min qablina, rabbana wa la tuhammilna ma la taqata lana bih, wa\'fu \'anna waghfir lana warhamna, anta mawlana fansurna \'alal-qawmil-kafirin',
        'german': 'Der Gesandte glaubt an das, was zu ihm von seinem Herrn herabgesandt worden ist, und ebenso die Gläubigen. Alle glauben an Allah, Seine Engel, Seine Bücher und Seine Gesandten. Wir machen keinen Unterschied zwischen irgendeinem Seiner Gesandten. Und sie sagen: Wir hören und wir gehorchen. (Wir bitten um) Deine Vergebung, unser Herr, und zu Dir ist die Rückkehr. Allah belastet keine Seele über ihr Vermögen hinaus. Ihr steht zu, was sie erworben hat, und gegen sie ist, was sie erworben hat. Unser Herr, ziehe uns nicht zur Rechenschaft, wenn wir vergessen oder Fehler begehen. Unser Herr, und lege uns keine Bürde auf, wie Du sie denen vor uns auferlegt hast. Unser Herr, und belaste uns nicht mit dem, was wir nicht zu tragen vermögen. Und verzeihe uns, vergib uns und erbarme Dich unser. Du bist unser Schutzherr, so hilf uns gegen das ungläubige Volk.',
        'english': 'The Messenger has believed in what was revealed to him from his Lord, and so have the believers. All of them have believed in Allah and His angels and His books and His messengers, saying, "We make no distinction between any of His messengers." And they say, "We hear and we obey. We seek Your forgiveness, our Lord, and to You is the final destination." Allah does not charge a soul except with that within its capacity. It will have the consequence of what it has gained, and it will bear the consequence of what it has earned. Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us. Our Lord, and burden us not with that which we have no ability to bear. And pardon us, and forgive us, and have mercy upon us. You are our protector, so give us victory over the disbelieving people.',
        'source': 'Quran 2:285-286',
      },
      {
        'number': '4️⃣',
        'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ، اللَّهُ الصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
        'transliteration': 'Qul huwa Allahu ahad, Allahus-samad, lam yalid wa lam yulad, wa lam yakun lahu kufuwan ahad',
        'german': 'Sprich: Er ist Allah, der Eine. Allah, der Unabhängige. Er zeugt nicht und ist nicht gezeugt worden. Und keiner ist Ihm ebenbürtig.',
        'english': 'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
        'source': 'Surah Al-Ikhlas',
        'times': '3',
      },
      {
        'number': '5️⃣',
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، مِنْ شَرِّ مَا خَلَقَ، وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ، وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        'transliteration': 'Qul a\'udhu bi rabbil-falaq, min sharri ma khalaq, wa min sharri ghasiqin idha waqab, wa min sharrin-naffathati fil-\'uqad, wa min sharri hasidin idha hasad',
        'german': 'Sprich: Ich suche Zuflucht beim Herrn des Tagesanbruchs, vor dem Übel dessen, was Er erschaffen hat, vor dem Übel der Dunkelheit, wenn sie hereinbricht, vor dem Übel der Knotenanbläserinnen und vor dem Übel eines Neiders, wenn er neidet.',
        'english': 'Say: I seek refuge in the Lord of daybreak, from the evil of that which He created, and from the evil of darkness when it settles, and from the evil of the blowers in knots, and from the evil of an envier when he envies.',
        'source': 'Surah Al-Falaq',
        'times': '3',
      },
      {
        'number': '6️⃣',
        'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ، مَلِكِ النَّاسِ، إِلَٰهِ النَّاسِ، مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ، الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ، مِنَ الْجِنَّةِ وَالنَّاسِ',
        'transliteration': 'Qul a\'udhu bi rabbin-nas, malikin-nas, ilahin-nas, min sharril-waswasil-khannas, alladhi yuwaswisu fi sudurin-nas, minal-jinnati wan-nas',
        'german': 'Sprich: Ich suche Zuflucht beim Herrn der Menschen, dem König der Menschen, dem Gott der Menschen, vor dem Übel des Einflüsterers, der sich zurückzieht, der in die Herzen der Menschen einflüstert, sei er von den Dschinn oder von den Menschen.',
        'english': 'Say: I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind, from the evil of the retreating whisperer, who whispers into the breasts of mankind, from among the jinn and mankind.',
        'source': 'Surah An-Nas',
        'times': '3',
      },
      {
        'number': '7️⃣',
        'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ للهِ وَالْحَمْدُ للهِ، لَا إِلَٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَٰذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَٰذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
        'transliteration': 'Amsayna wa amsal-mulku lillah walhamdulillah, la ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu, wa huwa \'ala kulli shay\'in qadir, rabbi as\'aluka khayra ma fi hadhihil-laylati wa khayra ma ba\'daha, wa a\'udhu bika min sharri ma fi hadhihil-laylati wa sharri ma ba\'daha, rabbi a\'udhu bika minal-kasali wa su\'il-kibar, rabbi a\'udhu bika min \'adhabin fin-nari wa \'adhabin fil-qabr',
        'german': 'Wir haben den Abend erreicht, und das Königreich gehört Allah. Alles Lob gebührt Allah. Es gibt keinen Gott außer Allah allein, ohne Teilhaber. Ihm gehört die Herrschaft und Ihm gehört der Lobpreis, und Er hat Macht über alle Dinge. Mein Herr, ich bitte Dich um das Gute dieser Nacht und das Gute danach, und ich suche Zuflucht bei Dir vor dem Übel dieser Nacht und dem Übel danach. Mein Herr, ich suche Zuflucht bei Dir vor Trägheit und vor schlechtem Altern. Mein Herr, ich suche Zuflucht bei Dir vor einer Strafe im Feuer und vor der Strafe im Grab.',
        'english': 'We have reached the evening and the sovereignty belongs to Allah. All praise is for Allah. There is no god but Allah alone, without partner. To Him belongs dominion and praise, and He has power over all things. My Lord, I ask You for the good of this night and the good that follows it, and I seek refuge in You from the evil of this night and the evil that follows it. My Lord, I seek refuge in You from laziness and from bad old age. My Lord, I seek refuge in You from punishment in the Fire and punishment in the grave.',
        'source': 'Muslim',
      },
      {
        'number': '8️⃣',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma anta rabbi la ilaha illa ant, khalaqtani wa ana \'abduk, wa ana \'ala \'ahdika wa wa\'dika mas-tata\'t, a\'udhu bika min sharri ma sana\'t, abu\'u laka bini\'matika \'alayya wa abu\'u bidhanbi faghfir li fa\'innahu la yaghfirudh-dhunuba illa ant',
        'german': 'O Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Du hast mich erschaffen und ich bin Dein Diener. Ich halte an Deinem Bund und Deinem Versprechen fest, so gut ich kann. Ich suche Zuflucht bei Dir vor dem Übel dessen, was ich getan habe. Ich erkenne Deine Gnade an mir an und ich bekenne meine Sünde. So vergib mir, denn niemand vergibt die Sünden außer Dir.',
        'english': 'O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant. I abide by Your covenant and promise as much as I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me and I acknowledge my sin, so forgive me, for verily none can forgive sins except You.',
        'source': 'Sayyid Al-Istighfar - Bukhari',
      },
      {
        'number': '9️⃣',
        'arabic': 'رَضِيتُ بِاللهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا وَرَسُولًا',
        'transliteration': 'Raditu billahi rabban, wa bil-Islami dinan, wa bi-Muhammadin sallallahu \'alayhi wa sallama nabiyyan wa rasulan',
        'german': 'Ich bin zufrieden mit Allah als meinem Herrn, mit dem Islam als meiner Religion und mit Muhammad ﷺ als Propheten und Gesandten.',
        'english': 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad ﷺ as a Prophet and Messenger.',
        'source': 'Abu Dawud & Tirmidhi',
        'times': '3',
      },
      {
        'number': '🔟',
        'arabic': 'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللهُ لَا إِلَٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ سَيِّدَنَا مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
        'transliteration': 'Allahumma inni amsaytu ushhiduk, wa ushhidu hamalata \'arshik, wa mala\'ikatak, wa jami\'a khalqik, annaka antallahu la ilaha illa anta wahdaka la sharika lak, wa anna sayyidana Muhammadan \'abduka wa rasuluk',
        'german': 'O Allah, wahrlich, ich habe den Abend erreicht und nehme Dich zum Zeugen, und ich nehme die Träger Deines Thrones, Deine Engel und die gesamte Schöpfung zu Zeugen, dass Du Allah bist: Es gibt keinen Gott außer Dir allein, ohne Teilhaber, und dass unser Herr Muhammad Dein Diener und Dein Gesandter ist.',
        'english': 'O Allah, I have reached the evening and call on You, the bearers of Your Throne, Your angels, and all of Your creation to witness that You are Allah: None has the right to be worshipped except You, alone, without partner, and that Muhammad is Your servant and Messenger.',
        'source': 'Abu Dawud',
        'times': '4',
      },
      {
        'number': '1️⃣1️⃣',
        'arabic': 'اللَّهُمَّ مَا أَمْسَىٰ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
        'transliteration': 'Allahumma ma amsa bi min ni\'matin aw bi-ahadin min khalqika faminka wahdaka la sharika lak, falakal-hamdu wa lakash-shukr',
        'german': 'O Allah, jede Gnade, die mich oder eines Deiner Geschöpfe am Abend erreicht hat, stammt allein von Dir. Dir gebührt aller Lobpreis und aller Dank.',
        'english': 'O Allah, whatever blessing I or any of Your creation have received in the evening is from You alone, without partner, so to You belongs all praise and all thanks.',
        'source': 'Abu Dawud & An-Nasa\'i',
      },
      {
        'number': '1️⃣2️⃣',
        'arabic': 'حَسْبِيَ اللهُ لَا إِلَٰهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        'transliteration': 'Hasbiyallahu la ilaha illa huwa, \'alayhi tawakkaltu wa huwa rabbul-\'arshil-\'adhim',
        'german': 'Allah genügt mir. Es gibt keinen Gott außer Ihm. Auf Ihn vertraue ich, und Er ist der Herr des gewaltigen Thrones.',
        'english': 'Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.',
        'source': 'Abu Dawud',
        'times': '7',
      },
      {
        'number': '1️⃣3️⃣',
        'arabic': 'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        'transliteration': 'Bismillahil-ladhi la yadurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-sami\'ul-\'alim',
        'german': 'Im Namen Allahs, bei dessen Namen nichts auf der Erde und im Himmel schadet, und Er ist der Allhörende, der Allwissende.',
        'english': 'In the name of Allah with whose name nothing is harmed on earth nor in the heavens, and He is the All-Hearing, the All-Knowing.',
        'source': 'Abu Dawud & Tirmidhi',
        'times': '3',
      },
      {
        'number': '1️⃣4️⃣',
        'arabic': 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
        'transliteration': 'Allahumma bika amsayna wa bika asbahna wa bika nahya wa bika namutu wa ilaykal-masir',
        'german': 'O Allah, durch Dich erreichen wir den Abend, durch Dich erreichen wir den Morgen, durch Dich leben wir und durch Dich sterben wir, und zu Dir ist die Rückkehr.',
        'english': 'O Allah, by You we reach the evening, by You we reach the morning, by You we live, by You we die, and to You is the return.',
        'source': 'Abu Dawud & Tirmidhi',
      },
      {
        'number': '1️⃣5️⃣',
        'arabic': 'أَمْسَيْنَا عَلَىٰ فِطْرَةِ الْإِسْلَامِ، وَعَلَىٰ كَلِمَةِ الْإِخْلَاصِ، وَعَلَىٰ دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَىٰ مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ',
        'transliteration': 'Amsayna \'ala fitratil-Islam, wa \'ala kalimatul-ikhlas, wa \'ala dini nabiyyina Muhammadin sallallahu \'alayhi wa sallam, wa \'ala millati abina Ibrahima hanifan musliman wa ma kana minal-mushrikin',
        'german': 'Wir haben den Abend auf der natürlichen Veranlagung des Islam erreicht, auf dem Wort der Aufrichtigkeit, auf der Religion unseres Propheten Muhammad ﷺ und auf der Gemeinschaft unseres Vaters Ibrahim.',
        'english': 'We have reached the evening upon the natural religion of Islam, and upon the word of sincere devotion, and upon the religion of our Prophet Muhammad ﷺ, and upon the religion of our father Ibrahim, inclining toward truth, and he was not of the polytheists.',
        'source': 'Ahmad',
      },
      {
        'number': '1️⃣6️⃣',
        'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ',
        'transliteration': 'Subhanallahi wa bihamdihi, \'adada khalqih, wa rida nafsih, wa zinata \'arshih, wa midada kalimatih',
        'german': 'Gepriesen ist Allah und alles Lob gebührt Ihm, entsprechend der Anzahl Seiner Schöpfung, dem Wohlgefallen Seiner Selbst, dem Gewicht Seines Thrones und der Fülle Seiner Worte.',
        'english': 'Glory be to Allah and praise Him, by the number of His creation, by His pleasure, by the weight of His Throne, and by the ink of His words.',
        'source': 'Muslim',
        'times': '3',
      },
      {
        'number': '1️⃣7️⃣',
        'arabic': 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ',
        'transliteration': 'Allahumma \'afini fi badani, allahumma \'afini fi sam\'i, allahumma \'afini fi basari, la ilaha illa ant',
        'german': 'O Allah, schenke mir Gesundheit in meinem Körper, in meinem Gehör und in meinem Sehvermögen. Es gibt keinen Gott außer Dir.',
        'english': 'O Allah, grant me health in my body, in my hearing, and in my sight. There is no deity except You.',
        'source': 'Abu Dawud',
        'times': '3',
      },
      {
        'number': '1️⃣8️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَنْ يَمِينِي وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
        'transliteration': 'Allahumma inni as\'alukal-\'afwa wal-\'afiyah fid-dunya wal-akhirah, allahumma inni as\'alukal-\'afwa wal-\'afiyah fi dini wa dunyaya wa ahli wa mali, allahummast-ur \'awrati wa amin raw\'ati, allahummahf-adhni min bayni yadayya wa min khalfi wa \'an yamini wa \'an shimali, wa min fawqi, wa a\'udhu bi\'adhamatika an ughtala min tahti',
        'german': 'O Allah, ich bitte Dich um Vergebung und Wohlergehen im Diesseits und im Jenseits. O Allah, ich bitte Dich um Vergebung und Wohlergehen in meiner Religion, in meinem weltlichen Leben, bei meiner Familie und in meinem Besitz. O Allah, bedecke meine Fehler und schenke mir Sicherheit vor meinen Ängsten. O Allah, bewahre mich von vorne und von hinten, von meiner Rechten und von meiner Linken und von oben. Und ich suche Zuflucht bei Deiner Erhabenheit davor, dass ich von unten her zugrunde gehe.',
        'english': 'O Allah, I ask You for pardon and well-being in this world and the Hereafter. O Allah, I ask You for pardon and well-being in my religion and my worldly affairs, in my family and my wealth. O Allah, veil my weaknesses and set at ease my dismay. O Allah, preserve me from the front and from behind, from my right and from my left, and from above, and I take refuge with Your greatness lest I be swallowed up by the earth.',
        'source': 'Abu Dawud & Ibn Majah',
      },
      {
        'number': '1️⃣9️⃣',
        'arabic': 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
        'transliteration': 'Ya Hayyu Ya Qayyumu birahmatika astaghith, aslih li sha\'ni kullah, wa la takilni ila nafsi tarfata \'ayn',
        'german': 'O Du Lebendiger, o Du Beständiger, durch Deine Barmherzigkeit suche ich Hilfe. Ordne mir all meine Angelegenheiten und überlasse mich nicht mir selbst, auch nicht für einen Augenblick.',
        'english': 'O Ever-Living, O Self-Subsisting Sustainer! By Your mercy I seek help. Rectify for me all of my affairs, and do not leave me to myself even for the blink of an eye.',
        'source': 'An-Nasa\'i',
        'times': '3',
      },
      {
        'number': '2️⃣0️⃣',
        'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ للهِ رَبِّ الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَٰذِهِ اللَّيْلَةِ فَتْحَهَا وَنَصْرَهَا، وَنُورَهَا وَبَرَكَتَهَا، وَهُدَاهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِيهَا وَشَرِّ مَا بَعْدَهَا',
        'transliteration': 'Amsayna wa amsal-mulku lillahi rabbil-\'alamin, allahumma inni as\'aluka khayra hadhihil-laylati fat-haha wa nasraha, wa nuraha wa barakataha, wa hudaha, wa a\'udhu bika min sharri ma fiha wa sharri ma ba\'daha',
        'german': 'Wir haben den Abend erreicht, und die Herrschaft gehört Allah, dem Herrn der Welten. O Allah, ich bitte Dich um das Gute dieser Nacht: ihren Erfolg, ihren Sieg, ihr Licht, ihren Segen und ihre Rechtleitung. Und ich suche Zuflucht bei Dir vor dem Übel dessen, was in ihr ist, und vor dem Übel dessen, was nach ihr kommt.',
        'english': 'We have reached the evening and the sovereignty belongs to Allah, Lord of the worlds. O Allah, I ask You for the good of this night: its opening, its victory, its light, its blessing, and its guidance. And I seek refuge in You from the evil that is in it and the evil that comes after it.',
        'source': 'Abu Dawud',
      },
      {
        'number': '2️⃣1️⃣',
        'arabic': 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَىٰ نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَىٰ مُسْلِمٍ',
        'transliteration': 'Allahumma \'alimal-ghaybi wash-shahadati fatiras-samawati wal-ard, rabba kulli shay\'in wa malikah, ashhadu an la ilaha illa ant, a\'udhu bika min sharri nafsi wa min sharrish-shaytani wa shirkih, wa an aqtarifa \'ala nafsi su\'an aw ajurrahu ila muslim',
        'german': 'O Allah, Du Kenner des Verborgenen und des Offenbaren, Schöpfer der Himmel und der Erde, Herr und Besitzer aller Dinge. Ich bezeuge, dass es keinen Gott gibt außer Dir. Ich suche Zuflucht bei Dir vor dem Übel meiner eigenen Seele und vor dem Übel des Satans und seinem Beigesellen (seiner Verführung), und davor, dass ich mir selbst Böses zufüge oder es auf einen Muslim übertrage.',
        'english': 'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth, Lord and Sovereign of all things. I bear witness that there is no deity except You. I seek refuge in You from the evil of my soul, from the evil of Satan and his association (polytheism), and from committing evil upon myself or bringing it upon a Muslim.',
        'source': 'At-Tirmidhi',
      },
      {
        'number': '2️⃣2️⃣',
        'arabic': 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        'transliteration': 'A\'udhu bikalimatiallahit-tammati min sharri ma khalaq',
        'german': 'Ich suche Zuflucht bei den vollkommenen Worten Allahs vor dem Übel dessen, was Er erschaffen hat.',
        'english': 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
        'source': 'Muslim',
        'times': '3',
      },
      {
        'number': '2️⃣3️⃣',
        'arabic': 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَىٰ سَيِّدِنَا مُحَمَّدٍ',
        'transliteration': 'Allahumma salli wa sallim wa barik \'ala sayyidina Muhammad',
        'german': 'O Allah, sende Deinen Segen, Deinen Frieden und Deinen Segen (Baraka) auf unseren Herrn Muhammad.',
        'english': 'O Allah, send blessings, peace and blessings upon our master Muhammad.',
        'source': 'Various',
        'times': '10',
      },
      {
        'number': '2️⃣4️⃣',
        'arabic': 'اللَّهُمَّ إِنَّا نَعُوذُ بِكَ مِنْ أَنْ نُشْرِكَ بِكَ شَيْئًا نَعْلَمُهُ، وَنَسْتَغْفِرُكَ لِمَا لَا نَعْلَمُهُ',
        'transliteration': 'Allahumma inna na\'udhu bika min an nushrika bika shay\'an na\'lamuh, wa nastaghfiruka lima la na\'lamuh',
        'german': 'O Allah, wir suchen Zuflucht bei Dir davor, Dir wissentlich etwas beizugesellen, und wir bitten Dich um Vergebung für das, was wir nicht wissen.',
        'english': 'O Allah, we seek refuge in You from knowingly associating anything with You, and we seek Your forgiveness for what we do not know.',
        'source': 'Ahmad',
        'times': '3',
      },
      {
        'number': '2️⃣5️⃣',
        'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ، وَقَهْرِ الرِّجَالِ',
        'transliteration': 'Allahumma inni a\'udhu bika minal-hammi wal-hazan, wa a\'udhu bika minal-\'ajzi wal-kasal, wa a\'udhu bika minal-jubni wal-bukhl, wa a\'udhu bika min ghalabatid-dayni wa qahrir-rijal',
        'german': 'O Allah, ich suche Zuflucht bei Dir vor Sorge und Traurigkeit, und ich suche Zuflucht bei Dir vor Unfähigkeit und Trägheit, und ich suche Zuflucht bei Dir vor Feigheit und Geiz, und ich suche Zuflucht bei Dir vor der Übermacht der Schulden und vor der Unterdrückung durch Menschen.',
        'english': 'O Allah, I seek refuge in You from anxiety and sorrow, from weakness and laziness, from miserliness and cowardice, from being overcome by debt and from being overpowered by men.',
        'source': 'Bukhari',
        'times': '3',
      },
      {
        'number': '2️⃣6️⃣',
        'arabic': 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ، الْحَيُّ الْقَيُّومُ، وَأَتُوبُ إِلَيْهِ',
        'transliteration': 'Astaghfirullaha al-\'adhimal-ladhi la ilaha illa huwal-hayyul-qayyum, wa atubu ilayh',
        'german': 'Ich bitte Allah, den Erhabenen, um Vergebung – denn es gibt keinen Gott außer Ihm, dem Lebendigen, dem Beständigen – und ich wende mich reumütig zu Ihm zurück.',
        'english': 'I seek forgiveness from Allah the Magnificent, whom there is no deity except Him, the Ever-Living, the Sustainer of existence, and I repent to Him.',
        'source': 'Abu Dawud & Tirmidhi',
        'times': '3',
      },
      {
        'number': '2️⃣7️⃣',
        'arabic': 'يَا رَبِّ، لَكَ الْحَمْدُ كَمَا يَنْبَغِي لِجَلَالِ وَجْهِكَ، وَلِعَظِيمِ سُلْطَانِكَ',
        'transliteration': 'Ya Rabbi, lakal-hamdu kama yanbaghi lijalali wajhik, wa li\'adhimi sultanik',
        'german': 'O mein Herr, Dir gebührt aller Lobpreis, so wie es der Erhabenheit Deines Angesichts und der Größe Deiner Macht entspricht.',
        'english': 'O my Lord, to You belongs all praise as befits the majesty of Your Countenance and the greatness of Your Sovereignty.',
        'source': 'Ibn Majah',
        'times': '3',
      },
      {
        'number': '2️⃣8️⃣',
        'arabic': 'لَا إِلَٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
        'transliteration': 'La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu wa huwa \'ala kulli shay\'in qadir',
        'german': 'Es gibt keinen Gott außer Allah allein, ohne Teilhaber. Ihm gehört die Herrschaft und Ihm gebührt aller Lobpreis, und Er hat Macht über alle Dinge.',
        'english': 'There is no deity except Allah, alone, without partner. To Him belongs dominion and to Him belongs all praise, and He is over all things competent.',
        'source': 'Bukhari & Muslim',
        'times': '10',
      },
      {
        'number': '2️⃣9️⃣',
        'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، عَلَيْكَ تَوَكَّلْتُ، وَأَنْتَ رَبُّ الْعَرْشِ الْعَظِيمِ. مَا شَاءَ اللهُ كَانَ، وَمَا لَمْ يَشَأْ لَمْ يَكُنْ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ الْعَلِيِّ الْعَظِيمِ، أَعْلَمُ أَنَّ اللهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، وَأَنَّ اللهَ قَدْ أَحَاطَ بِكُلِّ شَيْءٍ عِلْمًا، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ كُلِّ دَابَّةٍ أَنْتَ آخِذٌ بِنَاصِيَتِهَا، إِنَّ رَبِّي عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ',
        'transliteration': 'Allahumma anta rabbi la ilaha illa ant, \'alayka tawakkaltu, wa anta rabbul-\'arshil-\'adhim. Ma sha\'allahu kan, wa ma lam yasha\' lam yakun, wa la hawla wa la quwwata illa billahil-\'aliyyil-\'adhim, a\'lamu annallaha \'ala kulli shay\'in qadir, wa annallaha qad ahata bikulli shay\'in \'ilma, allahumma inni a\'udhu bika min sharri nafsi, wa min sharri kulli dabbatin anta akhidhun binasiyatiha, inna rabbi \'ala siratin mustaqim',
        'german': 'Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Auf Dich habe ich mein Vertrauen gesetzt, und Du bist der Herr des gewaltigen Thrones. Was Allah will, geschieht, und was Er nicht will, geschieht nicht. Es gibt keine Macht und keine Kraft außer bei Allah, dem Erhabenen, dem Allgewaltigen. Ich weiß, dass Allah zu allem fähig ist und dass Allah alles mit Seinem Wissen umfasst hat. O Allah, ich suche Zuflucht bei Dir vor dem Übel meiner eigenen Seele und vor dem Übel jedes Lebewesens, dessen Schopf Du in Deiner Hand hältst. Wahrlich, mein Herr ist auf einem geraden Weg.',
        'english': 'O Allah, You are my Lord; there is no deity except You. Upon You I have relied, and You are the Lord of the Great Throne. What Allah wills will be, and what He does not will shall not be. There is no power and no strength except with Allah, the Most High, the Most Great. I know that Allah is over all things competent, and that Allah has encompassed all things in knowledge. O Allah, I seek refuge in You from the evil of my soul, and from the evil of every creature You are holding by the forelock. Indeed, my Lord is on a straight path.',
        'source': 'Abu Dawud',
      },
      {
        'number': '3️⃣0️⃣',
        'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        'transliteration': 'Subhanallahi wa bihamdih',
        'german': 'Gepriesen ist Allah, und alles Lob gebührt Ihm.',
        'english': 'Glory be to Allah and praise Him.',
        'source': 'Bukhari & Muslim',
        'times': '100',
      },
    ],
    'before_exam': [
      {
        'number': '1️⃣',
        'arabic': 'اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا',
        'transliteration': 'Allahumma la sahla illa ma ja\'altahu sahlan, wa anta taj\'alul-hazna idha shi\'ta sahlan',
        'german': 'O Allah, nichts ist einfach außer dem, was Du einfach machst, und Du machst das Schwierige einfach, wenn Du willst.',
        'english': 'O Allah, nothing is easy except what You make easy, and You make the difficult easy if You wish.',
        'source': 'Ibn Hibban',
      },
      {
        'number': '2️⃣',
        'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي، وَيَسِّرْ لِي أَمْرِي، وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي، يَفْقَهُوا قَوْلِي',
        'transliteration': 'Rabbish-rah li sadri, wa yassir li amri, wahlul \'uqdatan min lisani, yafqahu qawli',
        'german': 'Mein Herr, erweitere mir meine Brust, und erleichtere mir meine Angelegenheit, und löse den Knoten in meiner Zunge, damit sie meine Rede verstehen.',
        'english': 'My Lord, expand for me my breast, and ease for me my task, and untie the knot from my tongue, that they may understand my speech.',
        'source': 'Quran 20:25-28',
      },
    ],
    'when_traveling': [
      {
        'number': '1️⃣',
        'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
        'transliteration': 'Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila rabbina lamunqalibun',
        'german': 'Gepriesen sei Der, Der uns dies dienstbar gemacht hat, und wir hätten es nicht selbst bezwingen können, und wir werden sicherlich zu unserem Herrn zurückkehren.',
        'english': 'Glory be to Him Who has subjected this to us, and we could never have it by our efforts. And to our Lord, surely, we are to return.',
        'source': 'Quran 43:13-14',
      },
    ],
    'when_sick': [
      {
        'number': '1️⃣',
        'arabic': 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
        'transliteration': 'Allahumma rabban-nas, adh-hibil-ba\'s, ishfi antash-shafi, la shifa\'a illa shifa\'uk, shifa\'an la yughadiru saqaman',
        'german': 'O Allah, Herr der Menschen, beseitige das Leiden. Heile, denn Du bist der Heiler. Es gibt keine Heilung außer Deiner Heilung, eine Heilung, die keine Krankheit zurücklässt.',
        'english': 'O Allah, Lord of mankind, remove the hardship. Heal, for You are the Healer. There is no healing except Your healing, a healing that leaves no illness.',
        'source': 'Bukhari & Muslim',
      },
    ],
    'for_parents': [
      {
        'number': '1️⃣',
        'arabic': 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
        'transliteration': 'Rabbir-hamhuma kama rabbayani saghira',
        'german': 'Mein Herr, erbarme Dich ihrer, so wie sie mich aufzogen, als ich klein war.',
        'english': 'My Lord, have mercy upon them as they brought me up when I was small.',
        'source': 'Quran 17:24',
      },
      {
        'number': '2️⃣',
        'arabic': 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
        'transliteration': 'Rabbanagh-fir li wa li-walidayya wa lil-mu\'minina yawma yaqumal-hisab',
        'german': 'Unser Herr, vergib mir und meinen Eltern und den Gläubigen am Tag, da die Abrechnung stattfindet.',
        'english': 'Our Lord, forgive me and my parents and the believers the Day the account is established.',
        'source': 'Quran 14:41',
      },
    ],
    'seeking_knowledge': [
      {
        'number': '1️⃣',
        'arabic': 'رَبِّ زِدْنِي عِلْمًا',
        'transliteration': 'Rabbi zidni \'ilma',
        'german': 'Mein Herr, mehre mein Wissen.',
        'english': 'My Lord, increase me in knowledge.',
        'source': 'Quran 20:114',
      },
      {
        'number': '2️⃣',
        'arabic': 'اللَّهُمَّ انْفَعْنِي بِمَا عَلَّمْتَنِي، وَعَلِّمْنِي مَا يَنْفَعُنِي، وَزِدْنِي عِلْمًا',
        'transliteration': 'Allahumman-fa\'ni bima \'allamtani, wa \'allimni ma yanfa\'uni, wa zidni \'ilma',
        'german': 'O Allah, lass mich von dem profitieren, was Du mich gelehrt hast, lehre mich, was mir nützt, und mehre mein Wissen.',
        'english': 'O Allah, benefit me with what You have taught me, teach me what will benefit me, and increase me in knowledge.',
        'source': 'Ibn Majah',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    if (selectedCategory == null) {
      return _buildCategoryGrid();
    } else {
      return _buildDuaList();
    }
  }

  String _translate(String key) {
    const map = {
      'dua': {'de': 'Dua', 'en': 'Dua', 'ar': 'الدعاء'},
      'morning_duas': {'de': 'Morgen-Duas', 'en': 'Morning Duas', 'ar': 'أذكار الصباح'},
      'evening_duas': {'de': 'Abend-Duas', 'en': 'Evening Duas', 'ar': 'أذكار المساء'},
      'leaving_home': {'de': 'Beim Verlassen des Hauses', 'en': 'Leaving Home', 'ar': 'دعاء الخروج من المنزل'},
      'entering_home': {'de': 'Beim Betreten des Hauses', 'en': 'Entering Home', 'ar': 'دعاء دخول المنزل'},
      'before_sleep': {'de': 'Vor dem Schlafen', 'en': 'Before Sleep', 'ar': 'دعاء قبل النوم'},
      'after_wudu': {'de': 'Nach Wudu', 'en': 'After Wudu', 'ar': 'دعاء بعد الوضوء'},
      'before_exam': {'de': 'Vor Prüfungen', 'en': 'Before Exams', 'ar': 'دعاء قبل الامتحان'},
      'when_traveling': {'de': 'Auf Reisen', 'en': 'When Traveling', 'ar': 'دعاء السفر'},
      'when_sick': {'de': 'Bei Krankheit', 'en': 'When Sick', 'ar': 'دعاء المرض'},
      'for_parents': {'de': 'Für Eltern', 'en': 'For Parents', 'ar': 'دعاء للوالدين'},
      'seeking_knowledge': {'de': 'Wissen suchen', 'en': 'Seeking Knowledge', 'ar': 'دعاء طلب العلم'},
      'times': {'de': 'Mal', 'en': 'times', 'ar': 'مرات'},
    };

    final langMap = map[key];
    if (langMap == null) {
      return key;
    }
    return langMap[widget.langCode] ?? langMap['en'] ?? key;
  }

  Widget _buildCategoryGrid() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          _translate('dua'),
          style: TextStyle(
            color: widget.themeColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey.shade900],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = cat['key'] as String;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cat['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (cat['gradient'] as List<Color>)[0].withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat['icon'] as String,
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _translate(cat['key'] as String),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDuaList() {
    final duas = duaData[selectedCategory] ?? [];
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedCategory = null;
            });
          },
        ),
        title: Text(
          _translate(selectedCategory!),
          style: TextStyle(
            color: widget.themeColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.grey.shade900],
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: duas.length,
            itemBuilder: (context, index) {
              final dua = duas[index];
              return _buildDuaCard(dua);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDuaCard(Map<String, dynamic> dua) {
    final translation = widget.langCode == 'de' 
        ? dua['german'] 
        : (widget.langCode == 'ar' ? dua['arabic'] : dua['english']);
    
    final showTimes = dua.containsKey('times');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeColor.withOpacity(0.15),
            Colors.black.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.themeColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number and Source Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dua['number'],
                  style: const TextStyle(fontSize: 32),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.themeColor, width: 1),
                  ),
                  child: Text(
                    dua['source'],
                    style: TextStyle(
                      color: widget.themeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Arabic Text
            Text(
              dua['arabic'],
              textAlign: TextAlign.right,
              style: GoogleFonts.amiriQuran(
                fontSize: 24,
                color: Colors.white,
                height: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            // Divider
            Divider(color: widget.themeColor.withOpacity(0.3), thickness: 1),
            const SizedBox(height: 15),
            // Transliteration
            Text(
              dua['transliteration'],
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Translation
            Text(
              translation,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.6,
              ),
            ),
            // Times to recite
            if (showTimes) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade700, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔄', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '${dua['times']}x ${_translate('times')}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
