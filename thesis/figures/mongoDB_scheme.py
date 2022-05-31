from diagrams import Cluster, Diagram, Edge, Node
from diagrams.onprem.database import MongoDB
from diagrams.onprem.database import MySQL
from diagrams.aws.security import SecretsManager
from diagrams.aws.compute import EC2
from diagrams.onprem.queue import Kafka
from diagrams.onprem.analytics import Spark
from diagrams.onprem.network import Zookeeper
from diagrams.generic.blank import Blank
from diagrams.programming.language import Python
from diagrams.programming.flowchart import PredefinedProcess


with Diagram(direction="TB" ,  filename="figures/mongoDB_scheme", show=False):
    
    with Cluster("Config Serwer"):
        with Cluster("replicaSet"):
            configsvr = MongoDB("mongod")

    with Cluster("Shard Serwer"):
        with Cluster("replicaSet"):
            with Cluster("PRIMARY"):
                 shard_mongod1 = MongoDB("mongod")
                 mongos = MongoDB("mongos")
            with Cluster("SECONDARY"):
                 shard_mongod2 = MongoDB("mongod")

    kafka = Kafka("Kafka")
    batch = Python("Warstwa biznesowa")
    kafka >> Edge(label="zapis") >> mongos
    mongos >> Edge(label="odczyt") >> batch

    configsvr >> Edge(reverse=True) >> mongos
    shard_mongod1 >> Edge(reverse=True) >> mongos
    shard_mongod2 >> Edge(reverse=True) >> mongos

    shard_mongod1 - Edge(style="dashed") - shard_mongod2
    # topic2 >> k1
    # topic2 >> k2
    # topic2 >> k3

    # k3 >> Edge(forward=True,reverse=True,  style="dashed") >> Spark("sentiment")

    # k2 >> sink1
    # k2 >> sink2
    # k2 >> sink3
    # k2 >> Edge(style="dashed") >> sink4

    # mongo = MongoDB("MongoDB")

    # sink1 >> mongo
    # sink2 >> mongo
    # sink3 >> mongo
    # sink4 >> Edge(style="dashed") >> mongo
 

    
    
    
