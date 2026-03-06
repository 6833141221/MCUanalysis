
//DATA STAGING AND IMPORT
//สร้างตารางเตรียมรับข้อมูลจาก dataset ที่ได้มาใส่ในตาราง
//สร้าง data type เป็น text ก่อนป้องกัน error บางข้อมูลที่มีเครื่องหมายพิเศษ

CREATE TABLE mcu_staging1(
	phase TEXT,
	film TEXT,
	year_release TEXT,
	us_release_date TEXT,
	gross_us_canada TEXT,
	gross_other TEXT,
	gross_world TEXT,
	rank_us_canada TEXT,
	rank_world TEXT,
	rt_rating TEXT,
	cinemascore TEXT,
	budget TEXT,
	director TEXT,
	producer TEXT,
	movie_image TEXT
);

CREATE TABLE mcu_staging2(
	movie_title TEXT,
	mcu_phase TEXT,
	release_date TEXT,
	imdb_rating TEXT,
	tomato_meter TEXT,
	audience_score TEXT,
	movie_duration TEXT,
	production_budget TEXT,
	open_weekend TEXT,
	domestic_box TEXT,
	international_box TEXT,
	worldwide_box TEXT
);





//DATA TRANSFORMATION
//casting ข้อมูลให้ถูกต้องนำไปใช้คำนวณได้

alter table mcu_staging1
alter column year_release type integer using year_release::integer,
alter column gross_us_canada type bigint using gross_us_canada::bigint,
alter column gross_other type bigint using gross_other::bigint,
alter column gross_world type bigint using gross_world::bigint,
alter column rank_us_canada type integer using rank_us_canada::integer,
alter column rank_world type integer using rank_world::integer,
alter column rt_rating type integer using rt_rating ::integer,
alter column budget type bigint using budget::bigint

alter table mcu_staging2
alter column imdb_rating type decimal(3,1) using imdb_rating::decimal(3,1),
alter column tomato_meter type integer using tomato_meter::integer,
alter column audience_score type integer using audience_score::integer,
alter column movie_duration type integer using movie_duration::integer,
alter column production_budget type bigint using production_budget::bigint,
alter column open_weekend type bigint using open_weekend::bigint,
alter column domestic_box type bigint using domestic_box::bigint,
alter column international_box type bigint using international_box::bigint,
alter column worldwide_box type bigint using worldwide_box::bigint




//MASTER TABLE
//สร้างตารางหลักโดยนำ data จากตารางทั้ง 2 อันที่ผ่านการ data cleaning เเล้วมา join กัน	

create table mcu_master_table as
select
	t1.film,
	t1.phase,
	t1.year_release,
	t1.director,
	t1.producer,
	t2.imdb_rating,
	t2.tomato_meter,
	t2.audience_score,
	t2.movie_duration,
	t2.production_budget,
	t2.open_weekend,
	t2.domestic_box,
	t2.international_box,
	t2.worldwide_box,
	t1.movie_image,
	t1.budget
from mcu_staging1 t1
join mcu_staging2 t2 on trim(t1.film)=trim(t2.movie_title);





//FINAL SCHEMA 
//ออกแบบฐานข้อมูลแบบ Relational Model
//เพื่อความสะดวกในการจัดการข้อมูลให้มีความถูกต้อง (Data Integrity)


CREATE TABLE phase (
    phase_id INT PRIMARY KEY,
    phase_name VARCHAR(50) NOT NULL UNIQUE
);

//ตารางบทบาทหน้าที่ (Director,Producer)
CREATE TABLE roles (
    roles_id INT PRIMARY KEY,
    roles_name VARCHAR(50) NOT NULL
);

//ตารางรายชื่อบุคคล
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    person_name VARCHAR(255) NOT NULL
);

//ตารางข้อมูลภาพยนตร์หลัก
CREATE TABLE movie (
    movie_id SERIAL PRIMARY KEY,
    phase_id INT NOT NULL,
    movie_name VARCHAR(255) NOT NULL,
    year_release INT CHECK(year_release >= 2008),
    movie_duration INT NOT NULL,
    movie_image TEXT NOT NULL,
    CONSTRAINT fk_movie_phase FOREIGN KEY (phase_id) REFERENCES phase(phase_id)
);

