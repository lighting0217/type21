# ฟังก์ชันคำนวณ GDD ที่สะสมไว้สำหรับแต่ละแปลง

ฟังก์ชันนี้จะคำนวณและเก็บ GDD ที่สะสมไว้สำหรับแต่ละแปลง โดยจะทำงานทุกวันจันทร์เวลา 8:30 น. (
ตามเวลาประเทศไทย) ฟังก์ชันจะดึงข้อมูลแปลงทั้งหมดจาก Firestore และคำนวณ GDD ที่สะสมไว้โดยการรวมผลรวม
GDD ประจำเดือนทั้งหมดของแปลงนั้น ฟังก์ชันจะบันทึก GDD ที่สะสมไว้ใน Firestore สำหรับแต่ละแปลง

## กำหนดค่าฟังก์ชัน

* ภูมิภาค: asia-southeast1
* หน่วยความจำ: 1GB
* กำหนดเวลาการเรียกใช้: ทุกวันจันทร์เวลา 8:30 น. (ตามเวลาประเทศไทย)
* เขตเวลา: Asia/Bangkok
* ฟังก์ชันการทำงาน: คำนวณและเก็บ GDD ที่สะสมไว้สำหรับแต่ละแปลง

## การทำงาน

1. ดึงข้อมูลแปลงทั้งหมดจาก Firestore
2. สำหรับแต่ละแปลง
    * ดึงข้อมูลอุณหภูมิประจำเดือนทั้งหมดของแปลงนั้นจาก Firestore
    * คำนวณ GDD ที่สะสมไว้โดยการรวมผลรวม GDD ประจำเดือนทั้งหมดของแปลงนั้น
    * หาผลต่างระหว่าง GDD ที่สะสมไว้กับ GDD สูงสุดของแปลง
    * บันทึก GDD ที่สะสมไว้, GDD สูงสุด, และผลต่างใน Firestore สำหรับแปลงนั้น

## ประโยชน์

ฟังก์ชันนี้จะเป็นประโยชน์สำหรับเกษตรกรในการติดตาม GDD ที่สะสมไว้สำหรับแต่ละแปลง
ซึ่งข้อมูลนี้จะสามารถนำไปใช้ในการตัดสินใจเกี่ยวกับการปลูกข้าวและการจัดการแปลงได้ ตัวอย่างเช่น
เกษตรกรสามารถใช้ข้อมูล GDD
ที่สะสมไว้เพื่อกำหนดช่วงเวลาที่เหมาะสมในการหว่านเมล็ดข้าวหรือเริ่มการให้น้ำ

## โค้ด

```javascript
// ฟังก์ชันนี้จะคำนวณและเก็บ GDD ที่สะสมไว้สำหรับแต่ละแปลง
exports.calculateAccumulatedGdd = functions
  .region("asia-southeast1")
  .runWith({memory: "1GB"})
  .pubsub.schedule("30 08 * * 1")
  .timeZone("Asia/Bangkok")
  .onRun(async () => {
    // เริ่มต้นด้วยการดึงข้อมูลแปลงทั้งหมดจาก Firestore
    const fieldsSnapshot = await admin
      .firestore()
      .collection("fields")
      .get();
    console.log("Fetched ${fieldsSnapshot.size} field documents.");

    // สำหรับแต่ละแปลง
    for (const fieldDoc of fieldsSnapshot.docs) {
      // เก็บ ID ของเอกสารแปลง
      const fieldId = fieldDoc.id;
      // เก็บข้อมูลของเอกสารแปลง
      const fieldData = fieldDoc.data();
      // เก็บ GDD สูงสุดของแปลง
      const riceMaxGdd = fieldData.riceMaxGdd || 0;
      console.log(`Processing field: ${fieldId}, Max GDD: ${riceMaxGdd}`);

      // ดึงข้อมูลอุณหภูมิประจำเดือนทั้งหมดของแปลงนั้นจาก Firestore
      const monthlyTemperaturesSnapshot =
        await fieldDoc
          .ref
          .collection("temperatures_monthly")
          .get();

      // เริ่มต้นด้วย GDD ที่สะสมไว้เป็น 0
      let accumulatedGdd = 0;

      // วนซ้ำผ่านเอกสารอุณหภูมิประจำเดือนทั้งหมด
      for (const monthlyDoc of monthlyTemperaturesSnapshot.docs) {
        // เก็บข้อมูลของเอกสารอุณหภูมิประจำเดือน
        const monthlyData = monthlyDoc.data();
        // เพิ่มผลรวมของ GDD ประจำเดือนลงใน GDD ที่สะสมไว้
        accumulatedGdd += (monthlyData.gddSum || 0);
      }

      // หาผลต่างระหว่าง GDD ที่สะสมไว้กับ GDD สูงสุดของแปลง
      const difference = Math.max(0, riceMaxGdd - accumulatedGdd);

      // บันทึก GDD ที่สะสมไว้, GDD สูงสุด, และผลต่างใน Firestore สำหรับแปลงนั้น
      await fieldDoc
        .ref
        .collection("accumulated_gdd")
        .doc("Accumulated GDD")
        .set({
          documentID: fieldId,
          date: admin.firestore.FieldValue.serverTimestamp(),
          accumulatedGdd,
          riceMaxGdd,
          difference,
        });

      // พิมพ์ข้อมูลต่างๆ ออกไปยังคอนโซล
      console.log(
        `Accumulated GDD for field ${fieldId}:
          ${accumulatedGdd}. Difference to maxGDD: ${difference}`);
    }

    // แสดงข้อความว่าการคำนวณ GDD ที่สะสมไว้เสร็จสิ้น
    console.log("Accumulated GDD calculation completed.");
  });
