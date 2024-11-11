------ Ćwiczenie 1 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
select * from USER_SDO_GEOM_METADATA;

INSERT INTO USER_SDO_GEOM_METADATA VALUES ('FIGURY', 'ksztalt', SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('X', -100, 100, 0.01),
        SDO_DIM_ELEMENT('Y', -100, 100, 0.01)
    ), NULL);

------ B ---------------------------------------------------------------------------------------------------------------
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0 )FROM dual;

------ C ---------------------------------------------------------------------------------------------------------------
CREATE INDEX FIGURY_INDEX ON FIGURY(KSZTALT) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;
SELECT INDEX_NAME, TABLE_NAME, TABLE_TYPE, INDEX_TYPE, STATUS FROM USER_INDEXES;

------ D ---------------------------------------------------------------------------------------------------------------
SELECT ID FROM FIGURY
WHERE SDO_FILTER(KSZTALT,
    SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3, 3, NULL), NULL, NULL)
) = 'TRUE';

------ E ---------------------------------------------------------------------------------------------------------------
SELECT ID FROM FIGURY
WHERE SDO_RELATE(KSZTALT,
    SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3, 3, NULL), NULL, NULL),
    'mask=ANYINTERACT'
) = 'TRUE';

select * from figury;

------ Ćwiczenie 2 -----------------------------------------------------------------------------------------------------
select * from country_boundaries;
select * from rivers;
select * from major_cities;
select * from water_bodies;
select * from STREETS_AND_RAILROADS;

------ A ---------------------------------------------------------------------------------------------------------------
select city_name miasto, sdo_nn_distance(1) odl from MAJOR_CITIES
where sdo_nn(geom, (select geom from MAJOR_CITIES where admin_name = 'Warszawa'), 'unit=km', 1) = 'TRUE'
    and sdo_nn_distance(1) > 0
order by odl fetch first 9 rows only;

------ B ---------------------------------------------------------------------------------------------------------------
select city_name miasto from MAJOR_CITIES
where sdo_within_distance(geom, (select geom from MAJOR_CITIES where admin_name = 'Warszawa'), 'distance=100 unit=km') = 'TRUE';

------ C ---------------------------------------------------------------------------------------------------------------
select country.cntry_name kraj, city.city_name
from COUNTRY_BOUNDARIES country, MAJOR_CITIES city
where country.cntry_name = 'Slovakia'
    and sdo_geom.relate(country.geom, 'DETERMINE', city.geom, 1) = 'CONTAINS';

------ D ---------------------------------------------------------------------------------------------------------------
SELECT c.Cntry_name kraj,
    SDO_GEOM.SDO_DISTANCE(c.GEOM, (SELECT geom FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Poland'), 1, 'unit=km') odl
FROM COUNTRY_BOUNDARIES c
WHERE SDO_GEOM.RELATE(c.GEOM, 'DETERMINE', (SELECT geom FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Poland'), 1) = 'DISJOINT';

------ Ćwiczenie 3 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
SELECT c.cntry_name,
    SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(
        (select geom from COUNTRY_BOUNDARIES where cntry_name = 'Poland'),
        c.geom, 1), 1, 'unit=km') AS odleglosc
FROM COUNTRY_BOUNDARIES c
WHERE sdo_geom.relate(c.geom, 'DETERMINE',
    (select geom from COUNTRY_BOUNDARIES where cntry_name = 'Poland'),
    1) = 'TOUCH';

------ B ---------------------------------------------------------------------------------------------------------------
SELECT cntry_name
FROM COUNTRY_BOUNDARIES
WHERE SDO_GEOM.SDO_AREA(geom, 0.01) = (SELECT MAX(SDO_GEOM.SDO_AREA(geom, 0.01)) FROM COUNTRY_BOUNDARIES);

------ C ---------------------------------------------------------------------------------------------------------------
SELECT SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_MBR(SDO_GEOM.SDO_UNION(
        (select geom from MAJOR_CITIES where city_name = 'Warsaw'),
        (select geom from MAJOR_CITIES where city_name = 'Lodz'))), 1, 'unit=SQ_KM') AS sq_km
from dual;

------ D ---------------------------------------------------------------------------------------------------------------
SELECT SDO_GEOM.SDO_UNION(
    (select geom from COUNTRY_BOUNDARIES where cntry_name = 'Poland'),
    (select geom from MAJOR_CITIES where city_name = 'Prague'), 1).SDO_GTYPE gtype
from dual;

------ E ---------------------------------------------------------------------------------------------------------------
SELECT c.city_name, c.cntry_name
FROM MAJOR_CITIES c
order by SDO_GEOM.SDO_DISTANCE(geom, SDO_GEOM.SDO_CENTROID((SELECT geom FROM COUNTRY_BOUNDARIES b WHERE b.CNTRY_NAME = c.cntry_name)), 1)
fetch first row only;

------ F ---------------------------------------------------------------------------------------------------------------
SELECT name, sum(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(geom,
    (SELECT geom FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Poland'), 1), 1, 'unit=km')) AS dlugosc
FROM RIVERS
WHERE SDO_GEOM.RELATE((SELECT geom FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME = 'Poland'), 'DETERMINE', geom, 1) != 'DISJOINT'
group by name;