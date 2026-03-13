cronAdd("sync_rappels", "0 6,18 * * *", () => {
  const res = $http.send({
    url: "https://codelabs.formation-flutter.fr/assets/rappels.json",
    method: "GET",
  });

  if (res.statusCode !== 200) {
    return;
  }

  const rappels = res.json;

  for (let i = 0; i < rappels.length; i++) {
    const item = rappels[i];
    const gtin = item.gtin;

    if (!gtin) continue;

    let record = null;

    try {
      record = $app.findFirstRecordByFilter(
        "rappels",
        "gtin = {:gtin}",
        { gtin: gtin },
      );
    } catch (_) {
      record = null;
    }

    if (record) {
      record.set("payload", item);
      $app.save(record);
    } else {
      const newRecord = new Record(
        $app.findCollectionByNameOrId("rappels"),
      );
      newRecord.set("gtin", gtin);
      newRecord.set("payload", item);
      $app.save(newRecord);
    }
  }
});