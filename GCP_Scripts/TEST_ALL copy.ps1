# Variabili di configurazione
$PROJECT     = "erudite-course-457308-h3"
$REGION      = "europe-west1"
$ZONE        = "europe-west1-b"
$BUCKET      = "dataset-copurchase"
$JAR         = "gs://$BUCKET/copurchaseanalysis_2.12-0.1.jar"
$INPUT       = "gs://$BUCKET/input/order_products.csv"
$OUTPUT_BASE = "gs://$BUCKET/output"

$OutputCsv   = "scalability_results.csv"
"Workers,StartTime,EndTime,DurationSeconds" | Out-File -Encoding utf8 $OutputCsv

# Numero di worker da testare
$workersList = 1,2,3,4

foreach ($workers in $workersList) {
    Write-Host "==============================="
    Write-Host "Creazione cluster con $workers nodi..."
    Write-Host "==============================="

    $ClusterName = "copurchase-cluster-$workers"

    if ($workers -eq 1) {
        gcloud dataproc clusters create $ClusterName `
            --project=$PROJECT `
            --region=$REGION `
            --zone=$ZONE `
            --single-node `
            --master-machine-type=n1-standard-2 `
            --image-version=2.1-debian11 `
            --quiet
    }
    else {
        gcloud dataproc clusters create $ClusterName `
            --project=$PROJECT `
            --region=$REGION `
            --zone=$ZONE `
            --num-workers=$workers `
            --master-machine-type=n1-standard-2 `
            --worker-machine-type=n1-standard-2 `
            --image-version=2.1-debian11 `
            --quiet
    }

    # Timestamp inizio
    $StartTime = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

    # Lancio del job Spark (cattura corretto JobId)
    $JobId = $(gcloud dataproc jobs submit spark `
        --project=$PROJECT `
        --cluster=$ClusterName `
        --region=$REGION `
        --class copurchase.CoPurchaseAnalysis `
        --jars=$JAR `
        "--" $INPUT "$OUTPUT_BASE/$workers-nodes" `
        --format="value(reference.jobId)")

    Write-Host "Job $JobId avviato su $workers nodi"

    # Attesa completamento
    gcloud dataproc jobs wait $JobId --region=$REGION --project=$PROJECT

    # Timestamp fine
    $EndTime = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    $Duration = [int]((Get-Date $EndTime) - (Get-Date $StartTime)).TotalSeconds

    # Salvataggio risultati
    "$workers,$StartTime,$EndTime,$Duration" | Out-File -Append -Encoding utf8 $OutputCsv

    # Eliminazione cluster
    gcloud dataproc clusters delete $ClusterName --region=$REGION --project=$PROJECT --quiet
}

Write-Host "==============================="
Write-Host "Benchmark completato!"
Write-Host "Risultati salvati in $OutputCsv"
Write-Host "==============================="
