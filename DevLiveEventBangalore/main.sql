--- ============== Login as SYS user --------------------

sqlplus sys@localhost:1521/freepdb1 as sysdba

select table_name from user_tables;

select username, account_status from DBA_USERS where account_status='OPEN';

SELECT * FROM V$VERSION;
 
---- 01 ---------- SQL without FROM ----------------- 
--  create user --

create user john identified by johnpwd quota unlimited on users; 
 
grant DB_DEVELOPER_ROLE to john;


GRANT CREATE MLE TO john; 
GRANT EXECUTE ON JAVASCRIPT TO john;  
GRANT connect, resource to john; 
commit;

---  01 ---- DEVELOPER AND JAVASCRIPT ROLES -------------
GRANT EXECUTE ON JAVASCRIPT TO john;
GRANT DB_DEVELOPER_ROLE to john;
GRANT CREATE MLE TO john;

---- Connect as user john -------------
---- 02 ---------- SQL without FROM -------------------------------------------------------------------

select sysdate; 
select (31*22)+(22*34) calc;
select user;

---- 03 ---------- IF NOT EXISTS -------------------------- 

DROP table if exists johnshop purge;
 
create table if not exists locations (
  different_colulmns json 
);

desc locations;

---- 04 ---------- BOOLEAN TYPE ---------------------------

CREATE TABLE johnshop 
(
    pizzaname VARCHAR2(100), 
    is_available BOOLEAN
); 

insert into johnshop 
(pizzaname, is_available) values ('Corn Pizza', true);

insert into johnshop 
(pizzaname, is_available) values ('Veg Pizza', 1); 

---- 05 ---------- Select and Insert together -------------------------------------------------------------------
select * from 
(values ('Corn with cheese pizza',true),('Corn with chicken pizza', false)) 
temp_johnshop 
(pizzaname, is_available);

select * from 
(values ('Corn with cheese pizza',true),('Corn with chicken pizza', false)) 
johnshop 
(pizzaname, is_available);

-- 06 --- Multi value Insert: ------------------------------------------------------------------
 
insert into johnshop values
    ('Veg rolls', true),
    ('Spring rolls', false),
    ('Corn pepper Pizza', 1);  

commit;

select * from johnshop;



--- 07 --- Direct Joins for UPDATE and DELETE Statements ----------------------------------------

DROP table if exists shop_items purge;
DROP table if exists shops purge;

create table shops (
  shop_id number constraint pk_shop_id primary key,
  shop_name varchar2(40),
  location varchar2(40)
) ;

create table shop_items (
  item_no number  constraint pk_item_no primary key,
  item_name varchar2(40), 
  quantity_available number, 
  unit_price number, 
  shop_id number constraint fk_shop_id references shops
); 

drop table if exists pizza_order;

create table pizza_order
( 
    customer_id number,
    order_item varchar2(100) annotations(display_size 'Medium Pizza', pizza_crust 'Thin', pizza_offer 'Festival Offer'), 
    quantity number,
    order_date date default sysdate 
)
annotations (display 'pizza_order_table');

select * from pizza_order;

insert into pizza_order values 
    (1, 'Pops Pizza', 10 , sysdate),
    (2, 'Alien Pizzas', 20, sysdate);

select * from pizza_order;

select object_name, object_type, column_name, annotation_name, annotation_value 
from user_annotations_usage; 

select object_name, column_name, domain_name, annotation_name, annotation_value
from   user_annotations_usage
where  object_name in ( 'PIZZA_ORDER' )
order  by annotation_name, object_name;

insert into shop_items values 
    (1, 'Pops Veg Pizza', 10, 100, 1),
    (2, 'Pops Chicken Pizza', 12, 100, 1),
    (3, 'Pops Corn Pizza', 20, 50, 1),
    (4, 'Alien Veg Burgers', 10, 100, 2),
    (5, 'Alien Chicken Burgers', 12, 100, 2),
    (6, 'Alien Paneer Rolls', 20, 50, 2);

commit;

select * from shops;
select * from shop_items;

UPDATE shops s 
    set s.shop_name = 'New ' || s.shop_name 