//ตารางข้อมูลทางการเงิน
CREATE TABLE finance (
    finance_id SERIAL PRIMARY KEY,
    movie_id INT NOT NULL UNIQUE,
    domestic_box NUMERIC(15,2) NOT NULL,
    international_box NUMERIC(15,2) NOT NULL,
    budget NUMERIC(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    CONSTRAINT fk_finance_movie FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE CASCADE
);

//ตารางคะแนนรีวิว
CREATE TABLE score (
    score_id SERIAL PRIMARY KEY,
    movie_id INT NOT NULL UNIQUE,
    imdb DECIMAL(3,1) NOT NULL,
    tomato DECIMAL(3,1) NOT NULL,
    audience DECIMAL(4,1) NOT NULL,
    CONSTRAINT fk_score_movie FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE CASCADE
);

//ตารางความสัมพันธ์ระหว่างหนังและทีมงาน
CREATE TABLE movie_crew (
    movie_id INT NOT NULL,
    roles_id INT NOT NULL,
    person_id INT NOT NULL,
    PRIMARY KEY (movie_id, roles_id, person_id),
    CONSTRAINT fk_movie_crew_movie_id FOREIGN KEY (movie_id) REFERENCES movie(movie_id),
    CONSTRAINT fk_movie_crew_roles_id FOREIGN KEY (roles_id) REFERENCES roles(roles_id),
    CONSTRAINT fk_movie_crew_person_id FOREIGN KEY (person_id) REFERENCES person(person_id)
);




DATA DISTRIBUTION
//กระจายข้อมูลจากตาราง master เข้าตารางย่อยที่เราออกเเบบมา

insert into roles(roles_id,roles_name) 
values (1,'director'),(2,'producer');

insert into phase(phase_id,phase_name)
values (1,'Phase One'),(2,'Phase Two'),(3,'Phase Three'),(4,'Phase Four'),(5,'Phase Five');

insert into movie(movie_name,phase_id,year_release,movie_duration,movie_image)
select film,p.phase_id,year_release,movie_duration,movie_image
from mcu_master_table
join phase p on phase=p.phase_name

insert into finance(movie_id,domestic_box,international_box,budget)
select m.movie_id,domestic_box,international_box,budget
from mcu_master_table join movie m on m.movie_name=film

insert into score(movie_id,imdb,tomato,audience)
select m.movie_id,imdb_rating,tomato_meter,audience_score
from mcu_master_table
join movie m on m.movie_name=film

CREATE TABLE raw_people AS
SELECT DISTINCT unnest(string_to_array(replace(replace(lower(director),' & ',','),' and ',','),',')) as raw_name
FROM mcu_master_table
UNION
SELECT DISTINCT unnest(string_to_array(replace(replace(replace(lower(producer),' & ',','),' and ',','),'and',','),',') as raw_name
FROM mcu_master_table;

insert into person (person_name)
SELECT DISTINCT TRIM(raw_name) 
FROM raw_people

insert into movie_crew(movie_id,person_id,roles_id)
select movie_id,person_id,1 as roles
from mcu_master_table mc
join movie m on mc.film=m.movie_name
cross join lateral unnest(string_to_array(replace(replace(lower(mc.director),' & ',','),' and ',','),',')) as raw_name
join person p on p.person_name = trim(raw_name)

insert into movie_crew(movie_id,person_id,roles_id)
select movie_id,person_id,2 as roles
from mcu_master_table mc
join movie m on mc.film=m.movie_name
cross join lateral unnest(string_to_array(replace(replace(replace(lower(mc.producer),' & ',','),' and ',','),'and',','),',')) as raw_name
join person p on p.person_name = trim(raw_name)





//เพิ่มเติมในส่วนของตาราง finance
SELECT 
    finance_id,
	movie_id,
    domestic_box,
    international_box,
    budget,
    (domestic_box + international_box) AS total_box_office,
    (domestic_box + international_box - budget) AS net_profit,
	currency
FROM finance;




//นำออกเป็นไฟล์ csv เพื่อไปทำ dashboard
select * from movie
select * from phase
select * from finance
select * from score
select * from movie_crew
select * from person
select * from roles






........ขอบคุณครับผม
