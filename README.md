# MCU Cinematic Universe Data Warehouse & Analysis

## Project Overview
โปรเจกต์นี้เริ่มต้นจากการนำ Dataset ดิบของภาพยนตร์ MCU มาทำการ **Data Modeling** ใหม่เพื่อเปลี่ยนจาก Flat Table ให้เป็นระบบ Relational Database เพื่อรองรับการวิเคราะห์ที่ซับซ้อน และนำไปสร้าง Interactive Dashboard เพื่อหา Insight ทางการเงินและคำวิจารณ์

## 1.Database Design (ER Diagram)
ได้ทำการ **Normalization** เพื่อแยก Entity ออกเป็นตารางย่อย เพื่อลดความซ้ำซ้อนของข้อมูลและเพิ่มความสะดวกในการจัดการข้อมูล (Data Integrity)

![MCU ER Diagram](Er_Diagram.png)

### Key Design Features:
* **Many-to-Many Relationship:** ใช้ตาราง 'movie_crew' เพื่อเชื่อมโยงระหว่างภาพยนตร์และทีมงาน(director/producer)
* **One-to-One Relationship:** แยกตาราง 'finance' และ 'score' ที่เชื่อมกับ ตาราง 'movie'
* **Data Constraints:** มีการใช้ 'Primary Key', 'Foreign Key'

## 2.Data Pipeline & SQL Techniques
ผมใช้ SQL ในการจัดการข้อมูลตั้งแต่ขั้นตอน Staging ไปจนถึงขั้นตอนสุดท้าย โดยมีเทคนิคที่สำคัญดังนี้:

* **Data Cleaning:** ใช้ 'REPLACE' และ 'TRIM' เพื่อกรองชื่อบุคคลและสัญลักษณ์พิเศษ
* **Dynamic Extraction:** ใช้ 'string_to_array' กับ 'unnest' เพื่อแยกรายชื่อผู้กำกับและโปรดิวเซอร์ที่อยู๋รวมกันมาให้เเยกชื่อคนทีละคนออกมาเป็นรายบรรทัด
* **Casting & Transformation:** ใช้ 'USING col::type' เพื่อแปลงข้อมูลจาก TEXT ให้เป็น NUMERIC/INTEGER

> 📂 *โค้ด SQL:* `SQLcode.sql`

## 3.Interactive Dashboard & Insights
ข้อมูลที่ผ่านการ Clean แล้วถูกนำไป Visualize ด้วย **Tableau** เพื่อหา insight โดย Dashboard นี้ถูกออกแบบมาให้สามารถดูภาพรวมและเจาะลึกข้อมูลรายภาพยนตร์ได้

![MCU Analysis Dashboard](Dashboard.png)

### Key Insights :
* **Financial Performance:** Phase 3 เป็นช่วงที่ทำกำไร (Profit) สูงสุดอย่างก้าวกระโดดเมื่อเทียบกับ Phase อื่นๆ
* **Critical Success:** ภาพยนตร์ที่มีคะแนนจากฝั่ง Audience สูงมักจะมีรายได้แบบ Domestic Box Office สูงตามกัน
* **Director Impact:** สามารถระบุผู้กำกับที่คุมงบประมาณ (Budget) ได้อย่างมีประสิทธิภาพและสร้างผลตอบแทนได้ดีที่สุด
