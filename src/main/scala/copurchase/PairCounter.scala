package copurchase

import org.apache.spark.rdd.RDD
import org.apache.spark.HashPartitioner

object PairCounter {

  def computeCoPurchases(data: RDD[(Int, Int)], numWorkers: Int): RDD[(Int, Int, Int)] = {
    val partitioned = data.partitionBy(new HashPartitioner(4 * numWorkers))

    val grouped = partitioned.groupByKey()

    val pairs = grouped.flatMap { case (_, productList) =>
      val products = productList.toSet.toList.sorted
      for {
        i <- products.indices
        j <- i + 1 until products.size
      } yield ((products(i), products(j)), 1)
    }

    pairs
      .reduceByKey(_ + _)
      .map { case ((p1, p2), count) => (p1, p2, count) }
  }
}
