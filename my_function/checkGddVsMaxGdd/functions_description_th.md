# ฟังก์ชันตรวจสอบ GDD เทียบกับ Max GDD

ฟังก์ชันนี้จะตรวจสอบ GDD ของแปลงแต่ละแปลงเทียบกับ Max GDD ที่กำหนดไว้ โดยจะทำงานทุกวันจันทร์เวลา 8:
00 น. (ตามเวลาประเทศไทย) ฟังก์ชันจะดึงข้อมูลแปลงทั้งหมดและข้อมูลอุณหภูมิประจำเดือนทั้งหมดจาก
Firestore และคำนวณ GDD ของแต่ละแปลง หาก GDD ของแปลงใดเกินกว่า Max GDD
ฟังก์ชันจะพิมพ์ข้อความแจ้งเตือนออกไปยังคอนโซล

## กำหนดค่าฟังก์ชัน

* ภูมิภาค: asia-southeast1
* หน่วยความจำ: 1GB
* กำหนดเวลาการเรียกใช้: ทุกวันจันทร์เวลา 8:00 น. (ตามเวลาประเทศไทย)
* เขตเวลา: Asia/Bangkok
* ฟังก์ชันการทำงาน: ตรวจสอบ GDD ของแปลงแต่ละแปลงเทียบกับ Max GDD ที่กำหนดไว้

## การทำงาน

1. ดึงข้อมูลแปลงทั้งหมดและข้อมูลอุณหภูมิประจำเดือนทั้งหมดจาก Firestore
2. สำหรับแต่ละแปลง
    * คำนวณ GDD ของแปลงนั้น
    * หาก GDD ของแปลงนั้นเกินกว่า Max GDD
        * พิมพ์ข้อความแจ้งเตือนออกไปยังคอนโซล

## ประโยชน์

ฟังก์ชันนี้จะเป็นประโยชน์สำหรับเกษตรกรในการติดตาม GDD ของแปลงแต่ละแปลงและแจ้งเตือนให้เกษตรกรทราบหาก
GDD ของแปลงใดเกินกว่า Max GDD
ซึ่งจะช่วยให้เกษตรกรสามารถตัดสินใจเกี่ยวกับการจัดการแปลงได้อย่างเหมาะสม

## ข้อจำกัด

ฟังก์ชันนี้มีข้อจำกัดบางประการ ดังนี้

* ฟังก์ชันจะคำนวณ GDD โดยใช้อุณหภูมิพื้นฐานสำหรับการเจริญเติบโตของข้าว
  ซึ่งอาจแตกต่างกันไปตามพันธุ์ข้าว
* ฟังก์ชันจะคำนวณ GDD โดยใช้อุณหภูมิเฉลี่ยรายเดือน ซึ่งอาจไม่แม่นยำเท่ากับการวัดอุณหภูมิรายวัน

## โค้ด

```javascript
//ฟังก์ชันตรวจสอบ GDD เทียบกับ Max GDD
exports.checkGddVsMaxGdd = functions
    .region("asia-southeast1")
    .runWith({memory: "1GB"})
    .pubsub.schedule("0 8 * * 1")
    .timeZone("Asia/Bangkok")
    .onRun(async (context) => {
        try {
            // 1. ดึงข้อมูลแปลงทั้งหมดและข้อมูลอุณหภูมิประจำเดือนทั้งหมดจาก Firestore
            const fieldsSnapshot = await admin
                .firestore()
                .collection("fields")
                .get();

            // 2. สำหรับแต่ละแปลง
            for (const fieldDoc of fieldsSnapshot.docs) {
                // เก็บ ID ของเอกสารแปลง
                const fieldId = fieldDoc.id;
                // เก็บข้อมูลของเอกสารแปลง
                const fieldData = fieldDoc.data();
                // เก็บ GDD สูงสุดของแปลง
                const riceMaxGdd = fieldData.riceMaxGdd;

                // 3. คำนวณ GDD ของแปลงนั้น
                const monthlyTemperaturesSnapshot = await fieldDoc
                    .ref
                    .collection("temperatures_monthly")
                    .get();

                const accumulatedGdd = 0;
                for (const monthlyTemperatureDoc of monthlyTemperaturesSnapshot.docs) {
                    const monthlyTemperatureData = monthlyTemperatureDoc.data();
                    const monthlyGddSum = monthlyTemperatureData.gddSum;
                    accumulatedGdd += monthlyGddSum;
                }

                // 4. หาก GDD ของแปลงนั้นเกินกว่า Max GDD
                if (accumulatedGdd >= riceMaxGdd) {
                    // พิมพ์ข้อความแจ้งเตือนออกไปยังคอนโซล
                    console.log(
                        `Field ${fieldId},
                        Month ${monthlyTemperatureData.documentID}: GDD exceeded riceMaxGdd`);
                }
            }

            // 5. พิมพ์ข้อความว่าการตรวจสอบ GDD vs Max GDD เสร็จสิ้น
            console.log("GDD vs Max GDD check completed");
            return null;
        } catch (error) {
            // พิมพ์ข้อความแสดงข้อผิดพลาดออกไปยังคอนโซล
            console.log("Error checking GDD vs Max GDD:", error);
            return null;
        }
    });
