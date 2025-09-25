package copurchase

import org.apache.spark.sql.SparkSession
import org.apache.spark.rdd.RDD

object CoPurchaseAnalysis {

  def main(args: Array[String]): Unit = {
    if (args.length != 3) {
      println("Usage: CoPurchaseAnalysis <inputPath> <outputPath> <numWorkers>")
      sys.exit(1)
    }

    val inputPath = args(0)
    val outputPath = args(1)
    val numWorkers = args(2).toInt

    val spark = SparkSession.builder()
      .appName("CoPurchaseAnalysis")
      .getOrCreate()

    try {
      val startTime = System.nanoTime()

      val inputRDD: RDD[(Int, Int)] = spark.sparkContext
        .textFile(inputPath)
        .map(_.split(","))
        .filter(_.length == 2)
        .map(arr => (arr(0).toInt, arr(1).toInt))

      // Passiamo numWorkers a computeCoPurchases
      val resultRDD = PairCounter.computeCoPurchases(inputRDD, numWorkers)

      resultRDD
        .map { case (p1, p2, count) => s"$p1,$p2,$count" }
        .repartition(1)
        .saveAsTextFile(outputPath + "/results")

    } finally {
      spark.stop()
    }
  }
}
