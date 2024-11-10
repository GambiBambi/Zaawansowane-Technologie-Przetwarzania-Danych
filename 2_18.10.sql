------ Duże obiekty binarne --------------------------------------------------------------------------------------------
------ Zadanie 1 -------------------------------------------------------------------------------------------------------
create table MOVIES as select * from ZTPD.MOVIES;

------ Zadanie 2 -------------------------------------------------------------------------------------------------------
select * from MOVIES;
select id, title, cover from MOVIES;

------ Zadanie 3 -------------------------------------------------------------------------------------------------------
select id, title from MOVIES where cover is null;

------ Zadanie 4 -------------------------------------------------------------------------------------------------------
select id, title, lengthb(cover) as filesize from MOVIES where cover is not null;

------ Zadanie 5 -------------------------------------------------------------------------------------------------------
select id, title, lengthb(cover) as filesize from MOVIES where cover is null;

------ Zadanie 6 -------------------------------------------------------------------------------------------------------
select directory_name, directory_path from ALL_DIRECTORIES;
select directory_path from ALL_DIRECTORIES where directory_name = 'TPD_DIR';

------ Zadanie 7 -------------------------------------------------------------------------------------------------------
update MOVIES set cover = empty_blob(), mime_type = 'image/jpeg' where id = 66;
commit;

------ Zadanie 8 -------------------------------------------------------------------------------------------------------
select id, title, lengthb(cover) as filesize from MOVIES where id in (65, 66);

------ Zadanie 9 -------------------------------------------------------------------------------------------------------
DECLARE
    picture BLOB;
    file BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
BEGIN
    SELECT cover INTO picture
    FROM MOVIES
    WHERE id = 66
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(file, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(picture, file, DBMS_LOB.GETLENGTH(file));
    DBMS_LOB.FILECLOSE(file);

    COMMIT;
END;

select * from MOVIES;

------ Zadanie 10 ------------------------------------------------------------------------------------------------------
create table TEMP_COVERS (
    movie_id number(12),
    image blob,
    mime_type varchar2(50)
) lob (image)
store as securefile(
    disable storage in row
    chunk 4096
    pctversion 20
    nocache
    nologging
    );

------ Zadanie 11 ------------------------------------------------------------------------------------------------------
insert into TEMP_COVERS values (65, bfilename('TPD_DIR', 'eagles.jpg'), 'image/jpg');

------ Zadanie 12 ------------------------------------------------------------------------------------------------------
select movie_id, lengthb(image) as FILESIZE from TEMP_COVERS where movie_id = 65;

------ Zadanie 13 ------------------------------------------------------------------------------------------------------
DECLARE
    temp_bfile BFILE;
    temp_mime_type VARCHAR2(50);
    temp_blob BLOB;
BEGIN
    SELECT image, mime_type
    INTO temp_blob, temp_mime_type
    FROM TEMP_COVERS
    WHERE movie_id = 65;

    DBMS_LOB.CREATETEMPORARY(temp_blob, TRUE);
    DBMS_LOB.FILEOPEN(temp_bfile, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(temp_blob, temp_bfile, DBMS_LOB.GETLENGTH(temp_bfile));
    DBMS_LOB.FILECLOSE(temp_bfile);

    UPDATE MOVIES
    SET cover = temp_blob,
        mime_type = temp_mime_type
    WHERE id = 65;
    DBMS_LOB.FREETEMPORARY(temp_blob);
    COMMIT;
END;

------ Zadanie 14 ------------------------------------------------------------------------------------------------------
select id, lengthb(cover) as FILESIZE from MOVIES where id in (65, 66);

------ Zadanie 15 ------------------------------------------------------------------------------------------------------
drop table MOVIES;