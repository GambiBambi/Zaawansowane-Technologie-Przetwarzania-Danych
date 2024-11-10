drop table samochody;
drop table wlasciciele;
drop type samochod;
drop type wlasciciel;

drop table kwartaly;
drop type miesiace;
drop type miesiac;

drop table koszyk_produktow;
drop table zakupy;
drop type produkt;

------ Tworzenie typów obiektowych -------------------------------------------------------------------------------------
------ Zadanie 1 -------------------------------------------------------------------------------------------------------
create type samochod as object (
    marka varchar2(20),
    model varchar2(20),
    kilometry number,
    data_produkcji date,
    cena number(10,2)
                                );
create table samochody of samochod;
insert into samochody values ('FIAT', 'BRAVA', 60000, to_date('30-11-1999', 'DD-MM-RRRR'), 25000);
insert into samochody values ('FORD', 'MONDEO', 80000, to_date('10-05-1997', 'DD-MM-RRRR'), 45000);
insert into samochody values ('MAZDA', '323', 12000, to_date('22-09-2000', 'DD-MM-RRRR'), 52000);

select * from samochody;

------ Zadanie 2 -------------------------------------------------------------------------------------------------------
create table wlasciciele(
    imie varchar2(100),
    nazwisko varchar2(100),
    auto samochod
                                );
insert into wlasciciele values ('JAN','KOWALSKI', samochod('FIAT', 'SEICENTO', 30000, to_date('02-12-2010', 'DD-MM-RRRR'), 19500));
insert into wlasciciele values ('ADAM','NOWAK', samochod('OPEL', 'ASTRA', 34000, to_date('01-06-2009', 'DD-MM-RRRR'), 33700));

select * from wlasciciele;

------ Zadanie 3 -------------------------------------------------------------------------------------------------------
alter type samochod replace as object (
    marka varchar2(20),
    model varchar2(20),
    kilometry number,
    data_produkcji date,
    cena number(10,2),
    member function wartosc return number
    );

create or replace type body samochod as
    member function wartosc return number is
        begin
            return cena * 0.9**(extract(year from current_date) - extract(year from data_produkcji));
        end wartosc;
end;

select s.marka, s.cena, s.wartosc() from samochody s;

------ Zadanie 4 -------------------------------------------------------------------------------------------------------
alter type samochod add map member function wiek_zuzycie
return number cascade including table data;

create or replace type body samochod as
    member function wartosc return number is
        begin
            return cena * 0.9**(extract(year from current_date) - extract(year from data_produkcji));
        end wartosc;
    map member function wiek_zuzycie return number is
        begin
            return (extract(year from current_date) - extract(year from data_produkcji)) + kilometry/10000;

        end wiek_zuzycie;
end;

 select * from samochody s order by value(s);

------ Zadanie 5 -------------------------------------------------------------------------------------------------------
drop table wlasciciele;

create type wlasciciel as object (
    imie varchar2(100),
    nazwisko varchar2(100)
                                );
create table wlasciciele of wlasciciel;
drop table samochody;
drop type samochod;

create type samochod as object (
    marka varchar2(20),
    model varchar2(20),
    kilometry number,
    data_produkcji date,
    cena number(10,2),
    wlasciciel_samochodu ref wlasciciel,
    member function wartosc return number
    );
alter type samochod add map member function wiek_zuzycie
return number cascade including table data;

create table samochody of samochod;
alter table samochody add scope for (wlasciciel_samochodu) is wlasciciele;

insert into wlasciciele values ('JAN','KOWALSKI');
insert into wlasciciele values ('ADAM','NOWAK');
insert into samochody values ('FIAT', 'BRAVA', 60000, to_date('30-11-1999', 'DD-MM-RRRR'), 25000, null);
insert into samochody values ('FORD', 'MONDEO', 80000, to_date('10-05-1997', 'DD-MM-RRRR'), 45000, null);
insert into samochody values ('MAZDA', '323', 12000, to_date('22-09-2000', 'DD-MM-RRRR'), 52000, null);

update samochody s set s.wlasciciel_samochodu = (
    select ref(w) from wlasciciele w
        where w.nazwisko = 'KOWALSKI'
) where s.marka = 'FIAT';
update samochody s set s.wlasciciel_samochodu = (
    select ref(w) from wlasciciele w
        where w.nazwisko = 'KOWALSKI'
) where s.marka = 'FORD';
update samochody s set s.wlasciciel_samochodu = (
    select ref(w) from wlasciciele w
        where w.nazwisko = 'NOWAK'
) where s.marka = 'MAZDA';

select * from wlasciciele;
select * from samochody;
select marka, model, deref(wlasciciel_samochodu) as wlasciciel_samochodu from samochody;

------ Kolekcje --------------------------------------------------------------------------------------------------------
------ Zadanie 6 -------------------------------------------------------------------------------------------------------
DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10 LOOP
        moje_przedmioty(i) := 'PRZEDMIOT_' || i;
    END LOOP;
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    moje_przedmioty.TRIM(2);
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;

