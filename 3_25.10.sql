------ Duże obiekty tekstowe -------------------------------------------------------------------------------------------
------ Zadanie 1 -------------------------------------------------------------------------------------------------------
create table DOKUMENTY(
    id number(12) primary key,
    dokument clob
);

------ Zadanie 2 -------------------------------------------------------------------------------------------------------
DECLARE
    tekst CLOB;
BEGIN
    DBMS_LOB.createTemporary(tekst, TRUE);

    FOR i IN 1..10000 LOOP
        tekst := tekst || 'Oto tekst. ';
    END LOOP;

    INSERT INTO DOKUMENTY VALUES (1, tekst);
    DBMS_LOB.freeTemporary(tekst);
    COMMIT;
END;

------ Zadanie 3 -------------------------------------------------------------------------------------------------------
select * from DOKUMENTY;
select id, upper(dokument) from DOKUMENTY;
select id, length(dokument) from DOKUMENTY;
select id, DBMS_LOB.getLength(dokument) from DOKUMENTY;
select id, substr(dokument, 5, 1000) from DOKUMENTY;
select id, DBMS_LOB.substr(dokument, 1000, 5) from DOKUMENTY;

------ Zadanie 4 -------------------------------------------------------------------------------------------------------
insert into DOKUMENTY values (2, empty_clob());

------ Zadanie 5 -------------------------------------------------------------------------------------------------------
insert into DOKUMENTY values (3, null);

------ Zadanie 6 -------------------------------------------------------------------------------------------------------
select * from DOKUMENTY;
select id, upper(dokument) from DOKUMENTY;
select id, length(dokument) from DOKUMENTY;
select id, DBMS_LOB.getLength(dokument) from DOKUMENTY;
select id, substr(dokument, 5, 1000) from DOKUMENTY;
select id, DBMS_LOB.substr(dokument, 1000, 5) from DOKUMENTY;

------ Zadanie 7 -------------------------------------------------------------------------------------------------------
DECLARE
    source_file BFILE := BFILENAME('TPD_DIR', 'dokument.txt');
    target_clob CLOB;
    dest_off integer := 1;
    src_off integer := 1;
    lang_ctx integer := 0;
    warning integer := null;
BEGIN
    SELECT DOKUMENT
    INTO target_clob
    FROM DOKUMENTY
    WHERE ID = 2
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(source_file, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(target_clob, source_file, DBMS_LOB.LOBMAXSIZE, dest_off, src_off, 0, lang_ctx, warning);

    DBMS_LOB.FILECLOSE(source_file);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status: ' || warning);
END;

------ Zadanie 8 -------------------------------------------------------------------------------------------------------
update DOKUMENTY set dokument = to_clob(bfilename('TPD_DIR', 'dokument.txt')) where id = 3;

------ Zadanie 9 -------------------------------------------------------------------------------------------------------
select * from DOKUMENTY;

------ Zadanie 10 ------------------------------------------------------------------------------------------------------
select id, DBMS_LOB.getLength(dokument) from DOKUMENTY;

------ Zadanie 11 ------------------------------------------------------------------------------------------------------
drop table DOKUMENTY;

------ Zadanie 12 ------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE CLOB_CENSOR(
    p_clob IN OUT CLOB,
    p_search IN VARCHAR2
) IS
    v_pos NUMBER;
    v_len NUMBER;
    v_replace VARCHAR2(4000);
BEGIN

    IF p_search IS NOT NULL AND LENGTH(p_search) > 0 THEN
        v_len := LENGTH(p_search);
        v_replace := RPAD('.', v_len, '.');
        v_pos := INSTR(p_clob, p_search, 1, 1);

        WHILE v_pos > 0 LOOP
            DBMS_LOB.WRITE(p_clob, v_len, v_pos, v_replace);
            v_pos := INSTR(p_clob, p_search, v_pos + v_len, 1);
        END LOOP;
    END IF;
END CLOB_CENSOR;

------ Zadanie 13 ------------------------------------------------------------------------------------------------------
CREATE TABLE BIOGRAPHIES AS SELECT * FROM ZTPD.BIOGRAPHIES;

DECLARE
    v_clob CLOB;
BEGIN
    SELECT bio INTO v_clob
    FROM BIOGRAPHIES
    WHERE ID = 1 FOR UPDATE;

    CLOB_CENSOR(v_clob, 'Cimrman');

    UPDATE BIOGRAPHIES
    SET bio = v_clob
    WHERE ID = 1;
    COMMIT;
END;

select * from BIOGRAPHIES;

------ Zadanie 14 ------------------------------------------------------------------------------------------------------
drop table BIOGRAPHIES;