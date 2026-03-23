onBootstrap((e) => {
  console.log("🔥 HOOK CHARGÉ 🔥");
  e.next();

  function runSync() {
    console.log("Début sync product_recalls...");

    let res;
    try {
      res = $http.send({
        url: "https://codelabs.formation-flutter.fr/assets/rappels.json",
        method: "GET",
        timeout: 120,
      });
    } catch (err) {
      console.log("Erreur HTTP rappels:", err);
      return;
    }

    console.log("STATUS:", res.statusCode);

    if (res.statusCode !== 200) {
      console.log("Erreur API rappels:", res.statusCode);
      return;
    }

    const items = Array.isArray(res.json) ? res.json : [];
    console.log("Nombre d'items trouvés:", items.length);

    const collection = $app.findCollectionByNameOrId("product_recalls");

    for (let i = 0; i < items.length; i++) {
      const item = items[i];

      const externalId = toStr(item.id);
      const barcode = toStr(item.gtin);

      if (!externalId || !barcode || barcode.length < 8) {
        continue;
      }

      let record;
      try {
        record = $app.findFirstRecordByFilter(
          "product_recalls",
          "external_id = {:id}",
          { id: externalId }
        );
      } catch (_) {
        record = new Record(collection);
      }

      record.set("external_id", externalId);
      record.set("barcode", barcode);
      record.set("product_name", toStr(item.modeles_ou_references));
      record.set("brand", toStr(item.marque));
      record.set("image_url", firstImage(item.liens_vers_les_images));
      record.set("recall_title", buildRecallTitle(item));
      record.set("recall_reason", toStr(item.motif_rappel));
      record.set(
        "risk_description",
        firstNotEmpty([
          item.risques_encourus,
          item.description_complementaire_risque,
        ])
      );
      record.set("geographic_area", toStr(item.zone_geographique_de_vente));
      record.set(
        "distribution_channels",
        firstNotEmpty([
          item.noms_des_distributeurs,
          item.distributeurs,
        ])
      );
      record.set(
        "additional_information",
        firstNotEmpty([
          item.informations_complementaires_publiques,
          item.modalites_de_compensation,
          item.conditionnements,
          item.temperature_conservation,
        ])
      );
      record.set(
        "consumer_guidance",
        formatConsumerGuidance(item.conduites_a_tenir_par_le_consommateur)
      );
      record.set("pdf_url", toStr(item.lien_vers_affichette_pdf));
      record.set("source_url", toStr(item.lien_vers_la_fiche_rappel));
      record.set("recall_date", normalizeDateTime(item.date_publication));
      record.set(
        "marketing_start_date",
        normalizeDate(item.date_debut_commercialisation)
      );
      record.set(
        "marketing_end_date",
        normalizeDate(item.date_date_fin_commercialisation)
      );
      record.set("is_active", isRecallActive(item));

      try {
        $app.save(record);
      } catch (_) {}
    }

    console.log("Fin sync product_recalls.");
  }

  function buildRecallTitle(item) {
    const marque = toStr(item.marque);
    const produit = toStr(item.modeles_ou_references);
    if (marque && produit) return marque + " - " + produit;
    return produit || marque || "";
  }

  function firstImage(value) {
    const text = toStr(value);
    if (!text) return "";
    if (text.indexOf("|") !== -1) return text.split("|")[0].trim();
    return text;
  }

  function formatConsumerGuidance(value) {
    const text = toStr(value);
    if (!text) return "";
    return text
      .split("|")
      .map((s) => s.trim())
      .filter((s) => s.length > 0)
      .join("\n");
  }

  function isRecallActive(item) {
    const endDate = normalizeDate(item.date_de_fin_de_la_procedure_de_rappel);
    if (!endDate) return true;

    const todayStr = new Date().toISOString().slice(0, 10);
    return endDate >= todayStr;
  }

  function firstNotEmpty(values) {
    for (let i = 0; i < values.length; i++) {
      const v = toStr(values[i]);
      if (v) return v;
    }
    return "";
  }

  function toStr(value) {
    if (value === null || value === undefined) return "";
    return String(value).trim();
  }

  function normalizeDate(value) {
    const v = toStr(value);
    return v || "";
  }

  function normalizeDateTime(value) {
    const v = toStr(value);
    return v || "";
  }

  cronAdd("sync_product_recalls", "0 6,18 * * *", () => {
    console.log("🕒 CRON sync_product_recalls déclenché");
    runSync();
  });
});