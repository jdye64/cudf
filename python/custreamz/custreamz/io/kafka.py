from custreamz import io


class KafkaConsumer(io.StreamingSource):
    def __init__(self, *args, **kwargs):
        print("Creating kafka consumer")


class KafkaProducer(io.StreamingSink):
    def __init__(self, *args, **kwargs):
        print("Creating kafka producer")
