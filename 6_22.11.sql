drop table MYST_COUNTRY_BOUNDARIES;
drop table MYST_MAJOR_CITIES;

------ Ćwiczenie 1 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
and prior t.owner = t.owner;

------ B ---------------------------------------------------------------------------------------------------------------
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

------ C ---------------------------------------------------------------------------------------------------------------
CREATE TABLE MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

------ D ---------------------------------------------------------------------------------------------------------------
select * from MAJOR_CITIES;
insert into MYST_MAJOR_CITIES
select FIPS_CNTRY, CITY_NAME, TREAT(ST_POINT.FROM_SDO_GEOM(GEOM) AS ST_POINT) STGEOM
from MAJOR_CITIES;
select * from MYST_MAJOR_CITIES;

------ Ćwiczenie 2 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
insert into MYST_MAJOR_CITIES
values('PL', 'Szczyrk', NEW ST_POINT(19.036107, 49.718655, null))

------ Ćwiczenie 3 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
CREATE TABLE MYST_COUNTRY_BOUNDARIES (
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM     ST_MULTIPOLYGON
);

------ B ---------------------------------------------------------------------------------------------------------------
select * from COUNTRY_BOUNDARIES;
insert into MYST_COUNTRY_BOUNDARIES
select FIPS_CNTRY, CNTRY_NAME, ST_MULTIPOLYGON(GEOM) STGEOM
from COUNTRY_BOUNDARIES;
select * from MYST_COUNTRY_BOUNDARIES;

------ C ---------------------------------------------------------------------------------------------------------------
select b.STGEOM.st_geometryType() typ_obiektu, count(*) ile
    from MYST_COUNTRY_BOUNDARIES b
group by b.STGEOM.st_geometryType();

------ D ---------------------------------------------------------------------------------------------------------------
select B.STGEOM.ST_ISSIMPLE() from MYST_COUNTRY_BOUNDARIES B;

------ Ćwiczenie 4 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
delete from MYST_MAJOR_CITIES where city_name = 'Szczyrk';

SELECT cb.CNTRY_NAME, COUNT(city_name) AS COUNT
FROM MYST_MAJOR_CITIES mc, MYST_COUNTRY_BOUNDARIES cb
WHERE mc.STGEOM.ST_WITHIN(cb.STGEOM) = 1
GROUP BY cb.CNTRY_NAME;

------ B ---------------------------------------------------------------------------------------------------------------
SELECT cb1.CNTRY_NAME AS A_NAME, cb2.CNTRY_NAME AS B_NAME
FROM MYST_COUNTRY_BOUNDARIES cb1, MYST_COUNTRY_BOUNDARIES cb2
WHERE cb2.CNTRY_NAME = 'Czech Republic' and cb1.STGEOM.ST_TOUCHES(cb2.STGEOM) = 1;

------ C ---------------------------------------------------------------------------------------------------------------
select * from RIVERS;

SELECT unique c.CNTRY_NAME, r.name
FROM MYST_COUNTRY_BOUNDARIES c, RIVERS r
WHERE c.CNTRY_NAME = 'Czech Republic' and ST_LINESTRING(r.GEOM).ST_INTERSECTS(c.STGEOM) = 1;

------ D ---------------------------------------------------------------------------------------------------------------
select treat(c1.STGEOM.ST_UNION(c2.STGEOM) as ST_POLYGON).ST_AREA() POWIERZCHNIA
from MYST_COUNTRY_BOUNDARIES c1, MYST_COUNTRY_BOUNDARIES c2
where c1.CNTRY_NAME = 'Czech Republic'
and c2.CNTRY_NAME = 'Slovakia';

------ E ---------------------------------------------------------------------------------------------------------------
select * from WATER_BODIES;

select c.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(w.GEOM)) obiekt,
    c.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(w.GEOM)).st_geometryType() wegry_bez
from MYST_COUNTRY_BOUNDARIES c, WATER_BODIES w
where c.CNTRY_NAME = 'Hungary'
and w.NAME = 'Balaton';

------ Ćwiczenie 5 -----------------------------------------------------------------------------------------------------
------ A ---------------------------------------------------------------------------------------------------------------
SELECT c.CNTRY_NAME , COUNT(*) liczba
FROM MYST_MAJOR_CITIES m, MYST_COUNTRY_BOUNDARIES c
WHERE c.CNTRY_NAME = 'Poland' AND SDO_WITHIN_DISTANCE(m.STGEOM, c.STGEOM, 'distance=100 unit=km') = 'TRUE'
GROUP BY c.CNTRY_NAME; -- nie działa

------ B ---------------------------------------------------------------------------------------------------------------
insert into USER_SDO_GEOM_METADATA
 select 'MYST_MAJOR_CITIES', 'STGEOM', T.DIMINFO, T.SRID from USER_SDO_GEOM_METADATA T
 where T.TABLE_NAME = 'MAJOR_CITIES';

select * from USER_SDO_GEOM_METADATA;

------ C ---------------------------------------------------------------------------------------------------------------
select * from MYST_MAJOR_CITIES;
CREATE INDEX MYST_MAJOR_CITIES_IDX ON MYST_MAJOR_CITIES(STGEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

------ D ---------------------------------------------------------------------------------------------------------------
SELECT c.CNTRY_NAME AS A_NAME, COUNT(*) FROM MYST_MAJOR_CITIES m, MYST_COUNTRY_BOUNDARIES c
WHERE c.CNTRY_NAME = 'Poland' AND SDO_WITHIN_DISTANCE(m.STGEOM, c.STGEOM, 'distance=100 unit=km') = 'TRUE'
GROUP BY c.CNTRY_NAME;

EXPLAIN PLAN FOR
SELECT c.CNTRY_NAME AS A_NAME, COUNT(*) FROM MYST_MAJOR_CITIES m, MYST_COUNTRY_BOUNDARIES c
WHERE c.CNTRY_NAME = 'Poland' AND SDO_WITHIN_DISTANCE(m.STGEOM, c.STGEOM, 'distance=100 unit=km') = 'TRUE'
GROUP BY c.CNTRY_NAME;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);