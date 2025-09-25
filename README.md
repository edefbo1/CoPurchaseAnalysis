# CoPurchaseAnalysis - Strong Scalability Benchmarking

Questo progetto implementa un'analisi di co-acquisto utilizzando **Scala** e **Apache Spark**, eseguibile su **Google Cloud Dataproc**. Lo scopo è calcolare quante volte coppie di prodotti vengono acquistate insieme e valutare la scalabilità del job aumentando il numero di nodi.

---

## Struttura del progetto

- `src/main/scala/copurchase/CoPurchaseAnalysis.scala`  
  Punto di ingresso del programma Spark.
- `src/main/scala/copurchase/PairCounter.scala`  
  Logica per il calcolo delle co-occorrenze tra coppie di prodotti.
- `order_products.csv`  
  File CSV di input contenente coppie `(order_id, product_id)`.
- `powershell_benchmark.ps1`  
  Script PowerShell per creare cluster Dataproc, eseguire il job Spark e registrare i risultati della scalabilità.

---

## Requisiti

- Google Cloud account con progetto attivo.
- Google Cloud SDK installato e configurato (`gcloud`).
- Bucket GCS contenente:
  - Il JAR compilato del progetto (`copurchaseanalysis_2.12-0.1.jar`).
  - File CSV di input (`order_products.csv`).
- Scala e SBT per compilare il progetto localmente (opzionale se si usa solo il JAR su Dataproc).

---

## Parametri di configurazione

Modifica le variabili nello script `powershell_benchmark.ps1` secondo il tuo progetto e bucket:

```powershell
$PROJECT     = ""
$REGION      = "europe-west1"
$ZONE        = "europe-west1-b"
$BUCKET      = ""
$JAR         = "gs://$BUCKET/copurchaseanalysis_2.12-0.1.jar"
$INPUT       = "gs://$BUCKET/input/order_products.csv"
$OUTPUT_BASE = "gs://$BUCKET/output"
$WORKERS_LIST = @(1,2,3,4,5,6)
$CSV_FILE    = "scalability_results.csv"
```

## Caricamento su bucket

```bash
sbt package
# Il JAR generato sarà in target/scala-2.12/copurchaseanalysis_2.12-0.1.jar
# Copialo nel bucket GCS:
gsutil cp target/scala-2.12/copurchaseanalysis_2.12-0.1.jar gs://<YOUR_BUCKET_NAME>/
gsutil cp order_products.csv gs://<YOUR_BUCKET_NAME>/input/

```

## Esecuzione script
```powershell
.\powershell_benchmark.ps1
```