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

graph_attr = {
    "layout":"dot",
    "compound":"true",
    }

with Diagram(direction="LR" ,  filename="figures/kafka_scheme", show=False, graph_attr=graph_attr):
    
    with Cluster("Producer"):
        topic1 = Python("tweets")
        topic2 = Python("users")
        topic3 = Python("places")

    with Cluster("Kafka Cluster",  direction="LR"):
        k1 = Kafka("Broker")
        k2 = Kafka("Broker")
        k3 = Kafka("Broker")

    sink1 = PredefinedProcess("Sink tweets")
    sink2 = PredefinedProcess("Sink users")
    sink3 = PredefinedProcess("Sink places")
    sink4 = PredefinedProcess("Sink sentiment")
    
    topic2 >> k1
    topic2 >> k2
    topic2 >> k3

    k3 >> Edge(forward=True,reverse=True,  style="dashed") >> Spark("sentiment")

    k2 >> sink1
    k2 >> sink2
    k2 >> sink3
    k2 >> Edge(style="dashed") >> sink4

    mongo = MongoDB("MongoDB")

    sink1 >> mongo
    sink2 >> mongo
    sink3 >> mongo
    sink4 >> Edge(style="dashed") >> mongo
    # sink = PredefinedProcess("Sink connectors")
    
    # spark = Spark("Sentiment analysis")
    # mongo = MongoDB("Mongo Cluster")
    # mongo_python = Python("Report")
    # # with Cluster("Mongo Cluster"):
    # #     cfg = MongoDB("Config server")

    # #     with Cluster("Shard Cluster"):
    # #         sh1 = MongoDB("Primary")
    # #         sh2 = MongoDB("Secondary")
    # #         sh1 - sh2

    # SM >> Edge(label="Bearer Token") >> api >> Edge(label="Raw Data", color="green") >> k1 >> Edge(label="Raw Data", color="green") >> spark


    # spark >> Edge(label="Sentiment", color="red", reverse=True,) >> k1 >> Edge(label="Sentiment", color="red") >> sink >> Edge(label="Sentiment", color="red") >> mongo

    # k1 >> Edge(label="Raw Data", color="green") >> sink >> Edge(label="Raw Data", color="green") >> mongo

    # mongo >> Edge(label="All Data") >> mongo_python

    
    
    