------ Zadanie 7 -------------------------------------------------------------------------------------------------------
create type tytul_ksiazki as varray(10) of varchar(100);
create table ksiazki (autor varchar2(100), ksiazki tytul_ksiazki);
insert into ksiazki values ('Adam Mickiewicz', tytul_ksiazki('Pan Tadeusz', 'Dziady część II', 'Dziady część IV'));
insert into ksiazki values ('Juliusz Słowacki', tytul_ksiazki('Balladyna', 'Kordian. Część pierwsza trylogii. Spisek koronacyjny'));
select * from ksiazki;

update ksiazki set ksiazki = tytul_ksiazki('Pan Tadeusz', 'Dziady część II', 'Dziady część IV', 'Dziady część III') where autor = 'Adam Mickiewicz';
select * from ksiazki;

------ Zadanie 8 -------------------------------------------------------------------------------------------------------
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.EXTEND(8);
    FOR i IN 3..10 LOOP
        moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;
    moi_wykladowcy.TRIM(2);
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;
    moi_wykladowcy.DELETE(5,7);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

------ Zadanie 9 -------------------------------------------------------------------------------------------------------
create type miesiac as object (
    nazwa varchar2(25),
    numer number,
    dni number
                          );
create type miesiace as TABLE OF miesiac;
create table kwartaly (numer number, tabela_miesiecy miesiace)
nested table tabela_miesiecy store as t_miesiace;

insert into kwartaly values (1, miesiace(miesiac('Styczeń', 1, 31), miesiac('Luty', 2, 28), miesiac('Marzec', 1, 31)));
insert into kwartaly values (2, miesiace(miesiac('Kwiecień', 1, 30), miesiac('Maj', 2, 31), miesiac('Czerwiec', 1, 30)));
insert into kwartaly values (3, miesiace(miesiac('Lipiec', 1, 31), miesiac('Sierpień', 2, 31), miesiac('Wrzesień', 1, 30)));
insert into kwartaly values (4, miesiace(miesiac('Październik', 1, 31), miesiac('Listopad', 2, 30), miesiac('Grudzień', 1, 31)));

select * from kwartaly;

------ Zadanie 10 ------------------------------------------------------------------------------------------------------
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE stypendium AS OBJECT (
nazwa VARCHAR2(50),
kraj VARCHAR2(30),
jezyki jezyki_obce );
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';
CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE semestr AS OBJECT (
numer NUMBER,
egzaminy lista_egzaminow );
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';

------ Zadanie 11 ------------------------------------------------------------------------------------------------------
create type produkt as object (
    nazwa varchar2(50),
    cena number(10, 2)
);
create type koszyk_produktow as table of produkt;

create table zakupy (
    id_zakupu number primary key,
    data_zakupu date,
    koszyk_produktow koszyk_produktow
)
nested table koszyk_produktow store as t_koszyk_produktow;

insert into zakupy values (1, to_date('07-11-2023', 'DD-MM-YYYY'),
                           koszyk_produktow(produkt('Chleb', 5.50), produkt('Masło', 6.20), produkt('Mleko', 3.40))
);
insert into zakupy values (2, to_date('07-11-2023', 'DD-MM-YYYY'),
                           koszyk_produktow(produkt('Chleb', 5.50), produkt('Jabłka', 2.50), produkt('Ser', 10.00))
);
insert into zakupy values (3, to_date('07-11-2023', 'DD-MM-YYYY'),
                           koszyk_produktow(produkt('Woda', 1.50), produkt('Masło', 6.20), produkt('Jabłka', 2.50))
);

select * from zakupy;

------ Polimorfizm, dziedziczenie --------------------------------------------------------------------------------------
------ Zadanie 12 ------------------------------------------------------------------------------------------------------
CREATE TYPE instrument AS OBJECT (
nazwa VARCHAR2(20),
dzwiek VARCHAR2(20),
MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
CREATE TYPE BODY instrument AS
MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN dzwiek;
END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
material VARCHAR2(20),
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_dety AS
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN 'dmucham: '||dzwiek;
END;
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
BEGIN
RETURN glosnosc||':'||dzwiek;
END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
producent VARCHAR2(20),
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN 'stukam w klawisze: '||dzwiek;
END;
END;
/
DECLARE
tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','ping-
ping','steinway');
BEGIN
dbms_output.put_line(tamburyn.graj);
dbms_output.put_line(trabka.graj);
dbms_output.put_line(trabka.graj('glosno'));
dbms_output.put_line(fortepian.graj);
END;

------ Zadanie 13 ------------------------------------------------------------------------------------------------------
CREATE TYPE istota AS OBJECT (
nazwa VARCHAR2(20),
NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota (
liczba_nog NUMBER,
OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
CREATE OR REPLACE TYPE BODY lew AS
OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
BEGIN
RETURN 'upolowana ofiara: '||ofiara;
END;
END;
DECLARE
KrolLew lew := lew('LEW',4);
InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;

------ Zadanie 14 ------------------------------------------------------------------------------------------------------
DECLARE
tamburyn instrument;
cymbalki instrument;
trabka instrument_dety;
saksofon instrument_dety;
BEGIN
tamburyn := instrument('tamburyn','brzdek-brzdek');
cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
-- saksofon := instrument('saksofon','tra-taaaa');
-- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

------ Zadanie 15 ------------------------------------------------------------------------------------------------------
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa')
);
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','ping-
ping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;
