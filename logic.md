State Management & Logic Lead
Mimari Sorumluluk: Tüm özelliklerin BLoC / Cubit (Event ve State) sınıflarının yazılması, reaktif Firestore Stream dinleyicileri, kuruş hassasiyetli hesaplama mantıkları (KDV, Komisyon, Taksit, Bütçe yüzdeleri).
Yapacağı Klasör & Dosyalar:
BLoC / Cubit Sınıfları:
WalletBloc (Bakiye gizleme/gösterme, anlık bakiye stream'i)
FastTransferCubit (4 adımlı transfer state'i, günlük/aylık limit kontrolü, hızlı tutar ekleme +100, +250, Tüm Bakiye hesaplaması)
ExpenseApprovalBloc (Tekli onay/red ve Tümünü İncele & Toplu Onayla (₺3.890,50) mantığı, KDV indirimi +₺648,40 hesabı)
VirtualPosCubit (Tutar girişi, Tek Çekim / 3 Taksit / 6 Taksit seçimi, %1,39 işlem komisyonu ve Net Hesaba Geçecek: ₺3.697,88 anlık hesaplaması)
Kodlayacağı UI Ekranları:
expense_approval_center_screen.dart (Görsel 8 - Masraf Onay Merkezi): 3 Bekleyen sekmesi, ₺3.890,50 Bekleyen Toplam Tutar ve Tümünü İncele & Toplu Onayla butonu, Ahmet Yılmaz (AI-OCR %98 Doğrulandı), Elif Demir (Departman Temsil Limiti ₺2.000 Sınırında %99 Doluluk uyarısı) ve Caner Kılıç (CTO İmzalı Ön Onaylı) kartları ve Reddet / Onayla aksiyonları.
batch_approval_receipt_screen.dart (Görsel 6 - Toplu Onay Protokolü): 3 Masraf Başarıyla Onaylandı! ekranı, BATCH-EXP-2026-9941 işlem no, ERP & Muhasebe Entegrasyonu (Logo & Paraşüt - #MSF-88410) kartı, onaylanan 3 kalemin özeti ve en alttaki SHA-256 Blokzincir Zaman Damgası kutusu.