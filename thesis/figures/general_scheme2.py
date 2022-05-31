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
from diagrams.custom import Custom

with Diagram(direction="LR", filename="figures/general_scheme2", show=False):
    
    twitter = Custom("Twitter API", "Twitter-logo.svg")
    api = Python("Polecenie własne")
    SM = SecretsManager("AWS Secrets manager")
    
    with Cluster("Klaster Kafka"):
        k1 = Kafka()
        z1 = Zookeeper()
        k1 - z1
    
        with Cluster("Łączniki Kafka-MongoDB typu sink"):
            k2 = Kafka() 
            m1 = MongoDB()
            k2 - m1
    
    mongo = MongoDB("MongoDB Cluster")
    mongo_python = Python("Raport")


    SM >> Edge(label="Bearer Token", style="dashed") >> api 
    twitter >> Edge(label="Zapytanie do serwera Twitter") >> api
    api >> Edge(label="Odpowiedź serwera Twitter") >> twitter
    
    api >> Edge(label="Surowe dane", color="darkgreen") >> k1 
    k1 >> Edge(label="Modyfikacja kluczy partycjonowania", color="orange") >> k2
    m1 >> Edge(label="Zapis", color="red") >> mongo
    mongo >> Edge(label="Analiza wsadowa", color="darkred") >> mongo_python

    # spark >> Edge(label="Sentiment", color="red", reverse=True,) >> k1 >> Edge(label="Sentiment", color="red") >> sink >> Edge(label="Sentiment", color="red") >> mongo

    # k1 >> Edge(label="Raw Data", color="green") >> sink >> Edge(label="Raw Data", color="green") >> mongo

    # mongo >> Edge(label="All Data") >> mongo_python

    
    
    
