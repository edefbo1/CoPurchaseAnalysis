package copurchase

import org.apache.spark.sql.SparkSession
import org.apache.spark.rdd.RDD

/**
 * Entry point per l'analisi di co-acquisto.
 * Argomenti:
 *   - args(0): path input
 *   - args(1): path output
 */
object CoPurchaseAnalysis {

  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      println("Usage: CoPurchaseAnalysis <inputPath> <outputPath>")
      sys.exit(1)
    }

    val inputPath = args(0)
    val outputPath = args(1)

    val spark = SparkSession.builder()
      .appName("CoPurchaseAnalysis")
      .getOrCreate()

    try {
      val inputRDD: RDD[(Int, Int)] = spark.sparkContext
        .textFile(inputPath)
        .map(_.split(","))
        .filter(_.length == 2)
        .map(arr => (arr(0).toInt, arr(1).toInt))

      val resultRDD = PairCounter.computeCoPurchases(inputRDD)

      resultRDD
        .map { case (p1, p2, count) => s"$p1,$p2,$count" }
        .coalesce(1)
        .saveAsTextFile(outputPath)

    } finally {
      spark.stop()
    }
  }
}
