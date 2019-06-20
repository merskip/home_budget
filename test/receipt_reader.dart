import 'package:home_budget/util/receipt_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final receiptReader = ReceiptReader();

  test("Single simple product", () {
    final receipt = receiptReader.read(["Name  1 * 2.00 2.00A", "SUMA PLN 2.00"]);

    expect(receipt.products.length, 1);

    expect(receipt.products[0].text, "Name");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 2.0);
    expect(receipt.products[0].totalAmount, 2.0);
    expect(receipt.products[0].taxLevel, "A");

    expect(receipt.totalAmount, 2.0);
    expect(receipt.isMalformed(), false);
  });

  test("Multi simple product", () {
    final receipt = receiptReader.read(["Name  1 * 2.00 2.00A", "Second name  2.00 x3.00  6.00B", "SUMA PLN 8.00"]);

    expect(receipt.products.length, 2);

    expect(receipt.products[0].text, "Name");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 2.0);
    expect(receipt.products[0].totalAmount, 2.0);
    expect(receipt.products[0].taxLevel, "A");

    expect(receipt.products[1].text, "Second name");
    expect(receipt.products[1].amount, 2.0);
    expect(receipt.products[1].unitPrice, 3.0);
    expect(receipt.products[1].totalAmount, 6.0);
    expect(receipt.products[1].taxLevel, "B");

    expect(receipt.totalAmount, 8.0);
    expect(receipt.isMalformed(), false);
  });

  test("Multiline products", () {
    final receipt = receiptReader.read(["Name", "1 * 2.00 2.00A", "Second name 2 * 3.00", "6.00B", "SUMA PLN 8.00"]);

    expect(receipt.products.length, 2);

    expect(receipt.products[0].text, "Name");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 2.0);
    expect(receipt.products[0].totalAmount, 2.0);
    expect(receipt.products[0].taxLevel, "A");

    expect(receipt.products[1].text, "Second name");
    expect(receipt.products[1].amount, 2.0);
    expect(receipt.products[1].unitPrice, 3.0);
    expect(receipt.products[1].totalAmount, 6.0);
    expect(receipt.products[1].taxLevel, "B");

    expect(receipt.totalAmount, 8.0);
    expect(receipt.isMalformed(), false);
  });

  test("Kantyna N14", () {
    final receipt = receiptReader.read(
      "TALIS\nKANTY\nKA2 Sp. 20.0.\nKANTYNA N14\nul. Naleczowska 14, 20-701 Lublin\n"
        "Facebook @Kant ynaN 14\n"
        "NIP 9462675530\n2019-06-17 13:27\n46869\n"
        "PARAGON FISKALNY\n"
        "DANIE 3\n1 x16,00 16,00B\n"
        "SPRZEDAZ OPODATK. B\n16,00\n"
        "PTU B 8,00 %\n1,19\n"
        "SUMA PTU\n1,19\nSUMA PLN\n16,00\n"
        "00237 #00000001 PRACOWNIK\n"
        "2019-06-17 13:27\nA2401F ZABOE96036405A76C6FDAD753175440492\n"
        "IP CAB 1501223054\n002r\nroom\n"
        .split("\n")
    );

    expect(receipt.products.length, 1);

    expect(receipt.products[0].text, "DANIE 3");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 16.0);
    expect(receipt.products[0].totalAmount, 16.0);
    expect(receipt.products[0].taxLevel, "B");

    expect(receipt.totalAmount, 16.0);
    expect(receipt.isMalformed(), false);
  });

  test("Restauracha BACHUS", () {
    final receipt = receiptReader.read(
      "RESTAURACJA BACHUS\nPaulina Zięcina\n"
        "20-410 Lublin, ul. 1-go Maja 32\n"
        "NIP 9462389681\n"
        "2019-06-16 17:45\n13111\n"
        "PARAGON FISKALNY\n"
        "FORSZMAK LUBELSKI\n1 x9,00 9,00B\n"
        "FURA FRYTEK Z KETCH. SOSEM CZOSNKOWYM\n1 x8,00 8,00B\n"
        "DLA TRADYCJONALISTOW 1 x18,00 18,00B\n"
        "ROLADKA DELUXE\n1 x18,00 18,00B\n"
        "W LESNEJ CHACIE\n1 x18,00 18,00B\n"
        "PIEROGI RUSKIE\n1 x9,00 9,00B\n"
        "MIZERIA\n1 x4,50 4,50B\n"
        "DZBANEK NIEGAZ. NAPOJU 1,2L\n1 x12,00 12,00A\n"
        "2.24\n8,50\n"
        "SPRZEDAZ OPODATKOWANA A\n12,00\nPTU A 23,00 %\n"
        "SPRZEDAZ OPODATKOWANA B 84,50\nPTU B 8,00 %\n6,26\n"
        "SUMA PTU\nSUMA PLN 96,50\n"
        "00020 #001 KIEROWNIK 2019-06-16 17:45\n"
        "C42FCEBABAC 493C6E64699153F 428237A99A5E76\n"
        "P CH0 160 1467635\nNr sys. 15591\nInna Fp.Inna\n96,50 PLN\n"
        .split("\n")
    );

    expect(receipt.products.length, 8);

    expect(receipt.products[0].text, "FORSZMAK LUBELSKI");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 9.0);
    expect(receipt.products[0].totalAmount, 9.0);
    expect(receipt.products[0].taxLevel, "B");

    expect(receipt.products[1].text, "FURA FRYTEK Z KETCH. SOSEM CZOSNKOWYM");
    expect(receipt.products[1].amount, 1.0);
    expect(receipt.products[1].unitPrice, 8.0);
    expect(receipt.products[1].totalAmount, 8.0);
    expect(receipt.products[1].taxLevel, "B");

    expect(receipt.products[2].text, "DLA TRADYCJONALISTOW");
    expect(receipt.products[2].amount, 1.0);
    expect(receipt.products[2].unitPrice, 18.0);
    expect(receipt.products[2].totalAmount, 18.0);
    expect(receipt.products[2].taxLevel, "B");

    expect(receipt.products[3].text, "ROLADKA DELUXE");
    expect(receipt.products[3].amount, 1.0);
    expect(receipt.products[3].unitPrice, 18.0);
    expect(receipt.products[3].totalAmount, 18.0);
    expect(receipt.products[3].taxLevel, "B");

    expect(receipt.products[4].text, "W LESNEJ CHACIE");
    expect(receipt.products[4].amount, 1.0);
    expect(receipt.products[4].unitPrice, 18.0);
    expect(receipt.products[4].totalAmount, 18.0);
    expect(receipt.products[4].taxLevel, "B");

    expect(receipt.products[5].text, "PIEROGI RUSKIE");
    expect(receipt.products[5].amount, 1.0);
    expect(receipt.products[5].unitPrice, 9.0);
    expect(receipt.products[5].totalAmount, 9.0);
    expect(receipt.products[5].taxLevel, "B");

    expect(receipt.products[6].text, "MIZERIA");
    expect(receipt.products[6].amount, 1.0);
    expect(receipt.products[6].unitPrice, 4.5);
    expect(receipt.products[6].totalAmount, 4.5);
    expect(receipt.products[6].taxLevel, "B");

    expect(receipt.products[7].text, "DZBANEK NIEGAZ. NAPOJU 1,2L");
    expect(receipt.products[7].amount, 1.0);
    expect(receipt.products[7].unitPrice, 12.0);
    expect(receipt.products[7].totalAmount, 12.0);
    expect(receipt.products[7].taxLevel, "A");

    expect(receipt.totalAmount, equals(96.50));
    expect(receipt.isMalformed(), equals(false));
  });

  test("Sklep ŻABKA", () {
    final receipt = receiptReader.read(
      "Sklep \"ŻABKA\" 25728\nPHU PATMIC Patrycja Minicka\n"
        "20-701 Lublin, ul. Nałęczowska 18/157\nNIP 5641794456\n2019-06-18\nnr wydr.077614/0111\n"
        "PARAGON FISKALNY\n"
        "WODA N.GAZ 1,5L A 1 * 2,70 zł. 2,70 A\n"
        "WAFLE PRYNCYPALKI 235G A\n1 * 6,79 zł. 6,79 A\n"
        "DROZDZOWKA MIESZANA 0,1 B\n1 * 1,95 zł. 1,95 B\n1\n"
        "Sprzed. opod. PTU A\nKwota A 23,00%\n"
        "Sprzed. opod. PTU B\nKwota B 08,00%\n"
        "Podatek PTU\n9,49\n1,77\n1,95\n0,14\n1,91\nSUMA PLN\n11,44\n"
        "000132 #1 4 kasjer_1\n09:03\n595007351DD8D37FF5192A137A3918273CDDDAEE\nE CCO 1701485318\npłatność\nkarta kred. 11,44\n"
        "RAZEM PLN\n1,44\nNr transakcji\n50094\n"
        .split("\n")
    );

    expect(receipt.products.length, 3);

    expect(receipt.products[0].text, "WODA N.GAZ 1,5L A");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 2.7);
    expect(receipt.products[0].totalAmount, 2.7);
    expect(receipt.products[0].taxLevel, "A");

    expect(receipt.products[1].text, "WAFLE PRYNCYPALKI 235G A");
    expect(receipt.products[1].amount, 1.0);
    expect(receipt.products[1].unitPrice, 6.79);
    expect(receipt.products[1].totalAmount, 6.79);
    expect(receipt.products[1].taxLevel, "A");

    expect(receipt.products[2].text, "DROZDZOWKA MIESZANA 0,1 B");
    expect(receipt.products[2].amount, 1.0);
    expect(receipt.products[2].unitPrice, 1.95);
    expect(receipt.products[2].totalAmount, 1.95);
    expect(receipt.products[2].taxLevel, "B");

    expect(receipt.totalAmount, equals(11.44));
    expect(receipt.isMalformed(), equals(false));
  });

  test("Stacja paliw ORLEN", () {
    final receipt = receiptReader.read(
      "ORLEN\n--------\nPolski Koncern Naf towy ORLEN S.A.\n09-411 PŁOCK, UL. CHEMIKOW 7\n"
        "STACJA PALIW NR 0474 W LUBLINIE\nUL. GŁĘBOKA 32, 20-612 LUBLIN\n"
        "BDO 000007103\nNIP: 774-00-01-454\n18-06-2019 16:37\nW1050846\n"
        "PARAGON FISKALNY\n"
        "VERVA 98 CN27101249.D(4) (A) 26.46*5.67\n150.03A\n"
        "SP.OP.A: 150.03 PTU 23%\n28.05\n"
        "Suma PTU:\n28.05\nSuma:\nPLN 150.03\n"
        "F506050 # 11\\K1 Kasjer :68 18-06-2019 16:37\n7rrjXML17SQUiUG1MEECMUESKVE= 05\nP CAJ 1501321178\n"
        "Przystąp do programu VITAY\nKlienci VITAY za tę transakcję otrzymują:\n208 PKT\n.. 150.03\nkarta:\n........\n101149838\n"
        .split("\n")
    );

    expect(receipt.products.length, 1);

    expect(receipt.products[0].text, "VERVA 98 CN27101249.D(4) (A)");
    expect(receipt.products[0].amount, 26.46);
    expect(receipt.products[0].unitPrice, 5.67);
    expect(receipt.products[0].totalAmount, 150.03);
    expect(receipt.products[0].taxLevel, "A");

    expect(receipt.totalAmount, equals(150.03));
    expect(receipt.isMalformed(), equals(false));
  });

  test("Sklep Stokrotka Express", () {
    final receipt = receiptReader.read(
      "Stokrotka Sp. z o.o.\n20-209 Lublin, ul. Projektowa 1\n"
        "Stokrotka Express 487\n20-046 Lublin, ul. Puławska 5\n"
        "NIP 712-10-08-323\n2019-06-07 21:35\n254903\n"
        "PARAGON FISKALNY\n"
        "D LA LORRAINE BULKA D 4x0,69 2,76D\n"
        "D LA LORRAINE KAJZERK 2 x0,49 0,98D\n"
        "D SOK HORTEX 1L POMAR 1 x4,99 4,99D\n"
        "A MUSZTARDA KAMIS 185 1 X2,29 2,29A\n"
        "D GRELA MELGIEW CHLEB 1 x2,29 2,29D\n"
        "SPRZEDAZ OPODATKOWANA A\nPTU A 23.00 %\n"
        "SPRZEDAZ OPODATKOWANA D\nPTU D 5,00 %\n"
        "SUMA PTU\nSUMA PLN 13,31\n00443 #01 1\n2.29\n0,43\n11,02\n0,52\n0.95\n2019-06-07 21:35\n"
        "OF M47703CF7B19630213898CDD520971\n- Cho 1601464238\nNr sys. 061215\nKarta MAGNETYCZNA\n13,31 PLN\n"
        .split("\n")
    );
    expect(receipt.products.length, 5);

    expect(receipt.products[0].text, "D LA LORRAINE BULKA D");
    expect(receipt.products[0].amount, 4);
    expect(receipt.products[0].unitPrice, 0.69);
    expect(receipt.products[0].totalAmount, 2.76);
    expect(receipt.products[0].taxLevel, "D");

    expect(receipt.products[1].text, "D LA LORRAINE KAJZERK");
    expect(receipt.products[1].amount, 2);
    expect(receipt.products[1].unitPrice, 0.49);
    expect(receipt.products[1].totalAmount, 0.98);
    expect(receipt.products[1].taxLevel, "D");

    expect(receipt.products[2].text, "D SOK HORTEX 1L POMAR");
    expect(receipt.products[2].amount, 1);
    expect(receipt.products[2].unitPrice, 4.99);
    expect(receipt.products[2].totalAmount, 4.99);
    expect(receipt.products[2].taxLevel, "D");

    expect(receipt.products[3].text, "A MUSZTARDA KAMIS 185");
    expect(receipt.products[3].amount, 1);
    expect(receipt.products[3].unitPrice, 2.29);
    expect(receipt.products[3].totalAmount, 2.29);
    expect(receipt.products[3].taxLevel, "A");

    expect(receipt.products[4].text, "D GRELA MELGIEW CHLEB");
    expect(receipt.products[4].amount, 1);
    expect(receipt.products[4].unitPrice, 2.29);
    expect(receipt.products[4].totalAmount, 2.29);
    expect(receipt.products[4].taxLevel, "D");

    expect(receipt.totalAmount, equals(13.31));
    expect(receipt.isMalformed(), equals(false));
  });

  test("Sklep Tiger", () {
    final receipt = receiptReader.read(
      "Tiger Warsaw Sp. z 0.0.\nul. Lipowa 13, 20-020 Lublin\nwww.flyingtiger.com\n"
        "Sklep PL 122: Kasa nr. 2\nBDO: 000109311\n124277\nNIP 5222988977\n2019-06-18 20:28\n"
        "PARAGON FISKALNY\n"
        "Miarka kuchenna 425 ml 1014 2 A\n1szt x10,00 10,00A"
        "\n-\n-\n-\n-\n10,00\nSPRZEDAZ OPODATKOWANA A\n1,87\nPTU A 23,00 %\n"
        "SUMA PTU\n1,87\nSUMA PLN\n10.00\n"
        "2019-06-18 20:28\n00272 #2 45\nC23E12672815F629772CBDC6A3202B3155480906\n- Cho 1601463553\n"
        "10,00 PLN\nKarta karta płatnicza\n126039\nAl transakciji\n"
        .split("\n")
    );
    expect(receipt.products.length, 1);

    expect(receipt.products[0].text, "Miarka kuchenna 425 ml 1014 2 A");
    expect(receipt.products[0].amount, 1);
    expect(receipt.products[0].unitPrice, 10.0);
    expect(receipt.products[0].totalAmount, 10.0);
    expect(receipt.products[0].taxLevel, "A");

    expect(receipt.totalAmount, equals(10.0));
    expect(receipt.isMalformed(), equals(false));
  });
}
