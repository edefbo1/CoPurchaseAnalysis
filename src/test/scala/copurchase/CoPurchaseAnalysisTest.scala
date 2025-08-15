package copurchase

import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.BeforeAndAfterAll
import org.apache.spark.rdd.RDD

import org.apache.spark.sql.SparkSession

class CoPurchaseAnalysisTest extends AnyFunSuite with BeforeAndAfterAll {

  private var spark: SparkSession = _

  override def beforeAll(): Unit = {
    System.setProperty("user.name", "testuser")  // <--- workaround per l'errore

    spark = SparkSession.builder()
      .master("local[*]")
      .appName("Test")
      .config("spark.sql.warehouse.dir", "file:///tmp/spark-warehouse")
      .getOrCreate()
  }


  override def afterAll(): Unit = {
    if (spark != null) spark.stop()
  }
  

  test("computeCoPurchases should correctly count product pairs") {
    val sc = spark.sparkContext

    // Input mockato: ordineId, prodottoId
    val input: RDD[(Int, Int)] = sc.parallelize(Seq(
      (1, 12), (1, 14),
      (2, 8), (2, 12), (2, 14),
      (3, 8), (3, 12), (3, 14), (3, 16)
    ))

    val result = PairCounter.computeCoPurchases(input).collect().toSet

    val expected = Set(
      (8, 12, 2),
      (8, 14, 2),
      (8, 16, 1),
      (12, 14, 3),
      (12, 16, 1),
      (14, 16, 1)
    )

    assert(result == expected)
  }

}