FROM shop_items si
    WHERE si.shop_id = s.shop_id
    AND si.item_name = 'Alien Paneer Rolls' ;

select * from shops;

commit;

--- 08 --- DML RETURNING Clause Enhancements --------------------------------------------------

DROP table if exists pizzaitems purge;

CREATE TABLE pizzaitems (itemname VARCHAR2(50), units_available number);

INSERT INTO pizzaitems(itemname, units_available) VALUES ('Chicken', 1700);
INSERT INTO pizzaitems(itemname, units_available) VALUES ('Paneer', 1000);
INSERT INTO pizzaitems(itemname, units_available) VALUES ('Corn', 800);
INSERT INTO pizzaitems(itemname, units_available) VALUES ('Tomatoes', 1800);
INSERT INTO pizzaitems(itemname, units_available) VALUES ('Red Chillies', 1800); 

commit;

select * from pizzaitems;

set serveroutput on
declare
  l_old_units_available         pizzaitems.units_available%type; 
  l_new_units_available         pizzaitems.units_available%type;
   
begin
  update pizzaitems
  set    units_available   = 3000 
  where  itemname  = 'Chicken'
  returning old units_available , new units_available 
  into l_old_units_available, l_new_units_available;

  dbms_output.put_line('l_old_units = ' || l_old_units_available); 
  dbms_output.put_line('l_new_units = ' || l_new_units_available); 

  rollback;
END;

--- 09 --- Bulk Update and DML RETURNING Clause Enhancements ---------------------------------

set serveroutput on
declare
  type unit_type is table of pizzaitems.units_available%type;
  l_old_units_available         unit_type; 
  l_new_units_available         unit_type;
   
begin
   
  update pizzaitems
  set    units_available    = units_available+250  
  returning old units_available  , new units_available 
  bulk collect into l_old_units_available, l_new_units_available;
   
  dbms_output.put_line('l_old_units_available.count = ' || l_old_units_available.count);
  
  for i in 1 .. l_old_units_available.count loop
    dbms_output.put_line('row               = ' || i);
    dbms_output.put_line('l_old_units_available         = ' || l_old_units_available(i)); 
    dbms_output.put_line('l_new_units_available         = ' || l_new_units_available(i)); 
  end loop;
 
END;
/ 

select * from pizzaitems;

commit;

--- 10 --- Annotations ---------------------------------------------------------------

drop table if exists pizza_order;

create table pizza_order
( 
    customer_id number,
    order_item varchar2(100) annotations(display_size 'Medium Pizza', 
    pizza_crust 'Thin', pizza_offer 'Festival Offer'), 
    quantity number,
    order_date date default sysdate 
)
annotations (display 'pizza_order_table');

select * from pizza_order;

insert into pizza_order values 
    (1, 'Pops Pizza', 10 , sysdate),
    (2, 'Alien Pizzas', 20, sysdate);

select * from pizza_order;

select object_name, object_type, column_name, annotation_name, annotation_value 
from user_annotations_usage; 

select object_name, column_name, domain_name, annotation_name, annotation_value
from   user_annotations_usage
where  object_name in ( 'PIZZA_ORDER' )
order  by annotation_name, object_name;

commit;

--- 11 --- Domains ------------------------------------------------------------------
 
CREATE DOMAIN if not exists bank_loan_domain AS varchar2(50)
   CONSTRAINT bank_loan_domain_constr
        CHECK (UPPER(VALUE) IN ('HOME-LOAN', 'CAR-LOAN', 'PERSONAL-LOAN', 
        'HOLIDAY-LOAN', 'STUDY-LOAN', 'BUSINESS-LOAN')) 
   DISPLAY SUBSTR(VALUE, 0, 12);

create table if not exists loan_applications (
    application_id  number,
    applicant_name varchar2(255),
    loan_type bank_loan_domain,
    loan_amount number,
    constraint application_id_pk primary  key (application_id)
) ; 

-- this will error out --
INSERT INTO LOAN_APPLICATIONS 
(application_id, applicant_name, loan_type, loan_amount) 
values 
(2, 'James Smith', 'Fun Loan', 25000);

