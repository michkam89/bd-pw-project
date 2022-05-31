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


with Diagram(direction="TB" ,  filename="figures/kafka_scheme2", show=False):
    
    with Cluster("Producers"):
        topics = Python("tweets, users, places")

    with Cluster("Kafka Cluster"):
        with Cluster("Broker1"):
            k1 = Kafka()
            z1 = Zookeeper()
            k1 - z1
            with Cluster("Łącznik tweets"):
                
                m1 = MongoDB()
                
            
        with Cluster("Broker2"):
            k2 = Kafka()
            z2 = Zookeeper()
            k2 - z2
            with Cluster("Łącznik users"):
                m2 = MongoDB()

        with Cluster("Broker3"):
            k3 = Kafka()
            z3 = Zookeeper()
            k3 - z3
            with Cluster("Łącznik places"):
                m3 = MongoDB()
    
    mDB = MongoDB("Baza danych")
    m1 >> mDB
    m2 >> mDB
    m3 >> mDB

    topics >> k1
    topics >> k2
    topics >> k3
    
    k1 >> m1
    k2 >> m2
    k3 >> m3



    # k3 >> Edge(forward=True,reverse=True,  style="dashed") >> Spark("sentiment")