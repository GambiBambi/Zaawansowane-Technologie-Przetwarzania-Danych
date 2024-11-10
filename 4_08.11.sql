drop table FIGURY;

------ Ćwiczenie 1 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
create table FIGURY (
    id number(1) primary key,
    ksztalt MDSYS.SDO_GEOMETRY
);

------ B ---------------------------------------------------------------------------------------------------------------
INSERT INTO FIGURY (ID, KSZTALT)
VALUES (1, SDO_GEOMETRY(2007, null, null,
            SDO_ELEM_INFO_ARRAY(1, 1003, 4),
            SDO_ORDINATE_ARRAY(5,7, 3,5, 5,3))
       );
INSERT INTO FIGURY (ID, KSZTALT)
VALUES (2, SDO_GEOMETRY(2007, NULL, NULL,
            SDO_ELEM_INFO_ARRAY(1, 1003, 1),
            SDO_ORDINATE_ARRAY(1,1, 5,1, 5,5, 1,5, 1,1))
        );
INSERT INTO FIGURY (ID, KSZTALT)
VALUES (3, SDO_GEOMETRY(2002, NULL, NULL,
            SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
            SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1))
        );
select * from FIGURY;

------ C ---------------------------------------------------------------------------------------------------------------
INSERT INTO FIGURY (ID, KSZTALT)
VALUES (4, SDO_GEOMETRY(2007, null, null,
            SDO_ELEM_INFO_ARRAY(1, 1003, 4),
            SDO_ORDINATE_ARRAY(5,7, 5,8, 5,9))
       );
select * from FIGURY;

------ D ---------------------------------------------------------------------------------------------------------------
select id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005) from FIGURY;

------ E ---------------------------------------------------------------------------------------------------------------
delete from figury where SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005) != 'TRUE';
select * from FIGURY;
select id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005) from FIGURY;

------ F ---------------------------------------------------------------------------------------------------------------
commit;