INSERT INTO LOAN_APPLICATIONS 
(application_id, applicant_name, loan_type, loan_amount) 
values (2, 'James Smith', 'HOME-LOAN', 25000);

INSERT INTO LOAN_APPLICATIONS 
(application_id, applicant_name, loan_type, loan_amount) 
values (3, 'Mike Smith', 'CAR-LOAN', 25000);
 
commit;

drop domain if exists email_dom;

create domain email_dom as varchar2(100)
constraint email_chk check (regexp_like (email_dom, '^(\S+)\@(\S+)\.(\S+)$'))
display lower(email_dom)
order   lower(email_dom)
annotations (Description 'Domain for Emails');

-- 12 ----- SQL for Pattern Matching - Fuzzy Match --------------------------------

CREATE TABLE pizzashop 
(
    pizzaname VARCHAR2(100), 
    is_available BOOLEAN
); 

insert into pizzashop 
(pizzaname, is_available) values ('Corn Pizza', true);

insert into pizzashop 
(pizzaname, is_available) values ('Veg Pizza', 1); 

select * from PIZZASHOP;

 
select pizzaname, 
       fuzzy_match(whole_word_match, pizzaname, 'Super Paneer Pizza') as case1,
       fuzzy_match(whole_word_match, pizzaname, 'Super Pizza') as case2,
       fuzzy_match(whole_word_match, pizzaname, 'Corn') as case3,
       fuzzy_match(whole_word_match, pizzaname, 'corn burn pizza', edit_tolerance 50) as case4,
       fuzzy_match(whole_word_match, pizzaname, 'corn pizza', edit_tolerance 50) as case5,
       is_available
from   PIZZASHOP;

-- 13 Oracle Text Search ------------------------------------------------------------

create table pizza_menu (
  id    number,
  item_name  varchar2(100),
  details  varchar2(4000),
  constraint pizza_menu_pk primary  key (id)
);

insert into pizza_menu values
  (1, 'Peppy Paneer Regular Pizza', 'The peppy paneer regular pizza can be opted for if you want to have a quiet and relaxed night without the hassle of cooking food. Enjoy the peppy paneer pizza regular along with watching your favorite movie.Add the desired amount of oregano and chili flakes to your taste.'),
  (2, 'Veg Pizza Mania', 'Surround yourself with the goodness of pizzas from the pizza mania options with your most beloved outlet for Italian food. Decide on the pizzas you prefer and order asap!'),
  (3, 'Onion Pizza', 'An onion pizza will be the perfect blend of crispy onions with the softness of the cheese. Be it thin or regular crust, the taste will always leave you in awe.'),
  (4, 'Cheesy Pizza', 'Cheesy Pizza options are perfect for kids and adults alike. Particularly with PopsPizza’s the quality of the cheese will give you the authentic stringy feel.'),
  (5, 'Capsicum Pizza', 'Another one of the most sought-after flavors would be in the form of a capsicum pizza. If you are picky with your vegetables, you can choose these single ones.'),
  (6, 'Chicken Sausage Pizza', 'The chicken sausage pizza can be ordered like you always do, however, an innovation in this option is that PopsPizza’s is now serving this pizza in a new hand-tossed crust. With chopped-up pieces of chicken sausages on a cheesy pizza in a slightly crispy crust, can you ask for more?');
commit;

CREATE INDEX idx_pizza ON PIZZA_MENU(details)
     INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
     ('FILTER CTXSYS.NULL_FILTER SECTION GROUP CTXSYS.HTML_SECTION_GROUP');

COLUMN details FORMAT a40;

select * from pizza_menu;

SELECT SCORE(1), id, item_name, details FROM PIZZA_MENU 
WHERE CONTAINS(details, 'KIDS', 1) > 0;

SELECT SCORE(1), id, item_name, details FROM PIZZA_MENU 
WHERE CONTAINS(details, 'kids, adults', 1) > 0;

SELECT SCORE(1), id, item_name, details FROM PIZZA_MENU 
WHERE CONTAINS(details, 'chicken sausage', 1) > 0;

---- 14 Built in Spatial functions  --------------------------------

