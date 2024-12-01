(:26:)(:
for $k in doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/swiat.xml')
/SWIAT/KONTYNENTY/KONTYNENT
return <KRAJ>
{$k/NAZWA, $k/STOLICA}
</KRAJ> :)

(:27:)(:
for $k in doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/swiat.xml')
/SWIAT/KRAJE/KRAJ
return <KRAJ>
{$k/NAZWA, $k/STOLICA}
</KRAJ> :)

(:28:)(:
for $k in doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/swiat.xml')
/SWIAT/KRAJE/KRAJ[starts-with(NAZWA,'A')]
return <KRAJ>
{$k/NAZWA, $k/STOLICA}
</KRAJ> :)

(:29:) (:
for $k in doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/swiat.xml')
/SWIAT/KRAJE/KRAJ[starts-with(NAZWA,substring(STOLICA, 1,1))]
return <KRAJ>
{$k/NAZWA, $k/STOLICA}
</KRAJ> :)

(:30:) (:
doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/swiat.xml')
//KRAJ :)

(:31:) (:
doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/zesp_prac.xml') :)

(:32:) (:
doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/zesp_prac.xml')
//NAZWISKO :)

(:33:) (:
doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/zesp_prac.xml')
//ROW[NAZWA='SYSTEMY EKSPERCKIE']/PRACOWNICY/ROW/NAZWISKO :)

(:34:) (:
count(doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/zesp_prac.xml')
//ROW[ID_ZESP=10]/PRACOWNICY/ROW/NAZWISKO) :)

(:35:) (:
doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/zesp_prac.xml')
//ROW[ID_SZEFA='100']/NAZWISKO :)

(:36:)
sum(doc('file:///D:/Studia/Zaawansowane Technologie Przetwarzania Danych/Laboratorium/XPath-XSLT/zesp_prac.xml')
//ROW[PRACOWNICY/ROW[NAZWISKO='BRZEZINSKI']/ID_ZESP=ID_ZESP]/PRACOWNICY/ROW/PLACA_POD)