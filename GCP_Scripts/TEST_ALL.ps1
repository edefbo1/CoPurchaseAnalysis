# ================================
# Strong Scalability Benchmarking
# ================================

# Parametri di progetto
$PROJECT   = ""
$REGION    = "europe-west1"
$ZONE      = "europe-west1-b"
$BUCKET    = ""
$JAR       = "gs://$BUCKET/copurchaseanalysis_2.12-0.1.jar"
$INPUT     = "gs://$BUCKET/input/order_products.csv"
$OUTPUT_BASE = "gs://$BUCKET/output"

# Lista dei numeri di worker da testare
$WORKERS_LIST = @(1,2,3,4,5,6)

# File CSV risultati
$CSV_FILE = "scalability_results.csv"
"Workers,StartTime,EndTime,DurationSeconds" | Out-File -FilePath $CSV_FILE -Encoding utf8

foreach ($NUM_WORKERS in $WORKERS_LIST) {
    $CLUSTER="copurchase-cluster-$NUM_WORKERS"

    Write-Host "==============================="
    Write-Host "Creazione cluster con $NUM_WORKERS worker..."
    Write-Host "==============================="

    if ($NUM_WORKERS -eq 1) {
        # Cluster single-node
        gcloud dataproc clusters create $CLUSTER `
            --project=$PROJECT `
            --region=$REGION `
            --zone=$ZONE `
            --single-node `
            --master-machine-type=n1-standard-4 `
            --master-boot-disk-size=50GB `
            --quiet
    } else {
        # Cluster multi-node
        gcloud dataproc clusters create $CLUSTER `
            --project=$PROJECT `
            --region=$REGION `
            --zone=$ZONE `
            --master-machine-type=n1-standard-4 `
            --worker-machine-type=n1-standard-4 `
            --master-boot-disk-size=50GB `
            --worker-boot-disk-size=50GB `
            --num-workers=$NUM_WORKERS `
            --quiet
    }

    Write-Host "Cluster $CLUSTER creato. Avvio job Spark..."

    # Salvo il tempo di inizio
    $JobStartTime = Get-Date

    # Avvio job Spark
    gcloud dataproc jobs submit spark `
        --cluster=$CLUSTER `
        --region=$REGION `
        --class=copurchase.CoPurchaseAnalysis `
        --jars=$JAR `
        --properties="spark.executor.memory=6g,spark.driver.memory=4g,spark.executor.cores=4" `
        "--" $INPUT "$OUTPUT_BASE/$NUM_WORKERS-nodes" $NUM_WORKERS

    # Salvo il tempo di fine
    $JobEndTime = Get-Date

    # Calcolo la durata
    $Duration = ($JobEndTime - $JobStartTime).TotalSeconds

    # Scrittura risultati
    "$NUM_WORKERS,$JobStartTime,$JobEndTime,$Duration" | Out-File -FilePath $CSV_FILE -Append -Encoding utf8
    Write-Host "Job completato su $NUM_WORKERS nodi. Durata: $Duration secondi"

    # Cancellazione cluster
    gcloud dataproc clusters delete $CLUSTER --region=$REGION --project=$PROJECT --quiet
}

Write-Host "==============================="
Write-Host "Benchmark completato!"
Write-Host "Risultati salvati in $CSV_FILE"
Write-Host "==============================="