create table unesco_sites_in
(
    ID  NUMBER primary key,
    NAME_EN VARCHAR2(500),
    GEO_LOCATION  SDO_GEOMETRY  NOT NULL
);
/
INSERT INTO unesco_sites_in
(ID, NAME_EN,  GEO_LOCATION) 
VALUES 
(1, 'Group of Monuments at Pattadakal', SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE (15.94833,75.81667, NULL), NULL, NULL));
/
INSERT INTO unesco_sites_in 
(ID, NAME_EN,  GEO_LOCATION) 
VALUES 
(2, 'Khajuraho Group of Monuments', SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE (24.85222,79.92222, NULL), NULL, NULL));
/
INSERT INTO unesco_sites_in 
(ID, NAME_EN,  GEO_LOCATION) 
VALUES 
(3, 'Group of Monuments at Hampi', SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE (15.31444,76.47167, NULL), NULL, NULL));
/
INSERT INTO unesco_sites_in 
(ID, NAME_EN,  GEO_LOCATION) 
VALUES 
(4, 'Ajanta Caves', SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE (20.55333,75.7, NULL), NULL, NULL));
/
INSERT INTO unesco_sites_in 
(ID, NAME_EN,  GEO_LOCATION) 
VALUES 
(5, 'Ellora Caves', SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE (20.02639,75.17917, NULL), NULL, NULL));
/
commit;

select * from unesco_sites_in;


SELECT   
   u.id,
   u.name_en,
   u.geo_location
FROM unesco_sites_in u
where SDO_WITHIN_DISTANCE(
  u.geo_location,
  SDO_GEOMETRY(2001, 8307, 
    SDO_POINT_TYPE(20.02639,75.17917, NULL),NULL, NULL
  ), 
  'distance=10 unit=KM'
) = 'TRUE';
 
---- 15 -- Multilingual Engine (MLE) for JavaScript

create or replace 
function helloworldjs 
    return varchar2 
    as mle language javascript 
    q'~  
        return 'Hello world';
    ~';
    /

select  helloworldjs as sayhello;

create or replace 
    function hellouser ("username" varchar2) 
    return varchar2 
    as mle language javascript 
    q'~ 
        return 'Hello world '+username;
    ~';
    /

select  hellouser ( 'Madhu' ) as sayhello;

-- source code view ------
create or replace 
    function simpleinterest ("P" number, "T" number, "R" number) 
    return number 
    as mle language javascript 
    q'~ 
        return (P * T * R)/1200;
    ~';
    / 

select round(simpleinterest ( 10000, 10, 5 ),2) as js_simp_int;

select TEXT
from   user_source
where  type = 'FUNCTION'
and    name = 'SIMPLEINTEREST'
order by line;

--- 16 JSON_TRANSFORM Enhancements PREPEND, APPEND, SORT ------------------

drop table if EXISTS j_pizza_menu;
-- create table
create table j_pizza_menu (
  id           number,
  pizza_json json,
  constraint j_pizza_menu_pk primary key (id)
);

-- insert JSON data
insert into j_pizza_menu (id, pizza_json) values 
(1, json('{"pizza_menu":[
        {"name":"paneer pizza","quantity":10},
        {"name":"chicken pizza","quantity":15, "crust":"thich"},
        {"name":"corn pizza","quantity":25, "crust":"medium","extras":"cheese" }
        ]}'));
commit;

-- set linesize
set linesize 100 pagesize 1000 long 1000000
column data format a60

-- run select query
select json_serialize(pizza_json pretty) as data from j_pizza_menu;

select json_transform(pizza_json,
                      prepend '$.pizza_menu' = json('{"name":"Hot and spicy pizza","quantity":20}')
                      returning clob pretty) as data
from   j_pizza_menu
where  id = 1;

select json_transform(pizza_json,
                      append '$.pizza_menu' = json('{"name":"Hot and cold pizza","quantity":20}')
                      returning clob pretty) as data
from   j_pizza_menu
where  id = 1;

select json_transform(pizza_json,
                      append '$.pizza_menu' = json('{"name":"Hot and cold pizza","quantity":20}'),
                      sort '$.pizza_menu'
                      returning clob pretty) as data
from   j_pizza_menu
where  id = 1;

--- 17 JSON DUALITY ------

select * from shops

