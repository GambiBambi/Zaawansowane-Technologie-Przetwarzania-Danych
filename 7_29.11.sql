------ Ćwiczenie 1 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
CREATE TABLE A6_LRS (GEOM SDO_GEOMETRY);

------ B ---------------------------------------------------------------------------------------------------------------
INSERT INTO A6_LRS (GEOM)
SELECT GEOM FROM STREETS_AND_RAILROADS
WHERE SDO_WITHIN_DISTANCE(GEOM, (SELECT GEOM FROM MAJOR_CITIES WHERE CITY_NAME = 'Koszalin'), 'distance=10 unit=km') = 'TRUE';

------ C ---------------------------------------------------------------------------------------------------------------
SELECT SDO_GEOM.SDO_LENGTH(GEOM, 1, 'unit=km') DISTANCE, SDO_UTIL.GETNUMVERTICES(GEOM) ST_NUMPOINTS FROM A6_LRS;

------ D ---------------------------------------------------------------------------------------------------------------
select * from A6_LRS;
drop table A6_LRS;
CREATE TABLE A6_LRS (GEOM SDO_GEOMETRY);
INSERT INTO A6_LRS (GEOM) SELECT SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 267.681) GEOM FROM STREETS_AND_RAILROADS
WHERE SDO_WITHIN_DISTANCE(GEOM, (SELECT GEOM FROM MAJOR_CITIES WHERE CITY_NAME = 'Koszalin'), 'distance=10 unit=km') = 'TRUE';

------ E ---------------------------------------------------------------------------------------------------------------
select * from A6_LRS;

INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('A6_LRS', 'GEOM',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('X', 12.0, 27.0, 0.5),
        SDO_DIM_ELEMENT('Y', 45.0, 59.0, 0.5),
        SDO_DIM_ELEMENT('M', 0, 300, 1)
    ), 8307);
select * from USER_SDO_GEOM_METADATA;

------ F ---------------------------------------------------------------------------------------------------------------
CREATE INDEX A6_LRS_IDX ON A6_LRS(GEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

------ Ćwiczenie 2 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
SELECT SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500 FROM A6_LRS;

------ B ---------------------------------------------------------------------------------------------------------------
SELECT SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT FROM A6_LRS;

------ C ---------------------------------------------------------------------------------------------------------------
SELECT SDO_LRS.LOCATE_PT(GEOM, 150, 0) KM150 FROM A6_LRS;

------ D ---------------------------------------------------------------------------------------------------------------
SELECT SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160) CLIPPED FROM A6_LRS;

------ E ---------------------------------------------------------------------------------------------------------------
select * from MAJOR_CITIES where city_name = 'Slupsk';
SELECT SDO_LRS.PROJECT_PT(a.GEOM, c.geom) WJAZD_NA_A6 FROM A6_LRS a, MAJOR_CITIES c
where c.city_name = 'Slupsk';

------ F ---------------------------------------------------------------------------------------------------------------
select SDO_GEOM.SDO_LENGTH( (select SDO_LRS.OFFSET_GEOM_SEGMENT(A6.GEOM, M.DIMINFO, 50, 200, 50, 'unit=m arc_tolerance=1')
    from A6_LRS A6, USER_SDO_GEOM_METADATA M where M.TABLE_NAME = 'A6_LRS' and M.COLUMN_NAME = 'GEOM'),1,'unit=km') KOSZT
from dual;