from diagrams import Cluster, Diagram, Edge
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

with Diagram(direction="LR", filename="figures/general_scheme", show=False):
    
    api = Python("Twitter API")
    SM = SecretsManager("Secrets manager")
    

    with Cluster("Kafka Cluster",  direction="LR"):
        k1 = Kafka("Kafka Brokers")
        z1 = Zookeeper("Zookeeper processes")
        
    sink = PredefinedProcess("Sink connectors")
    
    spark = Spark("Sentiment analysis")
    mongo = MongoDB("Mongo Cluster")
    mongo_python = Python("Report")
    # with Cluster("Mongo Cluster"):
    #     cfg = MongoDB("Config server")

    #     with Cluster("Shard Cluster"):
    #         sh1 = MongoDB("Primary")
    #         sh2 = MongoDB("Secondary")
    #         sh1 - sh2

    SM >> Edge(label="Bearer Token") >> api >> Edge(label="Raw Data", color="green") >> k1 >> Edge(label="Raw Data", color="green") >> spark


    spark >> Edge(label="Sentiment", color="red", reverse=True,) >> k1 >> Edge(label="Sentiment", color="red") >> sink >> Edge(label="Sentiment", color="red") >> mongo

    k1 >> Edge(label="Raw Data", color="green") >> sink >> Edge(label="Raw Data", color="green") >> mongo

    mongo >> Edge(label="All Data") >> mongo_python

    
    
    
