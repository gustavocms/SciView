import dateutil.parser
import optparse
import Queue
import tempodb
import datetime
from threading import Thread


class Worker(Thread):
    """Thread executing tasks from a given tasks queue"""
    def __init__(self, tasks):
        Thread.__init__(self)
        self.tasks = tasks
        self.daemon = True
        self.start()

    def run(self):
        while True:
            func, args, kargs = self.tasks.get()
            try:
                func(*args, **kargs)
            except Exception as e:
                print(e)
            self.tasks.task_done()


class ThreadPool:
    """Pool of threads consuming tasks from a queue"""
    def __init__(self, num_threads):
        self.tasks = Queue(num_threads)
        for _ in range(num_threads): Worker(self.tasks)

    def add_task(self, func, *args, **kargs):
        """Add a task to the queue"""
        self.tasks.put((func, args, kargs))
        print("time: %s \t Just popped one off!" % (datetime.datetime.now().time()))

    def wait_completion(self):
        """Wait for completion of all the tasks in the queue"""
        self.tasks.join()
        print("time: %s \t All done!" % (datetime.datetime.now().time()))


def main():
    # This script assumes that the input file is sorted by key
    parser = optparse.OptionParser(usage="usage: %prog [options] filename", version="%prog 0.1")
    parser.add_option("-i", "--input", dest="filename", help="read data from FILENAME")
    parser.add_option("-k", "--key", dest="key",  help="tempodb database key")
    parser.add_option("-s", "--secret", dest="secret", help="tempodb database secret")
    parser.add_option("-H", "--host", dest="host", default="api.tempo-db.com", help="tempodb host")
    parser.add_option("-P", "--port", dest="port", default=443, help="tempodb port")
    parser.add_option("-S", "--secure", action="store_true", dest="secure", default=True, help="tempodb secure")

    (options, args) = parser.parse_args()
    print()
    print (options)
    print (args)
    print()
    if not options.filename:
        parser.error("Enter a file to read from.")

    in_filename = options.filename
    source_file = open(in_filename)
    client = tempodb.Client(options.key, options.secret, options.host, int(options.port), options.secure)

    temperature_key = "a.thermostat.1.temperature"
    # solar_radiation_key = "thermostat.1.solar_radiation"
    # humidity_key = "thermostat.1.humidity"

    temperature_data = []
    solar_radiation_data = []
    humidity_data = []

    count = 0

    total = 0

    # Init a Thread pool with the desired number of threads
    pool = ThreadPool(3)

    for line in source_file:
        # timestamp, temperature, solar_radiation, humidity = line.split(',')
        timestamp, temperature = line.split(',')

        # grab 20 lines at a time
        if count >= 5000:
            total += count
            pool.add_task(client.write_key, temperature_key, temperature_data)
            print("time: %s \t count: %d" % (datetime.datetime.now().time(), total))
            # pool.add_task(client.write_key, solar_radiation_key, solar_radiation_data)
            # pool.add_task(client.write_key, humidity_key, humidity_data)
            temperature_data = []
            # solar_radiation_id = []
            # humidity_id = []
            count = 0

        input_date = dateutil.parser.parse(timestamp)
        temperature_data.append(tempodb.DataPoint(input_date, float(temperature)))
        # solar_radiation_data.append(tempodb.DataPoint(input_date, float(solar_radiation)))
        # humidity_data.append(tempodb.DataPoint(input_date, float(humidity)))
        
        count += 1

    # pick up any scraps
    if len(temperature_data) > 0:
        pool.add_task(client.write_key, temperature_key, temperature_data)
        # pool.add_task(client.write_key, solar_radiation_key, solar_radiation_data)
        # pool.add_task(client.write_key, humidity_key, humidity_data)

    source_file.close()

    # Wait for completion
    pool.wait_completion()

if __name__ == '__main__':
    main()