select * from shop_items

create or replace json relational duality view shops_dv as
select json {'shop_id' : s.shop_id,
             'shop_name'   : s.shop_name,
             'location'         : s.location }
from shops s with insert update delete;

select * from shops_dv

insert into shops_dv d (data)
values ('
{
    "shop_id" : 3, 
    "shop_name" : "Jasons TV Shop", 
    "location" : "Ashburn" 
}');
 
insert into shops_dv d (data)
values ('
{
    "shop_id" : 4, 
    "shop_name" : "Pops Burger and Pizza Shop", 
    "location" : "Riverdale" 
}');

SELECT JSON_SERIALIZE (data pretty) from shops_dv
 

 SELECT JSON_SERIALIZE (data pretty) from 
 shops_dv WHERE json_value(data, '$.shop_id') = 2;

SELECT JSON_SERIALIZE (data pretty) from 
shops_dv WHERE json_value(data, '$.shop_name') like 'Pops%';

--- 18 JSON View Update ---------

UPDATE shops_dv
SET data = (' 
      { 
        "shop_id" : 2, 
        "shop_name" : "Pops Burger", 
        "location" : "Riverdale High"
      }
')
WHERE json_value(data, '$.shop_id') = 2;

select * from shops_dv;

commit;

SELECT JSON_SERIALIZE (data pretty) from shops_dv WHERE 
json_value(data, '$.shop_id') = 2;

UPDATE shops_dv
SET data = (' 
      { "_metadata" : 
           { "etag" : "82978CBD3616ADDF85F5ECC8C8B7EF42", 
             "asof" : "0000000005192515"  }, 
      "shop_id" : 2, 
      "shop_name" : 
      "Pops Burger n Pizza Shop", 
      "location" : "Riverdale high" 
      }
')
WHERE json_value(data, '$.shop_id') = 2;

-- running same above query would error out ----

-- Delete Operation on DV

DELETE FROM shops_dv dv WHERE json_value(data, '$.shop_id') = 3;

select * from shops_dv;

select * from shops;

-----19 JSON DV on Master Detail Table ------

create or replace json relational duality view shop_items_dv as
select json {
         'shop_id' : s.shop_id,
         'shop_name'   : s.shop_name,
         'location' : s.location, 
         'shop_items' :
                        [ 
                            select json {
                            'item_no' : si.item_no,
                            'item_name'   : si.item_name,
                            'quantity_available' : si.quantity_available,
                            'unit_price' : si.unit_price  
                            }
                            from shop_items si with insert update delete 
                            where  si.shop_id = s.shop_id 
                        ]
          }
from shops s with insert update delete;

insert into shop_items_dv d (data) values 
('
    {   
        "shop_id" : 3, 
        "shop_name" : "Furniture Shop", 
        "location" : "Ashburn",
        "shop_items" : 
        [ 
            { 
                "item_no" : 1, 
                "item_name" : "Teak wood table", 
                "quantity_available" : 1000, 
                "unit_price" : 12 
            } 
        ] 
    }
')

---19 better Error messages ------------
update shop_items_dv
SET data = ('
{  
    "shop_id" : 1, 
    "shop_name" : "Jasons TV Shop", 
    "location" : "Ashburn", 
    "shop_items" : [ {
                "item_no" : 2, 
                "item_name" : "Sony TV", 
                "quantity_available" : 1000, 
                "unit_price" : 12 
    } ] 
} 
') 

/*
ORA-42603: Cannot update JSON Relational Duality View 'SHOP_ITEMS_DV': 
The Primary Key column(s) of the root table 'SHOPS' cannot be updated, 
omitted, or set to NULL.
ORA-06512: at "SYS.DBMS_SQL", line 1792
*/

---20 Store JSON Column ------------

create table movie_details
(
    ID  NUMBER primary key,
    TITLE VARCHAR2(500),
    MOVIE_META  JSON
);

insert into movie_details (id, title, movie_meta) values
(
    2,
    'Indiana Jones and the Dial of Destiny', 
    '{
        "Director": "James Mangold",
        "Genre": "Action-Adventure",
        "ReleaseDate": "Jun 30, 2023",
        "LeadActor": "Harrison Ford" 
        }'
);

commit;

select id, title, m.MOVIE_META.Director, m.MOVIE_META.Genre
 from movie_details m;

--- 21 Graph Queries -------------

 WITH query as ( 
    select 
    SRC_ACCT_ID as source , 
    DST_ACCT_ID as target  
    from bank_transfers where DESCRIPTION = 'ML'
    AND MERCHANT_STATE != 'United States of America'
),
page AS (
    -- pagination
    SELECT
        *
    FROM
        query
    ORDER BY
        source,
        target OFFSET :page_start ROWS FETCH NEXT :page_size ROWS ONLY
        --target OFFSET 1 ROWS FETCH NEXT 100 ROWS ONLY
),
vertices AS (
    -- fetch employee details and construct JSON
    SELECT
        JSON_OBJECT( 
            'id' VALUE FINBANK_ACCOUNTS.ID,
            'properties' VALUE JSON_OBJECT(
                'FirstName' VALUE FINBANK_ACCOUNTS.FIRST_NAME,
                'LastName' VALUE FINBANK_ACCOUNTS.LAST_NAME, 
                'Department' VALUE FINBANK_ACCOUNTS.DEPARTMENT_ID,
                'HireDate' VALUE FINBANK_ACCOUNTS.ACC_DATE,
                'JobId' VALUE FINBANK_ACCOUNTS.JOB_ID,
                'JobTitle' VALUE jobs.JOB_TITLE,
                'MERCHANT_STATE' VALUE bank_transfers.MERCHANT_STATE,
                'Amount' VALUE bank_transfers.Amount
               
            )
        ) AS vertex
    FROM
        
        FINBANK_ACCOUNTS finbank_accounts 
        LEFT OUTER JOIN EBA_GRAPHVIZ_JOBS jobs ON finbank_accounts.JOB_ID = jobs.JOB_ID
        LEFT OUTER JOIN BANK_TRANSFERS bank_transfers ON finbank_accounts.ID = bank_transfers.SRC_ACCT_ID  
    WHERE
        
        bank_transfers.SRC_ACCT_ID in (
            SELECT
                source
            from
                page
        )
        or bank_transfers.DST_ACCT_ID in (
            SELECT
                target
            from
                page
        )

),
edges AS (
   
    SELECT
        JSON_OBJECT('source' VALUE source, 'target' VALUE target) AS edge
    FROM
        page
)
SELECT
    -- construct the final JSON that GVT accepts.
    JSON_OBJECT(
        'vertices' VALUE (
            SELECT
                JSON_ARRAYAGG(vertex returning clob)
            FROM
                vertices
        ),
        'edges' VALUE (
            SELECT
                JSON_ARRAYAGG(edge returning clob)
            FROM
                edges
        ),
        'numResults' VALUE (
            SELECT
                COUNT(*)
            FROM
                query
        ) returning clob
    ) json
FROM
    SYS.DUAL

--- 23 Blockchain Table -------------

drop table if exists bct_t1 purge;

create blockchain table bct_t1 (
  id            number,
  fruit         varchar2(20),
  quantity      number,
  created_date  date,
  constraint bct_t1_pk primary key (id)
)
no drop until 0 days idle
no delete until 16 days after insert
hashing using "SHA2_512" version "v1";

-- 24 XML Type ----------

CREATE TABLE warehouses(
  warehouse_id NUMBER(3),
  warehouse_spec XMLTYPE,
  warehouse_name VARCHAR2(35),
  location_id NUMBER(4));

INSERT INTO warehouses VALUES 
   (       100, XMLType(
              '<Warehouse whNo="100"> 
               <Building>Owned</Building>
               </Warehouse>'), 'Tower Records', 1003);

select * from warehouses;

commit;

SELECT 
  w.warehouse_spec.extract('/Warehouse/Building/text()')
  .getStringVal() "Building"
  FROM warehouses w;

-- 25 --- FLOOR and CEIL on DATES


select sysdate ,
ceil(sysdate, 'iyyy') as cl, 
ceil(78328.2234 ) as cl2,
floor(sysdate, 'iyyy') as fl,
floor(78328.2234) as fl2 ; 
